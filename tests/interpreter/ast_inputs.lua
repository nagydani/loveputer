require("util.string")

--- @param s string|string[]
--- @param canonized string|string[]?
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

local sierpinski_res = {
  'sierpinski = function(depth)',
  -- --- [[ ]] version
  -- '  lines = { [[*]] }',
  '  lines = { "*" }',

  '  for i = 2, depth + 1 do',
  -- --- [[ ]] version
  -- '    sp = string.rep([[ ]], 2 ^ (i - 2))',
  '    sp = string.rep(" ", 2 ^ (i - 2))',

  '    tmp = { }',
  '    -- comment',
  '    for idx, line in ipairs(lines) do',
  '      tmp.idx = sp .. (line .. sp)',
  -- --- [[ ]] version
  -- '      tmp.add = line .. ([[ ]] .. line)',
  '      tmp.add = line .. (" " .. line)',

  '    end',
  '    lines = tmp',
  '  end',
  -- --- [[ ]] version
  -- '  return table.concat(lines, [[',
  -- ']])',
  -- ---  '' version
  -- "  return table.concat(lines, '\\n')",
  ---  "" version
  '  return table.concat(lines, "\\n")',
  'end',
  '',
  'print(sierpinski(4))',
}

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
local meta_res = {
  '--- @param node token',
  '--- @return table',
  -- 'function M:extract_comments(node)',
  'M.extract_comments = function(self, node)',
  '  local lfi = node.lineinfo.first',
  '  local lla = node.lineinfo.last',
  '  local comments = { }',
  -- '',
  '  --- @param c table',
  "  --- @param pos 'first'|'last'",
  '  local function add_comment(c, pos)',
  '    local idf = c.lineinfo.first.id',
  '    local idl = c.lineinfo.last.id',
  --- rewrites t[i] to t.i
  '    local present = self.comment_ids.idf or self.comment_ids.idl',
  '    if not present then',
  '      local comment_text = c[1]',
  '      local len = string.len(comment_text)',
  '      local n_l = # (string.lines(comment_text))',
  '      local cfi = c.lineinfo.first',
  '      local cla = c.lineinfo.last',
  --- splits tables
  '      local cfirst = {',
  '        l = cfi.line,',
  '        c = cfi.column',
  '      }',
  '      local clast = {',
  '        l = cla.line,',
  '        c = cla.column',
  '      }',
  '      local off = cla.offset - cfi.offset',
  '      local d = off - len',
  '      local l_d = cla.line - cfi.line',
  --- normalizes logic conditions
  '      local newline = (not (n_l == 0) and n_l == l_d)',
  '      local li = {',
  '        idf = idf,',
  '        idl = idl,',
  '        first = cfirst,',
  '        last = clast,',
  '        text = comment_text,',
  '        multiline = (4 < d),',
  '        position = pos,',
  '        prepend_newline = newline',
  '      }',
  '      self.comment_ids.idf = true',
  '      self.comment_ids.idl = true',
  '      table.insert(comments, li)',
  '    end',
  '  end',
  '  if lfi.comments then',
  '    for _, c in ipairs(lfi.comments) do',
  '      add_comment(c, "first")',
  '    end',
  '  end',
  '  if lla.comments then',
  '    for _, c in ipairs(lla.comments) do',
  '      add_comment(c, "last")',
  '    end',
  '  end',
  -- '',
  '  return comments',
  'end',
}

