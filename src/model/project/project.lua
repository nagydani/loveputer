local messages = {
  no_projects = 'No projects available',
  list_header = 'Projects:\n─────────',
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

function ProjectService:new(M)
  local pc = {
    path = love.paths.project_path,
    messages = messages,
  }
  setmetatable(pc, self)
  self.__index = self

  return pc
end

---@param name string
---@return boolean success
function ProjectService:create(name)
  -- check if it exists already
  return true
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
