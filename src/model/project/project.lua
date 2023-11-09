Project = {}

function Project:new()
  local p = {
  }
  setmetatable(p, self)
  self.__index = self

  return p
end

ProjectService = {}

function ProjectService:new(M)
  local pc = {
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
  return {}
end

---@return boolean success
function ProjectService:select()
  return true
end
