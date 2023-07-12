TitleView = {
  draw = function(title, x, y, w, custom_font)
    title = title or "LÖVEputer"
    local prev_font = love.graphics.getFont()
    local font = custom_font or prev_font
    local fh = font:getHeight()
    x = x or 0
    y = y or love.graphics.getHeight() - 2 * fh
    w = w or love.graphics.getWidth()
    love.graphics.setColor(Color[0])
    love.graphics.rectangle("fill", x, y, w, fh)
    local i = 1
    local c = { 13, 12, 14, 10 }
    for lx = w - fh, w - 4 * fh, -fh do
      love.graphics.setColor(Color[c[i]])
      i = i + 1
      love.graphics.polygon("fill",
        lx,
        y,
        lx - fh,
        y,
        lx - 2 * fh,
        y + fh,
        lx - fh,
        y + fh)
    end
    love.graphics.setColor(Color[15])

    if custom_font then
      love.graphics.setFont(font)
    end
    love.graphics.print(title, x + fh, y)
    if custom_font then
      love.graphics.setFont(prev_font)
    end
  end
}
