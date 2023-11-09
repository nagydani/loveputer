local messages = {
  no_projects = 'No projects available',
  list_header = 'Projects:\n─────────',

  invalid_filenae = 'Filename invalid!',
  already_exists = 'A project already exists with this name',
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
---@return string? error
function ProjectService:create(name)
  if not self:validate_filename(name) then
    return false, messages.invalid_filenae
  end
  local p_path = string.format('%s/%s', self.path, name)
  if nativefs.getInfo(p_path, 'directory') then
    return false, messages.already_exists
  else
    return true
  end
end

---@return table projects
function ProjectService:list()
  local folders = nativefs.getDirectoryItemsInfo(self.path)
  local ret = Dequeue:new()
  for _, f in ipairs(folders) do
    if f.type and f.type == 'directory' then
      local p_path = string.format('%s/%s', self.path, f.name)
      local ok = false
      for k, v in pairs(nativefs.getDirectoryItemsInfo(p_path)) do
        Log(k, Debug.terse_t(v))
        if v.name == 'main.lua' then
          ok = true
        end
      end
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