return {
  ------------------
  ---  canonize  ---
  ------------------
  prep('if a > b then     return a else return b end', {
    'if b < a then',
    '  return a',
    'else',
    '  return b',
    'end' }
  ),
  prep('local str = "asd"'),
  prep("local str = 'asd'", { 'local str = "asd"' }),
  --- operators
  prep('if not (a == b) then end',
    {
      'if a ~= b then',
      '  ',
      'end'
    }),
  -----------------
  --- splitting ---
  -----------------
  prep('local t = { b = 2, 3, 4 }', {
    'local t = {',
    '  b = 2,',
    '  3,',
    '  4',
    '}' }),
  prep('a = 1 ; b = 2', { 'a = 1', 'b = 2' }),

  -----------------
  --- comments  ---
  -----------------
  prep({
    'y = 10',
    '--- comment',
    'z = 99'
  }),

  prep({
    'y = 10',
    '--- comment1',
    '--- comment2',
    '--- comment3',
    'z = 99'
  }),

  prep({
    'x = 0',
    '-- comment1',
    '-- comment2',
    '-- comment3',
    'a = 1'
  }),

  prep({
    'x = 1',
    '--[[ comment1',
    ' comment2',
    ' comment3]]',
    'a = 3'
  }),

  prep({
    'x = 0',
    '--[[ comment1',
    ' comment2]]--',
    'a = 2',
  }, {
    'x = 0',
    '--[[ comment1',
    ' comment2]]',
    '--', --- this is canonical now, no following `--` after `]]`
    'a = 2',
  }),

  prep({
    'x = 0',
    '--[[ comment1',
    ' comment2]]',
    'a = 2',
  }, {
    'x = 0',
    '--[[ comment1',
    ' comment2]]',
    'a = 2',
  }),

  prep({
    'x = 0',
    '-- comment1',
    '-- comment2',
    'a = 2',
  }),

  prep([[-- comment]]),
  prep({ '-- interesting comment', 'a = 1' }),
  prep({
    '-- comment1',
    '-- comment2'
  }),

  prep({
    '--[[ comment1',
    ' comment2--]]',
    'a = 2',
    '-- asd', -- canonical space after comment marker
    '--[[]]',
  }),
  prep({ '--[[]]', 'a = 1' }),
  prep({ 'a = 1', '--[[]]' }),
  prep({
    '-- comment1',
    '-- comment2',
    'a = 1'
  }),
  prep({
    'local head_r = 8',
    'local leg_r = 5',
    '-- move offsets',
    'local x_r = 15',
    'local y_r = 20',
  }),
  prep({
    'y = 3',
    '--[[',
    'multi-',
    'line',
    'comment]]',
  }),
  prep({ '--[[',
    'multi-',
    'line',
    'comment]]',
  }),
  prep({ '--[[multi-',
    'line',
    'comment',
    ']]',
  }),
  prep({ '--[[multi-',
    'line',
    'comment]]',
  }),
  prep({
    '--[[ comment1',
    ' comment2]]--',
    'a = 2',
    '--asd',
    '--[[]]',
  }, {
    '--[[ comment1',
    ' comment2]]',
    '--',     --- this is canonical now, no following `--` after `]]`
    'a = 2',
    '-- asd', -- canonical space after comment marker
    '--[[]]',
  }),
  prep({
      'local x = 2',
      '--[[',
      'multi-',
      'line',
      'comment]]--',
    },
    {
      'local x = 2',
      '--[[',
      'multi-',
      'line',
      'comment]]',
      '--', --- this is canonical now, no following `--` after `]]`
    }
  ),

  -----------------
  --- multliine ---
  -----------------
  prep({
    'local s = [[asd',
    'string',
    ']]',
  }, { [[local s = "asd\nstring\n"]] }),
  prep({
    'local s = [[asd',
    'string',
    '',
    '',
    ']]',
  }, { [[local s = "asd\nstring\n\n\n"]] }),

  prep({
      'local ms=  [[█Bacon ipsum dolor amet ribeye hamburger',
      'c█hislic pork short ribs',
      'po█rchetta. Pork loin meatball ball tip',
      'por█k chop pork capicola fatback andouille beef sausage short',
      'loin█ bresaola venison.\\t]]',
    },
    -- --- [[ ]] version
    -- {
    --   'local ms = [[█Bacon ipsum dolor amet ribeye hamburger',
    --   'c█hislic pork short ribs',
    --   'po█rchetta. Pork loin meatball ball tip',Debug.text(comment_text)
    -- }
    --- " " version
    {
      'local ms = ',
      [[  "█Bacon ipsum dolor amet ribeye hamburger\n" ..]],
      [[  "c█hislic pork short ribs\n" ..]],
      [[  "po█rchetta. Pork loin meatball ball tip\n" ..]],
      [[  "por█k chop pork capicola fatback andouille beef sausage s" ..]],
      [[  "hort\n" ..]],
      [[  "loin█ bresaola venison.\t"]],
    }
  ),
  prep({
      'local str = "asd\\nbgf"',
      'local mstr = [[rty',
      'qwe]]',
      'local ms = [[ms]]',
      'local m_s = [[m\ns]]',
    },
    -- --- [[ ]] version
    -- {
    --   'local str = [[asd',
    --   'bgf]]',
    --   'local mstr = [[rty',
    --   'qwe]]',
    --   'local ms = "ms"',
    -- }
    --- " " version
    {
      [[local str = "asd\nbgf"]],
      [[local mstr = "rty\nqwe"]],
      'local ms = "ms"',
      [[local m_s = "m\ns"]],
    }
  ),
  -----------------
  ---  wrapping ---
  -----------------
  prep(
    'local long_string = "яяяяяяяяяяяяяяяяяяя22222222222222222eeeeeeeeeeeeeeeeeee6666666666666666666666666sssssssssss"',
    {
      'local long_string = ',
      '  "яяяяяяяяяяяяяяяяяяя22222222222222222eeeeeeeeeeeeeeeeeee66" ..',
      '  "66666666666666666666666sssssssssss"',
    }),
  prep(
    '-- яяяяяяяяяяяяяяяяяяя22222222222222222eeeeeeeeeeeeeeeeeee6666666666666666666666666sssssssssss',
    {
      '-- яяяяяяяяяяяяяяяяяяя22222222222222222eeeeeeeeeeeeeeeeeee66666',
      '-- 66666666666666666666sssssssssss',
    }),
  prep(
    {
      '--[[Bacon ipsum dolor amet sint meatball pork loin, shankle kiel',
      'basa nulla mollit quis elit dolore tenderloin swine.',
      'Elit beef pancetta, lorem sirloin spare ribs tenderloin exercitation laborum tongue eiusmod dolor fatback.',
      'In ut dolore corned beef flank eiusmod, burgdoggen capicola ham enim culpa hamburger chuck. Beef burgdoggen qui meatloaf cupidatat sunt. Lorem spare ribs dolor mollit porchetta. Nostrud pig shoulder beef veniam shank pork loin landjaeger chuck ball tip.',
      'Tri-tip elit culpa deserunt.]]' },
    {
      '--[[Bacon ipsum dolor amet sint meatball pork loin, shankle kiel',
      'basa nulla mollit quis elit dolore tenderloin swine.',
      'Elit beef pancetta, lorem sirloin spare ribs tenderloin exercita',
      'tion laborum tongue eiusmod dolor fatback.',
      'In ut dolore corned beef flank eiusmod, burgdoggen capicola ham ',
      'enim culpa hamburger chuck. Beef burgdoggen qui meatloaf cupidat',
      'at sunt. Lorem spare ribs dolor mollit porchetta. Nostrud pig sh',
      'oulder beef veniam shank pork loin landjaeger chuck ball tip.',
      'Tri-tip elit culpa deserunt.]]',
    }),
  prep({
      '-- яяяяяяяяяяяяяяяяяяя22222222222222222eeeeeeeeeeeeeeeeeee6666666666666666666666666sssssssssss',
      '-- цэфлаэфцжфдэжафдукзщфкхз2щ3х54з2ьахажщд2хфладжьяхадыхжахдхыжхахдыалджлождлод' },
    {
      '-- яяяяяяяяяяяяяяяяяяя22222222222222222eeeeeeeeeeeeeeeeeee66666',
      '-- 66666666666666666666sssssssssss',
      '-- цэфлаэфцжфдэжафдукзщфкхз2щ3х54з2ьахажщд2хфладжьяхадыхжахдхыж',
      '-- хахдыалджлождлод',
    }),
  -----------------
  --- functions ---
  -----------------
  prep(meta, meta_res),
  prep(sierpinski, sierpinski_res),
  prep(
    {
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
      'function love.keyreleased(k)',
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
      'end' }, {
      -- functions are values
      'love.draw = function()',
      '  draw()',
      'end',
      '',
      -- functions are values
      'love.update = function(dt)',
      '  t = t + dt',
      '  s = math.floor(t)',
      -- canonized compare order
      '  if midnight < s then',
      '    s = 0',
      '  end',
      'end',
      '',
      -- functions are values
      'cycle = function(c)',
      -- canonized compare order
      '  if 7 < c then',
      '    return 1',
      '  end',
      '  return c + 1',
      'end',
      '',
      -- functions are values
      'love.keyreleased = function(k)',
      '  if k == "space" then',
      '    if love.keyboard.isDown("lshift", "rshift") then',
      '      bg_color = cycle(bg_color)',
      '    else',
      '      color = cycle(color)',
      '    end',
      '  end',
      '  if k == "s" then',
      '    stop("STOP THE CLOCKS!")',
      '  end',
      'end',
    }),

}
