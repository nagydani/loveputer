require("util.string")
require("util.filesystem")


local function error_annot(base)
  return function(err)
    local msg = base
    if err then
      msg = msg .. ' :' .. err
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

  invalid_filenae     = error_annot('Filename invalid'),
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
--- @return table
function Project:readfile(name)
  local fp = string.join_path(self.path, name)
  return FS.lines(fp)
end

function Project:writefile(name, data)
  local fp = string.join_path(self.path, name)
  return FS.write(fp, data)
end

--- Validate if the path contains a valid project under the supplied name
--- @param path string
--- @param name string
--- @return boolean
--- @return string path
Project.isValid = function(path, name)
  local p_path = string.join_path(path, name)
  local ok = FS.exists(string.join_path(p_path, 'main.lua'))
  return ok, messages.pr_does_not_exist(name)
end


ProjectService = {}

--- Determine if the supplied string is a valid filename
--- @param name string
--- @return boolean
local function validate_filename(name)
  if not string.is_non_empty_string(name) then
    return false
  end
  if not (string.ulen(name) < 64) then
    return false
  end
  -- TODO
  return true
end


--- @return ProjectService
function ProjectService:new(M)
  ProjectService.path = love.paths.project_path
  ProjectService.validate_filename = validate_filename
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
--- @return boolean success
--- @return string  path
local function isProject(path, name)
  local p_path = string.join_path(path, name)
  if not FS.exists(p_path) then
    return false, p_path
  end
  local main = string.join_path(p_path, 'main.lua')
  if not FS.exists(main) then
    return false, p_path
  end
  return true, p_path
end

--- @param name string
--- @return boolean success
--- @return string? error
function ProjectService:create(name)
  if not ProjectService.validate_filename(name) then
    return false, messages.invalid_filename()
  end
  local exists, p_path = isProject(self.path, name)
  if exists then
    return false, messages.already_exists
  end

  local dir_ok = FS.mkdir(p_path)
  if not dir_ok then
    return false, messages.write_error()
  end
  local main = string.join_path(p_path, 'main.lua')
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
  for n, f in pairs(folders) do
    if f.type and f.type == 'directory' then
      local ok = isProject(self.path, n)
      if ok then
        ret:push_back(Project:new(n))
      end
    end
  end
  return ret
end

--- @return boolean success
--- @return string? errmsg
function ProjectService:open(name)
  local ok, p_err = Project.isValid(self.path, name)
  if ok then
    self.current = Project:new(name)
    return true
  end
  return false, p_err
end

--- @return boolean success
function ProjectService:close()
  self.current = nil
  return true
end

--- @return boolean success
function ProjectService:deploy_example()
  return true
end
