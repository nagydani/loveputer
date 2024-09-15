--- Require `name`.lua if exists
--- @param name string
local function prequire(name)
  local ok, module = pcall(function()
    return require(name)
  end)
  if ok then return module end
end

local t = {
  prequire = prequire,
}

for k, v in pairs(t) do
  _G[k] = v
end
