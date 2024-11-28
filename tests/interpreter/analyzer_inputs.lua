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
  --[[
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
  prep({
    'tmp = {}',
    'tmp[1] = 2',
  }, {
    { name = 'tmp', line = 1, }
  }),
  ]]
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

local sierpinski = [[function sierpinski(depth)
  lines = { '*' }
  for i = 2, depth + 1 do
    sp = string.rep(' ', 2 ^ (i - 2))
    tmp = {} -- comment
    for idx, line in ipairs(lines) do
      tmp[idx] = sp .. line .. sp
      tmp[idx + #lines] = line .. ' ' .. line
    end
    lines = tmp
  end
  return table.concat(lines, '\n')
end

print(sierpinski(4))]]

local clock = {
  'love.draw = function()',
  '  draw()',
  'end',
  '',
  'function love.update(dt)',
  '  t = t + dt',
  '  s = math.floor(t)',
  '  if s > midnight then s = 0 end',
  'end',
  '',
  'function cycle(c)',
  '  if c > 7 then return 1 end',
  '  return c + 1',
  'end',
  '',
  'love.keyreleased = function (k)',
  '  if k == \'space\' then',
  '    if love.keyboard.isDown("lshift", "rshift") then',
  '      bg_color = cycle(bg_color)',
  '    else',
  '      color = cycle(color)',
  '    end',
  '  end',
  '  if k == \'s\' then',
  '    stop(\'STOP THE CLOCKS!\')',
  '  end',
  'end' }

local meta =
[[
--- @param node token
--- @return table
function M:extract_comments(node)
   local lfi = node.lineinfo.first
   local lla = node.lineinfo.last
   local comments = {}

   --- @param c table
   --- @param pos 'first'|'last'
   local function add_comment(c, pos)
      local idf = c.lineinfo.first.id
      local idl = c.lineinfo.last.id
      local present = self.comment_ids[idf] or self.comment_ids[idl]
      if not present then
         local comment_text    = c[1]
         local len             = string.len(comment_text)
         local n_l             = #(string.lines(comment_text))
         local cfi             = c.lineinfo.first
         local cla             = c.lineinfo.last
         local cfirst          = { l = cfi.line, c = cfi.column }
         local clast           = { l = cla.line, c = cla.column }
         local off             = cla.offset - cfi.offset
         local d               = off - len
         local l_d             = cla.line - cfi.line
         local newline         = (n_l ~= 0 and n_l == l_d)
         local li              = {
            idf = idf,
            idl = idl,
            first = cfirst,
            last = clast,
            text = comment_text,
            multiline = (d > 4),
            position = pos,
            prepend_newline = newline
         }
         self.comment_ids[idf] = true
         self.comment_ids[idl] = true
         table.insert(comments, li)
      end
   end
   if lfi.comments then
      for _, c in ipairs(lfi.comments) do
         add_comment(c, 'first')
      end
   end
   if lla.comments then
      for _, c in ipairs(lla.comments) do
         add_comment(c, 'last')
      end
   end

   return comments
end
]]

local full = {
  prep(sierpinski, {
    { name = 'sierpinski', line = 1, },
    { name = 'lines',      line = 2, },
    { name = 'sp',         line = 4, },
    { name = 'tmp',        line = 5, },
    { name = 'lines',      line = 10, },
  }),
  prep(clock, {
    { name = 'love.draw',        line = 1, },
    { name = 'love.update',      line = 5, },
    { name = 't',                line = 6, },
    { name = 's',                line = 7, },
    { name = 's',                line = 8, },
    { name = 'cycle',            line = 11, },
    { name = 'love.keyreleased', line = 16, },
    { name = 'bg_color',         line = 19, },
    { name = 'color',            line = 21, },
  }),
  prep(meta, {
    { name = 'M:extract_comments', line = 3, },
    { name = 'lfi',                line = 4, },
    { name = 'lla',                line = 5, },
    { name = 'comments',           line = 6, },
    { name = 'add_comment',        line = 10, },
    { name = 'idf',                line = 11, },
    { name = 'idl',                line = 12, },
    { name = 'present',            line = 13, },
    { name = 'comment_text',       line = 15, },
    { name = 'len',                line = 16, },
    { name = 'n_l',                line = 17, },
    { name = 'cfi',                line = 18, },
    { name = 'cla',                line = 19, },
    { name = 'cfirst',             line = 20, },
    -- { name = 'l',                  line = 20, },
    -- { name = 'c',                  line = 20, },
    { name = 'clast',              line = 21, },
    -- { name = 'l',                  line = 21, },
    -- { name = 'c',                  line = 21, },
    { name = 'off',                line = 22, },
    { name = 'd',                  line = 23, },
    { name = 'l_d',                line = 24, },
    { name = 'newline',            line = 25, },
    { name = 'li',                 line = 26, },
    -- { name = 'idf',                line = 27, },
    -- { name = 'idl',                line = 28, },
    -- { name = 'first',              line = 29, },
    -- { name = 'last',               line = 30, },
    -- { name = 'text',               line = 31, },
    -- { name = 'multiline',          line = 32, },
    -- { name = 'position',           line = 33, },
    -- { name = 'prepend_newline',    line = 34, },
  }),
}

return {
  { 'simple', simple },
  { 'full',   full },
}
