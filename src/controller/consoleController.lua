require("controller.inputController")
require("controller.interpreterController")
require("controller.editorController")

local class = require('util.class')
require("util.lua")
require("util.testTerminal")
require("util.key")
local LANG = require("util.eval")
require("util.table")

--- @class ConsoleController
--- @field time number
--- @field model Model
--- @field main_env LuaEnv
--- @field pre_env LuaEnv
--- @field base_env LuaEnv
--- @field project_env LuaEnv
--- @field input InputController
--- @field interpreter InterpreterController
--- @field editor EditorController
--- @field view ConsoleView?
--- methods
--- @field edit function
--- @field finish_edit function
ConsoleController = class.create()

--- @param M Model
function ConsoleController.new(M)
  local env = getfenv()
  local pre_env = table.clone(env)
  local config = M.cfg
  pre_env.font = config.view.font
  local IpC = InputController(M.interpreter.input)
  local InC = InterpreterController.new(M.interpreter, IpC)
  local EC = EditorController.new(M.editor)
  local self = setmetatable({
    time        = 0,
    model       = M,
    interpreter = InC,
    editor      = EC,
    -- console runner env
    main_env    = env,
    -- copy of the application's env before the prep
    pre_env     = pre_env,
    -- the project env where we make the API available
    base_env    = {},
    -- this is the env in which the user project runs
    -- subject to change, for example when switching projects
    project_env = {},

    view        = nil,

    cfg         = config
  }, ConsoleController)
  -- initialize the stub env tables
  ConsoleController.prepare_env(self)
  ConsoleController.prepare_project_env(self)

  return self
end

--- @param V ConsoleView
function ConsoleController:set_view(V)
  self.view = V
end

--- @param f function
--- @param cc ConsoleController
--- @param project_path string?
--- @return boolean success
--- @return string? errmsg
local function run_user_code(f, cc, project_path)
  local G = love.graphics
  local output = cc.model.output
  local env = cc:get_base_env()

  G.setCanvas(cc:get_canvas())
  G.push('all')
  G.setColor(Color[Color.black])
  local old_path = package.path
  local ok, call_err
  if project_path then
    package.path = string.format('%s;%s/?.lua', package.path, project_path)
    env = cc.project_env
  end
  ok, call_err = pcall(f)
  if project_path then -- user project exec
    Controller.set_user_handlers(env['love'])
  end
  package.path = old_path
  output:restore_main()
  G.pop()
  G.setCanvas()
  if not ok then
    local e = LANG.get_call_error(call_err)
    return false, e
  end
  return true
end

--- @param cc ConsoleController
local function close_project(cc)
  local ok = cc:close_project()
  if ok then
    print('Project closed')
  end
end

--- @private
--- @param name string
--- @return string[]?
function ConsoleController:_readfile(name)
  local PS            = self.model.projects
  local p             = PS.current
  local ok, lines_err = p:readfile(name)
  if ok then
    local lines = lines_err
    return lines
  else
    print(lines_err)
  end
end

--- @private
--- @param name string
--- @param content string[]
--- @return boolean success
--- @return string? err
function ConsoleController:_writefile(name, content)
  local P = self.model.projects
  local p = P.current
  local text = string.unlines(content)
  return p:writefile(name, text)
end

function ConsoleController.prepare_env(cc)
  local prepared            = cc.main_env
  prepared.G                = love.graphics

  local P                   = cc.model.projects

  --- @param f function
  local check_open_pr       = function(f, ...)
    if not P.current then
      print(P.messages.no_open_project)
    else
      return f(...)
    end
  end

  prepared.list_projects    = function()
    local ps = P:list()
    if ps:is_empty() then
      -- no projects, display a message about it
      print(P.messages.no_projects)
    else
      -- list projects
      cc.model.output:reset()
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
    close_project(cc)
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
  --- @return string[]?
  prepared.readfile         = function(name)
    return check_open_pr(cc._readfile, cc, name)
  end

  --- @param name string
  --- @param content string[]
  prepared.writefile        = function(name, content)
    return check_open_pr(function()
      local p = P.current
      local fpath = string.join_path(p.path, name)
      local ex = FS.exists(fpath)
      if ex then
        -- TODO: confirm overwrite
      end
      local ok, err = cc:_writefile(name, content)
      if ok then
        print(name .. ' written')
      else
        print(err)
      end
    end)
  end

  --- @param name string
  --- @return any
  prepared.runfile          = function(name)
    local con = check_open_pr(cc._readfile, cc, name)
    local code = string.unlines(con)
    local chunk, err = load(code, '', 't')
    if chunk then
      chunk()
    else
      print(err)
    end
  end

  --- @param name string
  prepared.edit             = function(name)
    return check_open_pr(cc.edit, cc, name)
  end

  prepared.run_project      = function(name)
    if love.state.app_state == 'inspect' or
        love.state.app_state == 'running'
    then
      cc.interpreter:set_error("There's already a project running!", true)
      return
    end
    local runner_env = cc:get_project_env()
    local f, err, path = P:run(name, runner_env)
    if f then
      local n = name or P.current.name or 'project'
      Log.info('Running \'' .. n .. '\'')
      local ok, run_err = run_user_code(f, cc, path)
      if ok then
        if Controller.has_user_update() then
          love.state.app_state = 'running'
        end
      else
        print('Error: ', run_err)
      end
    else
      print(err)
    end
  end

  prepared.quit             = function()
    love.event.quit()
  end
