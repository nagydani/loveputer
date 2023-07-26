function love.conf(t)
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
end
