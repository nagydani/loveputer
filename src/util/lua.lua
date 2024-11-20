local require = _G.o_require or _G.require

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
  error_test = function()
    if love and love.DEBUG then
      error('error injection test')
    end
  end
}

for k, v in pairs(t) do
  _G[k] = v
end
