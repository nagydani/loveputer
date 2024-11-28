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
    { line = 1, name = 'x',  type = 'global', },
    { line = 2, name = 'y',  type = 'global', },
    { line = 3, name = 'x',  type = 'global', },
    { line = 4, name = 'w',  type = 'global', },
    { line = 4, name = 'ww', type = 'global', },
  }),
  prep({
    'local l = 1',
    'local x, y = 2, 3',
  }, {
    { line = 1, name = 'l', type = 'local', },
    { line = 2, name = 'x', type = 'local', },
    { line = 2, name = 'y', type = 'local', },
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
    { line = 1, name = 'drawBackground', type = 'function', },
  }),
  prep({
    'function love.draw()',
    '  draw()',
    'end',
  }, {
    { line = 1, name = 'love.draw', type = 'function', },
  }),
  prep({
    'function love.handlers.keypressed()',
    'end',
  }, {
    { line = 1, name = 'love.handlers.keypressed', type = 'function', },
  }),
  prep({
    'local function drawBody()',
    'end',
  }, {
    { name = 'drawBody', line = 1, type = 'function' }
  }),
  --- methods
  prep({
    'function M:draw()',
    'end',
  }, {
    { name = 'M:draw', line = 1, type = 'method' }
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
    { line = 1,  name = 'sierpinski', type = 'function', },
    { line = 2,  name = 'lines',      type = 'global', },
    { line = 4,  name = 'sp',         type = 'global', },
    { line = 5,  name = 'tmp',        type = 'global', },
    { line = 10, name = 'lines',      type = 'global', },
  }),
  prep(clock, {
    { line = 1,  name = 'love.draw',        type = 'function', },
    { line = 5,  name = 'love.update',      type = 'function', },
    { line = 6,  name = 't',                type = 'global', },
    { line = 7,  name = 's',                type = 'global', },
    { line = 8,  name = 's',                type = 'global', },
    { line = 11, name = 'cycle',            type = 'function', },
    { line = 16, name = 'love.keyreleased', type = 'function', },
    { line = 19, name = 'bg_color',         type = 'global', },
    { line = 21, name = 'color',            type = 'global', },
  }),
  prep(meta, {
    { line = 3,  name = 'M:extract_comments', type = 'method', },
    { line = 4,  name = 'lfi',                type = 'local', },
    { line = 5,  name = 'lla',                type = 'local', },
    { line = 6,  name = 'comments',           type = 'local', },
    { line = 10, name = 'add_comment',        type = 'function', },
    { line = 11, name = 'idf',                type = 'local', },
    { line = 12, name = 'idl',                type = 'local', },
    { line = 13, name = 'present',            type = 'local', },
    { line = 15, name = 'comment_text',       type = 'local', },
    { line = 16, name = 'len',                type = 'local', },
    { line = 17, name = 'n_l',                type = 'local', },
    { line = 18, name = 'cfi',                type = 'local', },
    { line = 19, name = 'cla',                type = 'local', },
    { line = 20, name = 'cfirst',             type = 'local', },
    { line = 21, name = 'clast',              type = 'local', },
    { line = 22, name = 'off',                type = 'local', },
    { line = 23, name = 'd',                  type = 'local', },
    { line = 24, name = 'l_d',                type = 'local', },
    { line = 25, name = 'newline',            type = 'local', },
    { line = 26, name = 'li',                 type = 'local', },
  }),
}

return {
  { 'simple', simple },
  { 'full',   full },
}
