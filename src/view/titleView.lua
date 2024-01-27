TitleView = {
  draw = function(title, x, y, w, custom_font)
    title = title or "LÖVEputer"
    local prev_font = G.getFont()
    local font = custom_font or prev_font
    local fh = font:getHeight()
    x = x or 0
    y = y or G.getHeight() - 2 * fh
    w = w or G.getWidth()
    G.setColor(Color[0])
    G.rectangle("fill", x, y, w, fh)
    local i = 1
    local c = { 13, 12, 14, 10 }
    for lx = w - fh, w - 4 * fh, -fh do
      G.setColor(Color[c[i]])
      i = i + 1
      G.polygon("fill",
        lx,
        y,
        lx - fh,
        y,
        lx - 2 * fh,
        y + fh,
        lx - fh,
        y + fh)
    end
    G.setColor(Color[15])

    if custom_font then
      G.setFont(font)
    end
    G.print(title, x + fh, y)
    if custom_font then
      G.setFont(prev_font)
    end
  end
}
