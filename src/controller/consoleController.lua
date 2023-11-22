ConsoleController = {}

require("util.testTerminal")
require("util.eval")
require("util.table")


--- @param f function
--- @param M Model
--- @return boolean success
--- @return string? errmsg
local function run_user_code(f, M, extra_path)
  local G = love.graphics
  local output = M.output



  G.push('all')
  output:draw_to()
  local old_path = package.path
  local ok, call_err
  if extra_path then
    package.path = string.format('%s;%s/?.lua', package.path, extra_path)
    ok, call_err = pcall(f)
    package.path = old_path
  else
    ok, call_err = pcall(f)
  end
  output:restore_main()
  G.pop()
  if not ok then
    local e = LANG.parse_error(call_err)
    return false, e
  end
  return true
end

--- Put API functions into the env table
--- @param prepared table
--- @param M Model
--- @param runner_env table
local function prepare_env(prepared, M, runner_env)
  local IM = M.input


  prepared.G                = love.graphics

  prepared.switch           =
  --- @param kind EvalType
      function(kind)
        IM:switch(kind)
      end

  local P                   = M.projects
  prepared.list_projects    = function()
    local ps = P:list()
    if ps:is_empty() then
      -- no projects, display a message about it
      print(P.messages.no_projects)
    else
      -- list projects
      M.output:reset()
      print(P.messages.list_header)
      for _, p in ipairs(ps) do
        print('> ' .. p.name)
      end
    end
  end

  --- @param name string
  prepared.create_project   = function(name)
    local ok, err = P:create(name)
    if not ok then
      print(err)
    else
      print('Project ' .. name .. ' created')
    end
  end

  --- @param name string
  prepared.open_project     = function(name)
    local ok, err = P:open(name)
    if not ok then
      print(err)
    else
      print('Project ' .. name .. ' opened')
    end
  end

  prepared.close_project    = function()
    local ok = P:close()
    if ok then
      print('Project closed')
    end
  end

  prepared.current_project  = function()
    if P.current and P.current.name then
      print('Currently open project: ' .. P.current.name)
    else
      print(P.messages.no_open_project)
    end
  end

  prepared.example_projects = function()
    local ok, err = P:deploy_examples()
    if not ok then
      print('err: ' .. err)
    end
  end

  --- @param f function
  local check_open_pr       = function(f)
    if not P.current then
      print(P.messages.no_open_project)
    else
      return f()
    end
  end

  prepared.list_contents    = function()
    return check_open_pr(function()
      local p = P.current
      local items = p:contents()
      print(P.messages.project_header(p.name))
      for name, _ in pairs(items) do
        print('• ' .. name)
      end
    end)
  end

  --- @param name string
  prepared.readfile         = function(name)
    return check_open_pr(function()
      local p = P.current
      local ok, lines_err = p:readfile(name)
      if ok then
        local lines = lines_err
        local nl = string.ulen('' .. #lines .. '  ')
        M.output:reset()
        local w = M.output.cfg.drawableChars - 1
        print(P.messages.file_header(name, w))
        for i, l in ipairs(lines) do
          local ln = string.format("% " .. nl .. "d", i)
          print(string.format("%s │ %s", ln, l))
        end
      else
        print(lines_err)
      end
    end)
  end

  --- @param name string
  --- @param content string
  prepared.writefile        = function(name, content)
    return check_open_pr(function()
      local p = P.current
      local fpath = string.join_path(p.path, name)
      local ex = FS.exists(fpath)
      local text = string.join(content, '\n')
      if ex then
        -- TODO: confirm overwrite
      end
      local ok, err = p:writefile(name, text)
      if ok then
        print(name .. ' written')
      else
        print(err)
      end
    end)
  end

  prepared.run_project      = function(name)
    local f, err, path = P:run(name, runner_env)
    if f then
      local ok, run_err = run_user_code(f, M, path)
      if ok then
        Log('Running \'' .. name .. '\' finished')
      else
        print('Error: ', run_err)
      end
    else
      print(err)
    end
  end
end

function ConsoleController:new(M)
  local env = getfenv()
  local project_env = getfenv()
  prepare_env(env, M, project_env)
  local cc = {
    time        = 0,
    model       = M,
    base_env    = table.clone(env),
    env         = table.clone(env),
    project_env = project_env,
  }
  setmetatable(cc, self)
  self.__index = self

  return cc
end

function ConsoleController:pass_time(dt)
  self.time = self.time + dt
  self.model.output.terminal:update(dt)
end

function ConsoleController:get_timestamp()
  return self.time
end

function ConsoleController:evaluate_input()
  local input = self.model.input
  local P = self.model.projects
  local project_path
  if P.current then
    project_path = P.current.path
  end

  local text = input:get_text()
  local eval = input.evaluator

  local eval_ok, res = input:evaluate()
  if eval.is_lua then
    if eval_ok then
      local code = string.join(text, '\n')
      local f, load_err = load(code, '', 't', self.env)
      if f then
        local _, err = run_user_code(f, self.model, project_path)
        if err then
          input:set_error(err, true)
        end
      else
        -- this means that metalua failed to catch some invalid code
        orig_print('Load error:', LANG.parse_error(load_err))
        input:set_error(load_err, true)
      end
    else
      local _, _, eval_err = input:get_eval_error(res)
      if string.is_non_empty_string(eval_err) then
        orig_print(eval_err)
        input:set_error(eval_err)
      end
    end
  end
end

function ConsoleController:_reset_executor_env()
  self.env = table.clone(self.base_env)
end

function ConsoleController:reset()
  self:quit_project()
  self.model.input:reset(true) -- clear history
end

function ConsoleController:quit_project()
  self.model.output:reset()
  self.model.input:reset()
  nativefs.setWorkingDirectory(love.filesystem.getSourceBaseDirectory())
  Controller.set_default_handlers()
  Controller.set_love_update()
  View.set_love_draw()
  self:_reset_executor_env()
end

function ConsoleController:keypressed(k)
  local out = self.model.output
  local input = self.model.input
  local function is_enter()
    return k == "return" or k == 'kpenter'
  end

  local function terminal_test()
    if not love.state.testing then
      love.state.testing = 'running'
      input:cancel()
      TerminalTest:test(out.terminal)
    elseif love.state.testing == 'waiting' then
      TerminalTest:reset(out.terminal)
      love.state.testing = false
    end
  end

  if input:has_error() then
    input:clear_error()
    return
  end

  if love.state.testing == 'running' then
    return
  end
  if love.state.testing == 'waiting' then
    terminal_test()
    return
  end

  local ctrl, shift
  ctrl  = love.keyboard.isDown("lctrl", "rctrl")
  shift = love.keyboard.isDown("lshift", "rshift")

  -- input controls
  do
    if k == "backspace" then
      input:backspace()
    end
    if k == "delete" then
      input:delete()
    end

    if k == "up" then
      input:cursor_vertical_move('up')
    end
    if k == "down" then
      input:cursor_vertical_move('down')
    end
    if k == "left" then
      input:cursor_left()
    end
    if k == "right" then
      input:cursor_right()
    end

    if k == "pageup" then
      input:history_back()
    end
    if k == "pagedown" then
      input:history_fwd()
    end

    if k == "home" then
      input:jump_home()
    end
    if k == "end" then
      input:jump_end()
    end

    if not shift and is_enter() then
      self:evaluate_input()
    end
    if not ctrl and k == "escape" then
      input:cancel()
    end
  end

  local function paste() input:paste(love.system.getClipboardText()) end
  local function copy()
    local t = input:get_selected_text()
    love.system.setClipboardText(string.join(t, '\n'))
  end
  local function cut()
    local t = input:pop_selected_text()
    love.system.setClipboardText(string.join(t, '\n'))
  end
  -- Ctrl held
  if ctrl then
    if k == "v" then
      paste()
    end
    if k == "c" or k == "insert" then
      copy()
    end
    if k == "x" then
      cut()
    end
    if k == "l" then
      self.model.output:reset()
    end
    if love.DEBUG then
      if k == 't' then
        terminal_test()
        return
      end
      if k == 'o' then
        input:test_lua_eval()
      end
    end
  end

  -- Shift held
  if shift then
    if k == "insert" then
      paste()
    end
    if k == "delete" then
      cut()
    end
    if is_enter() then
      input:line_feed()
    end
    input:hold_selection()
  end

  -- Ctrl and Shift held
  if ctrl and shift then
    if k == "q" then
      self:quit_project()
    end
    if k == "r" then
      self:reset()
    end
  end
end

function ConsoleController:keyreleased(k)
  if k == "lshift" or k == "rshift" then
    local im = self.model.input
    im:release_selection()
  end
end

function ConsoleController:textinput(t)
  -- TODO: block with events
  self.model.input:add_text(t)
end

function ConsoleController:_translate_to_input_grid(x, y)
  local cfg = self.model.output.cfg
  local h = cfg.h
  local fh = cfg.fh
  local fw = cfg.fw
  local line = math.floor((h - y) / fh)
  local a, b = math.modf((x / fw))
  local char = a + 1
  if b > .5 then char = char + 1 end
  return char, line
end

function ConsoleController:_handle_mouse(x, y, btn, handler)
  if btn == 1 then
    local im = self.model.input
    local n_lines = #(im:get_wrapped_text())
    local c, l = self:_translate_to_input_grid(x, y)
    if l < n_lines then
      handler(n_lines - l, c)
    end
  end
end

function ConsoleController:mousepressed(x, y, btn)
  local im = self.model.input
  self:_handle_mouse(x, y, btn, function(l, c)
    im:mouse_click(l, c)
  end)
end

function ConsoleController:mousereleased(x, y, btn)
  local im = self.model.input
  self:_handle_mouse(x, y, btn, function(l, c)
    im:mouse_release(l, c)
  end)
  im:release_selection()
end

function ConsoleController:mousemoved(x, y)
  local im = self.model.input
  self:_handle_mouse(x, y, 1, function(l, c)
    im:mouse_drag(l, c)
  end)
end

function ConsoleController:get_terminal()
  return self.model.output.terminal
end

function ConsoleController:get_input()
  local im = self.model.input
  local wt, wt_info = im:get_wrapped_text()
  return {
    text = im:get_text(),
    wrapped_text = wt,
    wt_info = wt_info,
    wrapped_error = im:get_wrapped_error(),
    highlight = im:highlight(),
    selection = im:get_ordered_selection(),
  }
end

function ConsoleController:get_cursor_info()
  return self.model.input:get_cursor_info()
end

function ConsoleController:get_status()
  return self.model.input:get_status()
end

function ConsoleController:autotest()
  local input = self.model.input
  local output = self.model.output
  local term = output.terminal
  input:add_text('list_projects()')
  self:evaluate_input()
  input:add_text('run_project("turtle")')
end
