local messages = {
  no_projects     = 'No projects available',
  list_header     = 'Projects:\n─────────',

  invalid_filenae = 'Filename invalid!',
  already_exists  = 'A project already exists with this name!',
  write_error     = 'Cannot write target directory!',
}

Project = {}

function Project:new(name)
  local p = {
    name = name,
  }
  setmetatable(p, self)
  self.__index = self

  return p
end

ProjectService = {}


--- Determine if the supplied string is a valid filename
--- @return boolean
local function validate_filename(name)
  -- TODO
  return true
end

function ProjectService:new(M)
  local pc = {
    path = love.paths.project_path,
    messages = messages,
    validate_filename = validate_filename,
  }
  setmetatable(pc, self)
  self.__index = self

  return pc
end

---@param name string
---@return boolean success
---@return string  path
local function isProject(path, name)
  local p_path = string.format('%s/%s', path, name)
  local ok = false
  for _, v in pairs(nativefs.getDirectoryItemsInfo(p_path)) do
    if v.name == 'main.lua' then
      ok = true
    end
  end
  return ok, p_path
end

---@param name string
---@return boolean success
---@return string? error
function ProjectService:create(name)
  if not self:validate_filename(name) then
    return false, messages.invalid_filenae
  end
  local exists, p_path = isProject(self.path, name)
  if exists then
    return false, messages.already_exists
  end

  local dir_ok = nativefs.createDirectory(p_path)
  if not dir_ok then
    return false, messages.write_error
  end
  local main = string.format('%s/%s', p_path, 'main.lua')
  local example = [[
print('Hello world!')
]]
  local ok, write_err = nativefs.write(main, example)
  if not ok then
    return false, write_err
  end
  return true
end

---@return table projects
function ProjectService:list()
  local folders = nativefs.getDirectoryItemsInfo(self.path)
  local ret = Dequeue:new()
  for _, f in ipairs(folders) do
    if f.type and f.type == 'directory' then
      local ok = isProject(self.path, f.name)
      if ok then
        ret:push_back(Project:new(f.name))
      end
    end
  end
  return ret
end

---@return boolean success
function ProjectService:select()
  return true
end
