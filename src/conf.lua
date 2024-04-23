function love.conf(t)
  t.identity = 'loveputer'
  t.window.title = 'LÖVEputer'
  t.window.resizable = false
  local hidpi = os.getenv("HIDPI")
  if os.getenv("DEBUG") then
    love.DEBUG = true
  end

  local width = 1024
  local height = 600
  if hidpi == 'true' or hidpi == 'TRUE' then
    t.window.width = width * 2
    t.window.height = height * 2
    love.hiDPI = true
  else
    t.window.width = width
    t.window.height = height
  end
  love.fixHeight = t.window.height
  love.fixWidth = t.window.width
  love.test_grid_x = 4
  love.test_grid_y = 4

  -- Android: use SD card for storage
  t.externalstorage = true

  require('host').spec(t)
end