end

--- API functions for the user
--- @param cc ConsoleController
function ConsoleController.prepare_project_env(cc)
  require("controller.userInputController")
  require("model.input.userInputModel")
  require("view.input.userInputView")
  local interpreter           = cc.model.interpreter
  ---@type table
  local project_env           = cc:get_pre_env_c()
  project_env.G               = love.graphics

  --- @param msg string?
  project_env.stop            = function(msg)
    cc:suspend_run(msg)
  end

  project_env.continue        = function()
    if love.state.app_state == 'inspect' then
      -- resume
      love.state.app_state = 'running'
      Controller.restore_user_handlers()
    else
      print('No project halted')
    end
  end

  project_env.close_project   = function()
    close_project(cc)
  end

  --- @param type InputType
  --- @param result any
  local input                 = function(type, result)
    if love.state.user_input then
      return -- there can be only one
    end
    local cfg = interpreter.cfg
    local eval
    if type == 'lua' then
      eval = interpreter.luaInput
    elseif type == 'text' then
      eval = interpreter.textInput
    else
      Log('Invalid input type!')
      return
    end
    local cb = function(v) table.insert(result, 1, v) end
    local input = UserInputModel(cfg, eval, true)
    local controller = UserInputController(input, cb)
    local view = UserInputView(cfg.view, controller)
    love.state.user_input = {
      M = input, C = controller, V = view
    }
  end

  project_env.input_code      = function(result)
    return input('lua', result)
  end
  project_env.input_text      = function(result)
    return input('text', result)
  end

  project_env.validated_input = function(result, filters)
    if love.state.user_input then
      return -- there can be only one
    end
    local cfg = interpreter.cfg
    local cb = function(v) table.insert(result, 1, v) end
    local eval = ValidatedTextEval(filters)
    local model = UserInputModel(cfg, eval, true)
    local controller = UserInputController(model, cb)
    local view = UserInputView(cfg.view, controller)
    love.state.user_input = {
      M = model, C = controller, V = view
    }
  end

  --- @param name string
  project_env.edit            = function(name)
    return cc:edit(name)
  end

  local base                  = table.clone(project_env)
  local project               = table.clone(project_env)
  cc:_set_base_env(base)
  cc:_set_project_env(project)
end

---@param dt number
function ConsoleController:pass_time(dt)
  self.time = self.time + dt
  self.model.output.terminal:update(dt)
end

---@return number
function ConsoleController:get_timestamp()
  return self.time
end

function ConsoleController:evaluate_input()
  --- @type InterpreterController
  local inter = self.interpreter

  local text = inter:get_text()
  local eval = inter:get_eval()

  local eval_ok, res = inter:evaluate()

  if eval.parser then
    if eval_ok then
      local code = string.unlines(text)
      local run_env = (function()
        if love.state.app_state == 'inspect' then
          return self:get_project_env()
        end
        return self:get_console_env()
      end)()
      local f, load_err = load(code, '', 't', run_env)
      if f then
        local _, err = run_user_code(f, self)
        if err then
          inter:set_error(err, true)
        end
      else
        -- this means that metalua failed to catch some invalid code
        Log.error('Load error:', LANG.get_call_error(load_err))
        inter:set_error(load_err, true)
      end
    else
      local eval_err = res
      if eval_err then
        local msg = eval_err.msg
        if string.is_non_empty_string(msg) then
          orig_print(msg)
          inter:set_error(msg, false)
        end
      end
    end
  end
end

function ConsoleController:_reset_executor_env()
  self:_set_project_env(table.clone(self.base_env))
end

function ConsoleController:reset()
  self:quit_project()
  self.interpreter:reset(true) -- clear history
end

---@return LuaEnv
function ConsoleController:get_console_env()
  return self.main_env
end

---@return LuaEnv
function ConsoleController:get_pre_env_c()
  return table.clone(self.pre_env)
end

---@return LuaEnv
function ConsoleController:get_project_env()
  return self.project_env
end

---@return LuaEnv
function ConsoleController:get_base_env()
  return self.base_env
end

---@param t LuaEnv
function ConsoleController:_set_project_env(t)
  self.project_env = t
end

---@param t LuaEnv
function ConsoleController:_set_base_env(t)
  self.base_env = t
  table.protect(t)
end

