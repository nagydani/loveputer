require('util.dequeue')

--- @param t love
local function mock_love(t)
  _G.love = t
  _G.TESTING = Dequeue()
end

return {
  mock_love = mock_love
}
