--- @param s str
--- @param defs Assignment[]
--- @return table {string[], string[]}
local prep = function(s, defs)
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

  return { orig, defs }
end

local simple = {
  --- sets
  prep({
    'x = 2',
    'y = 3',
    'x = 3',
    'w, ww = 10, 11',
  }, {
    { name = 'x',  line = 1, },
    { name = 'y',  line = 2, },
    { name = 'x',  line = 3, },
    { name = 'w',  line = 4, },
    { name = 'ww', line = 4, },
  }),
  prep({
    'local l = 1',
    'local x, y = 2, 3',
  }, {
    { name = 'l', line = 1 },
    { name = 'x', line = 2, },
    { name = 'y', line = 2, },
  }),
  --- tables
  prep({
    'local t = {',
    ' ty = 3,',
    '}',
    't2 = {',
    ' w1 = 1,',
    ' w2 = 2,',
    '}',
    'a = {',
    ' 1,',
    ' z = 2,',
    ' 3,',
    '}',
  }, {
    { name = 't',  line = 1, },
    { name = 'ty', line = 2, },
    { name = 't2', line = 4, },
    { name = 'w1', line = 5, },
    { name = 'w2', line = 6, },
    { name = 'a',  line = 8, },
    { name = 'z',  line = 10, },
  }),
  --- functions
  prep({
    'function drawBackground()',
    'end',
  }, {
    { name = 'drawBackground', line = 1, }
  }),
  prep({
    'function love.draw()',
    '  draw()',
    'end',
  }, {
    { name = 'love.draw', line = 1, }
  }),
  prep({
    'function love.handlers.keypressed()',
    'end',
  }, {
    { name = 'love.handlers.keypressed', line = 1, }
  }),
  prep({
    'local function drawBody()',
    'end',
  }, {
    { name = 'drawBody', line = 1, }
  }),
  --- methods
  prep({
    'function M:draw()',
    'end',
  }, {
    { name = 'M:draw', line = 1, }
  }),
}

return {
  { 'simple', simple }
}