--- @param msg string?
function ConsoleController:suspend_run(msg)
  -- local base_env   = self:get_base_env()
  local runner_env = self:get_project_env()
  if love.state.app_state ~= 'running' then
    return
  end
  Log.info('Suspending project run')
  love.state.app_state = 'inspect'
  if msg then
    self.interpreter:set_error(tostring(msg), true)
  end

  self.model.output:invalidate_terminal()

  Controller.save_user_handlers(runner_env['love'])
  Controller.set_default_handlers(self, self.view)
end

function ConsoleController:close_project()
  local P = self.model.projects
  P:close()
  self:_reset_executor_env()
  Controller.clear_user_handlers()
  self.model.output:clear_canvas()
  love.state.app_state = 'ready'
end

function ConsoleController:quit_project()
  self.model.output:reset()
  self.interpreter:reset()
  nativefs.setWorkingDirectory(love.filesystem.getSourceBaseDirectory())
  Controller.set_default_handlers(self, self.view)
  Controller.set_love_update(self)
  love.state.user_input = nil
  Controller.set_love_draw(self, self.view)
  -- TODO clean snap and everything
  self:close_project()
end

--- @param name string
function ConsoleController:edit(name)
  if love.state.app_state == 'running' then return end

  local PS       = self.model.projects
  local p        = PS.current
  local filename = name or ProjectService.MAIN
  local fpath    = string.join_path(p.path, filename)
  local ex       = FS.exists(fpath)
  local text
  if ex then
    text = self:_readfile(filename)
  end
  love.state.prev_state = love.state.app_state
  love.state.app_state = 'editor'
  self.editor:open(filename, text)
end

function ConsoleController:finish_edit()
  local name, newcontent = self.editor:close()
  local ok, err = self:_writefile(name, newcontent)
  if ok then
    love.state.app_state = love.state.prev_state
    love.state.prev_state = nil
  else
    print(err)
  end
end

--- Handlers ---

--- @param t string
function ConsoleController:textinput(t)
  if love.state.app_state == 'editor' then
    self.editor:textinput(t)
  else
    local inter = self.interpreter
    if inter:has_error() then
      inter:clear_error()
    else
      if Key.ctrl() and Key.shift() then
        return
      end
      inter:textinput(t)
    end
  end
end

--- @param k string
function ConsoleController:keypressed(k)
  local inter = self.interpreter

  local function terminal_test()
    local out = self.model.output
    if not love.state.testing then
      love.state.testing = 'running'
      inter:cancel()
      TerminalTest.test(out.terminal)
    elseif love.state.testing == 'waiting' then
      TerminalTest.reset(out.terminal)
      love.state.testing = false
    end
  end

  if love.state.app_state == 'editor' then
    self.editor:keypressed(k)
  else
    if love.state.testing == 'running' then
      return
    end
    if love.state.testing == 'waiting' then
      terminal_test()
      return
    end

    if inter:has_error() then
      if k == 'space' or Key.is_enter(k)
          or k == "up" or k == "down" then
        inter:clear_error()
      end
      return
    end

    if k == "pageup" then
      inter:history_back()
    end
    if k == "pagedown" then
      inter:history_fwd()
    end
    local limit = inter:keypressed(k)
    if limit then
      if k == "up" then
        inter:history_back()
      end
      if k == "down" then
        inter:history_fwd()
      end
    end
    if not Key.shift() and Key.is_enter(k) then
      if not inter:has_error() then
        self:evaluate_input()
      end
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
      end
    end
    -- Ctrl and Shift held
    if Key.ctrl() and Key.shift() then
      if k == "r" then
        self:reset()
      end
    end
  end
end

--- @param k string
function ConsoleController:keyreleased(k)
  self.interpreter:keyreleased(k)
end

function ConsoleController:mousepressed(x, y, button)
  if love.state.app_state == 'editor' then
    self.editor.interpreter:mousepressed(x, y, button)
  else
    self.interpreter:mousepressed(x, y, button)
  end
end

function ConsoleController:mousereleased(x, y, button)
  if love.state.app_state == 'editor' then
    self.editor.interpreter:mousereleased(x, y, button)
  else
    self.interpreter:mousereleased(x, y, button)
  end
end

function ConsoleController:mousemoved(x, y, dx, dy)
  if love.state.app_state == 'editor' then
    self.editor.interpreter:mousemoved(x, y)
  else
    self.interpreter:mousemoved(x, y)
  end
end

--- @return Terminal
function ConsoleController:get_terminal()
  return self.model.output.terminal
end

--- @return love.Canvas
function ConsoleController:get_canvas()
  return self.model.output.canvas
end

--- @return ViewData
function ConsoleController:get_viewdata()
  return {
    w_error = self.interpreter:get_wrapped_error(),
  }
end

function ConsoleController:autotest()
  --- @diagnostic disable-next-line undefined-global
  local autotest = prequire('tests/autotest')
  if autotest then
    autotest(self)
  end
end
