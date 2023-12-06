--- @param k string
--- @return boolean
local function is_enter(k)
  return k == "return" or k == 'kpenter'
end

--- @return boolean
local function shift()
  return love.keyboard.isDown("lshift", "rshift")
end

--- @return boolean
local function ctrl()
  return love.keyboard.isDown("lctrl", "rctrl")
end

Key = {
  is_enter = is_enter,
  shift    = shift,
  ctrl     = ctrl,
}
