require("util.table")

local shift_k = { "lshift", "rshift" }
local ctrl_k  = { "lctrl", "rctrl" }
local alt_k   = { "lalt", "ralt" }

--- @param k string
--- @return boolean
local function is_enter(k)
  return k == "return" or k == 'kpenter'
end

--- @return boolean
local function is_shift(k)
  return table.is_member(shift_k, k)
end
--- @return boolean
local function shift()
  return love.keyboard.isDown("lshift", "rshift")
end

--- @return boolean
local function is_ctrl(k)
  return table.is_member(ctrl_k, k)
end
--- @return boolean
local function ctrl()
  return love.keyboard.isDown("lctrl", "rctrl")
end

--- @return boolean
local function is_alt(k)
  return table.is_member(alt_k, k)
end
--- @return boolean
local function alt()
  return love.keyboard.isDown("lalt", "ralt")
end

Key = {
  is_enter = is_enter,
  shift    = shift,
  is_shift = is_shift,
  ctrl     = ctrl,
  is_ctrl  = is_ctrl,
  alt      = alt,
  is_alt   = is_alt,
}
