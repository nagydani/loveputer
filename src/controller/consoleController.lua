require("controller.inputController")

require("util.testTerminal")
require("util.key")
require("util.eval")
require("util.table")

ConsoleController = {}

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
  prepared.G                = love.graphics

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
  prepared.project          = function(name)
    local open, create, err = P:opreate(name)
    if open then
      print('Project ' .. name .. ' opened')
    elseif create then
      print('Project ' .. name .. ' created')
    else
      print(err)
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
      for _, f in pairs(items) do
        print('• ' .. f.name)
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
        return lines
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
  local IC = InputController:new(M.interpreter.input)
  local cc = {
    time        = 0,
    model       = M,
    base_env    = table.clone(env),
    env         = table.clone(env),
    project_env = project_env,
    input       = IC
  }
  setmetatable(cc, self)
  self.__index = self

  return cc
end

function ConsoleController:pass_time(dt)
  self.time = self.time + dt
  self.model.output.terminal:update(dt)
end

---@return number
function ConsoleController:get_timestamp()
  return self.time
end

function ConsoleController:evaluate_input()
  local interpreter = self.model.interpreter
  local input = interpreter.input
  local P = self.model.projects
  local project_path
  if P.current then
    project_path = P.current.path
  end

  local text = input:get_text()
  local eval = input.evaluator

  local eval_ok, res = interpreter:evaluate()
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
  self.model.interpreter:reset(true) -- clear history
end

function ConsoleController:quit_project()
  self.model.output:reset()
  self.model.interpreter:reset()
  nativefs.setWorkingDirectory(love.filesystem.getSourceBaseDirectory())
  Controller.set_default_handlers()
  Controller.set_love_update()
  View.set_love_draw()
  self:_reset_executor_env()
end

function ConsoleController:keypressed(k)
  local out = self.model.output
  local interpreter = self.model.interpreter

  local function terminal_test()
    if not love.state.testing then
      love.state.testing = 'running'
      interpreter:cancel()
      TerminalTest:test(out.terminal)
    elseif love.state.testing == 'waiting' then
      TerminalTest:reset(out.terminal)
      love.state.testing = false
    end
  end

  if interpreter:has_error() then
    interpreter:clear_error()
    return
  end

  if love.state.testing == 'running' then
    return
  end
  if love.state.testing == 'waiting' then
    terminal_test()
    return
  end

  if k == "pageup" then
    interpreter:history_back()
  end
  if k == "pagedown" then
    interpreter:history_fwd()
  end

  local limit = self.input:keypressed(k)
  if limit then
    if k == "up" then
      interpreter:history_back()
    end
    if k == "down" then
      interpreter:history_fwd()
    end
  end
  if not Key.shift() and Key.is_enter(k) then
    self:evaluate_input()
  end

  -- Ctrl held
  if Key.ctrl() then
    if k == "l" then
      self.model.output:reset()
    end
    if love.DEBUG then
      if k == 't' then
        terminal_test()
        return
      end
      if k == 'o' then
        interpreter:test_lua_eval()
      end
    end
  end
  -- Ctrl and Shift held
  if Key.ctrl() and Key.shift() then
    if k == "q" then
      self:quit_project()
    end
    if k == "r" then
      self:reset()
    end
  end
end

function ConsoleController:keyreleased(k)
  self.input:keyreleased(k)
end

function ConsoleController:get_terminal()
  return self.model.output.terminal
end

function ConsoleController:get_status()
  return self.model.interpreter:get_status()
end

function ConsoleController:autotest()
  local input = self.model.interpreter
  local output = self.model.output
  local term = output.terminal
  input:add_text('list_projects()')
  self:evaluate_input()
  input:add_text('run_project("turtle")')
end
