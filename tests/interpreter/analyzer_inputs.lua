--- @param s str
--- @param canonized str?
--- @return table {string[], string[]}
local prep = function(s, canonized)
  local orig = (function()
    if type(s) == 'string' then
      return string.lines(s)
    elseif type(s) == 'table' then
      local ret = {}
      for i, v in ipairs(s) do
        ret[i] = v
      end
      return ret
    end
  end)()
  local canon = canonized and string.lines(canonized) or orig

  return { orig, canon }
end

local simple = {
  prep('x = 2'),
  prep({
    'function love.draw()',
    '  draw()',
    'end',
  }),
}

return {
  { 'simple', simple }
}
