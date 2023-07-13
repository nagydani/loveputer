function love.conf(t)
  t.window.title = 'LÖVEputer'
  t.window.resizable = false
  local hidpi = os.getenv("HIDPI")
  if os.getenv("DEBUG") then
    love.DEBUG = true
  end
  if hidpi == 'true' or hidpi == 'TRUE' then
    t.window.width = 800 * 2
    t.window.height = 480 * 2
    love.hiDPI = true
  else
    t.window.width = 800
    t.window.height = 480
  end
end
