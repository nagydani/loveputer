local require = _G.o_require or _G.require

--- Require `name`.lua if exists
--- @param name string
local function prequire(name)
  local ok, module = pcall(function()
    return require(name)
  end)
  if ok then return module end
end

--- @param code string
--- @param env table?
--- @return function? chunk
local codeload = function(code, env)
  local f = loadstring(code)
  if not f then return end
  if env then
    setfenv(f, env)
  end
  return f
end

local t = {
  prequire = prequire,
  error_test = function()
    if love and love.DEBUG then
      error('error injection test')
    end
  end,
  codeload = codeload,
}

for k, v in pairs(t) do
  _G[k] = v
end
