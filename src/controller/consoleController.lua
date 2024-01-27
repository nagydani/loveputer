require("controller.inputController")

require("util.testTerminal")
require("util.key")
require("util.eval")
require("util.table")

--- @class ConsoleController
--- @field time number
--- @field model Model
--- @field env LuaEnv
--- @field pre_env LuaEnv
--- @field base_env LuaEnv
--- @field project_env LuaEnv
--- @field input InputController
ConsoleController = {}
ConsoleController.__index = ConsoleController

setmetatable(ConsoleController, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param M Model
function ConsoleController.new(M)
  local env = getfenv()
  local pre_env = table.clone(env)
  local IC = InputController:new(M.interpreter.input)
  local self = setmetatable({
    time        = 0,
    model       = M,
    input       = IC,
    -- console runner env
    main_env    = env,
    -- copy of the application's env before the prep
    pre_env     = pre_env,
    -- the project env where we make the API available
    base_env    = {},
    -- this is the env in which the user project runs
    -- subject to change, for example when switching projects
    project_env = {},
  }, ConsoleController)
  -- initialize the stub env tables
  ConsoleController.prepare_env(self)
  ConsoleController.prepare_project_env(self)

  return self
end

--- @param f function
--- @param C ConsoleController
--- @param project_path string?
--- @return boolean success
--- @return string? errmsg
local function run_user_code(f, C, project_path)
  local G = love.graphics
  local output = C.model.output
  local env = C:get_base_env()

  G.push('all')
  G.setColor(Color[Color.black])
  output:draw_to()
  local old_path = package.path
  local ok, call_err
  if project_path then
    package.path = string.format('%s;%s/?.lua', package.path, project_path)
    env = C.project_env
  end
  ok, call_err = pcall(f)
  if project_path then -- user project exec
    Controller.set_user_handlers(env['love'])
  end
  package.path = old_path
  output:restore_main()
  G.pop()
  if not ok then
    local e = LANG.parse_error(call_err)
    return false, e
  end
  return true
end

function ConsoleController.prepare_env(cc)
  local prepared            = cc.main_env
  prepared.G                = love.graphics

  local P                   = cc.model.projects

  --- @param f function
  local check_open_pr       = function(f)
    if not P.current then
      print(P.messages.no_open_project)
    else
      return f()
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
    local runner_env = self:get_project_env()
    local f, err, path = P:run(name, runner_env)
    if f then
      local n = name or P.current.name or 'project'
      Log.info('Running \'' .. n .. '\'')
      local ok, run_err = run_user_code(f, cc, path)
      if ok then
        love.state.app_state = 'running'
      else
        print('Error: ', run_err)
      end
    else
      print(err)
    end
  end

  prepared.continue         = function()
    if love.state.app_state == 'inspect' then
      -- resume
      love.state.app_state = 'running'
    end
  end
end

--- API functions for the user
function ConsoleController.prepare_project_env(cc)
  local interpreter      = cc.model.interpreter
  ---@type table
  local project_env      = cc:get_pre_env_c()
  project_env.G          = love.graphics

  --- @param msg string?
  project_env.stop       = function(msg)
    cc:suspend_run(msg)
  end

  --- @param type InputType
  --- @param result any
  local input            = function(type, result)
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
    local input = InputModel:new(cfg, eval, true)
    local controller = InputController:new(input, cb)
    local view = InputView:new(cfg, controller)
    love.state.user_input = {
      M = input, C = controller, V = view
    }
  end

  project_env.input_code = function(result)
    return input('lua', result)
  end
  project_env.input_text = function(result)
    return input('text', result)
  end

  local base             = table.clone(project_env)
  local project          = table.clone(project_env)
  cc:_set_base_env(base)
  cc:_set_project_env(project)
  -- Log.debug(Debug.mem(project_env), 'prep project_env')
  -- Log.debug(Debug.mem(cc.base_env), 'prep base_env')
  -- Log.debug(Debug.mem(cc.project_env), 'prep project_env2')
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
  --- @type Model
  local M = self.model
  --- @type InterpreterModel
  local interpreter = M.interpreter
  local input = interpreter.input
  local P = M.projects
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
      local f, load_err = load(code, '', 't', self:get_env())
      if f then
        -- TODO: distinguish paused project run and normal console
        local _, err = run_user_code(f, self)
        if err then
          interpreter:set_error(err, true)
        end
      else
        -- this means that metalua failed to catch some invalid code
        Log.error('Load error:', LANG.parse_error(load_err))
        interpreter:set_error(load_err, true)
      end
    else
      local _, _, eval_err = interpreter:get_eval_error(res)
      if string.is_non_empty_string(eval_err) then
        orig_print(eval_err)
        interpreter:set_error(eval_err, false)
      end
    end
  end
end

function ConsoleController:_reset_executor_env()
  self:_set_project_env(table.clone(self.base_env))
end

function ConsoleController:reset()
  self:quit_project()
  self.model.interpreter:reset(true) -- clear history
end

---@return LuaEnv
function ConsoleController:get_env()
  return table.clone(self.env)
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
end

--- @param msg string?
function ConsoleController:suspend_run(msg)
  local base_env   = self:get_base_env()
  local runner_env = self:get_project_env()
  if love.state.app_state ~= 'running' then
    return
  end
  Log('Suspending project run')
  love.state.app_state = 'inspect'
  if msg then
    self.model.interpreter:set_error(tostring(msg), true)
  end
end

function ConsoleController:quit_project()
  self.model.output:reset()
  self.model.interpreter:reset()
  nativefs.setWorkingDirectory(love.filesystem.getSourceBaseDirectory())
  Controller.set_default_handlers(self)
  Controller.set_love_update(self)
  love.state.user_input = nil
  View.set_love_draw(self)
  -- TODO clean this up immediately, or leave it for inspection?
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

--- @return ViewData
function ConsoleController:get_viewdata()
  return {
    w_error = self.model.interpreter:get_wrapped_error(),
  }
end

function ConsoleController:autotest()
  local input = self.model.interpreter.input
  input:add_text('list_projects()')
  self:evaluate_input()
  input:add_text('run_project("turtle")')
end
