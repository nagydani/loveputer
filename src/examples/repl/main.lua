r = {}

function love.update()
  if not r[1] then
    input_text(r)
  else
    print(r[1])
    r[1] = nil
  end
end
