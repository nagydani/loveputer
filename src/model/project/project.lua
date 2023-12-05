require("util.string")
require("util.filesystem")


local function error_annot(base)
  return function(err)
    local msg = base
    if err then
      msg = msg .. ': ' .. err
    end
    return msg
  end
end

local messages = {
  no_projects         = 'No projects available',
  list_header         = 'Projects:\n─────────',
  project_header      = function(name)
    local pl = 'Project ' .. name .. ':'
    return pl .. '\n' .. string.times('─', string.ulen(pl))
  end,
  file_header         = function(name, width)
    local w = width or 64
    local l = string.ulen(name) + 2
    local pad = string.times('─', math.floor((w - l) / 2))
    return string.format('%s %s %s', pad, name, pad)
  end,

  invalid_filename    = error_annot('Filename invalid'),
  already_exists      = 'A project already exists with this name',
  write_error         = error_annot('Cannot write target directory'),
  pr_does_not_exist   = function(name)
    return name .. ' is not an existing project'
  end,
  file_does_not_exist = function(name)
    return name .. ' does not exist'
  end,
  no_open_project     = 'No project is open',
}

local MAIN = 'main.lua'

--- Determine if the supplied string is a valid filename
--- @param name string
--- @return boolean valid
--- @return string? error
local function validate_filename(name)
  if not string.is_non_empty_string(name) then
    return false, messages.invalid_filename('Empty')
  end
  if string.ulen(name) > 60 then
    return false, messages.invalid_filename('Too long')
  end
  if name:match('%.%.')
      or name:match('/')
  then
    return false, messages.invalid_filename('Forbidden characters')
  end
  return true
end

--- @class Project
--- @field name string
--- @field path string
--- @field contents function
--- @field readfile function
--- @field writefile function
Project = {}

function Project:new(pname)
  local p = {
    name = pname,
    path = string.join_path(love.paths.project_path, pname)
  }
  setmetatable(p, self)
  self.__index = self

  return p
end

--- @return table
function Project:contents()
  return FS.dir(string.join_path(self.path))
end

--- @param name string
--- @return boolean success
--- @return table|string result|errmsg
function Project:readfile(name)
  local fp = string.join_path(self.path, name)

  local ex = FS.exists(fp)
  if not ex then
    return false, messages.file_does_not_exist(name)
  else
    return true, FS.lines(fp)
  end
end

--- @param name string
--- @param data string
--- @return boolean success
--- @return string? error
function Project:writefile(name, data)
  local valid, err = validate_filename(name)
  if not valid then
    return false, err
  end
  local fp = string.join_path(self.path, name)
  return FS.write(fp, data)
end

--- @class ProjectService
--- @field path string
--- @field messages table
--- @field validate_filename function
--- @field current Project
--- @field create function
--- @field list function
--- @field open function
--- @field close function
--- @field deploy_examples function
--- @field run function
ProjectService = {}


--- @return ProjectService
function ProjectService:new(M)
  ProjectService.path = love.paths.project_path
  ProjectService.messages = messages
  local pc = {
    --- @type Project?
    current = nil
  }
  setmetatable(pc, self)
  self.__index = self

  return pc
end

--- @param name string
--- @return string? path
--- @return string? error
local function is_project(path, name)
  local p_path = string.join_path(path, name)
  if not FS.exists(p_path) then
    return nil, messages.pr_does_not_exist(name)
  end
  local main = string.join_path(p_path, MAIN)
  if not FS.exists(main) then
    return nil, messages.pr_does_not_exist(name)
  end
  return p_path
end

--- @param name string
--- @return string? path
--- @return string? error
local function can_be_project(path, name)
  local ok, n_err = validate_filename(name)
  if not ok then
    return nil, n_err
  end
  local p_path = string.join_path(path, name)
  if FS.exists(p_path) then
    return nil, messages.already_exists(name)
  end
  return p_path
end

--- @param name string
--- @return boolean success
--- @return string? error
function ProjectService:create(name)
  local p_path, err = can_be_project(ProjectService.path, name)
  if not p_path then
    return false, err
  end

  local dir_ok = FS.mkdir(p_path)
  if not dir_ok then
    return false, messages.write_error()
  end
  local main = string.join_path(p_path, MAIN)
  local example = [[
print('Hello world!')
]]
  local ok, write_err = FS.write(main, example)
  if not ok then
    return false, write_err
  end
  return true
end

--- @return table projects
function ProjectService:list()
  local folders = FS.dir(self.path)
  local ret = Dequeue:new()
  for _, f in pairs(folders) do
    if f.type and f.type == 'directory' then
      local ok = is_project(ProjectService.path, f.name)
      if ok then
        ret:push_back(Project:new(f.name))
      end
    end
  end
  return ret
end

--- @return boolean success
--- @return string? errmsg
function ProjectService:open(name)
  local ok, p_err = is_project(self.path, name)
  -- TODO: noop if already open
  if ok then
    self.current = Project:new(name)
    return true
  end
  return false, p_err
end

function ProjectService:opreate(name)
  local ook, _ = self:open(name)
  if ook then
    return ook, false
  else
    local cok, c_err = self:create(name)
    if cok then
      return false, cok
    else
      return false, c_err
    end
  end
end

--- @return boolean success
function ProjectService:close()
  self.current = nil
  return true
end

--- @return boolean success
--- @return string? error
function ProjectService:deploy_examples()
  local cp_ok = true
  local cp_err
  local ex_base = 'examples'
  local examples = FS.dir(ex_base, 'directory', true)
  if #examples == 0 then
    return false, 'No examples'
  end
  for _, i in ipairs(examples) do
    if i and i.type == 'directory' then
      local s_path = string.join_path(ex_base, i.name)
      local t_path = string.join_path(ProjectService.path, i.name)
      Log('INFO: copying example' .. i.name .. ' to ' .. t_path)
      local ok, err = FS.cp_r(s_path, t_path, true)
      if not ok then
        cp_ok = false
        cp_err = err
      end
    end
  end

  return cp_ok, cp_err
end

--- @param name string
--- @param env table
--- @return function?
--- @return string? error
--- @return string? path
function ProjectService:run(name, env)
  local p_path, err
  if not name then
    if self.current then
      p_path = self.current.path
      nativefs.setWorkingDirectory(p_path)
    else
      return nil, messages.no_open_project
    end
  else
    p_path, err = is_project(ProjectService.path, name)
  end
  if p_path then
    local main = string.join_path(p_path, MAIN)
    return loadfile(main, 't', env), nil, p_path
  end
  return nil, err
end
