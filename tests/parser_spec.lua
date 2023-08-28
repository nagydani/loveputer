require("util/color")
local parser = require("model/parser")('metalua')
local tokenHL = require("model/tokenHighlighter")

require("util/debug")
local term = require("util/termcolor")

if not orig_print then
  _G.orig_print = print
end

local inputs = {
  {
    compiles = false,
    code = { 'úő' }
  },
  {
    compiles = true,
    code = { 'local s = "úő"' }
  },
  { compiles = false, code = { 'local' } },
  { compiles = true,  code = { 'local a' } },
  { compiles = true,  code = { 'local x = 1', } },
  { compiles = false, code = { 'local 1' } },
  { compiles = true,  code = { 'a = 1' } },
  { compiles = true,  code = { 'a = 1, 2' } },
  { compiles = true,  code = { 'a, b = 1, 2' } },
  { compiles = true,  code = { 'a.b = 1' } },
  { compiles = true,  code = { 'a.b.c = 1' } },
  { compiles = true,  code = { 'a[b] = 1' } },
  { compiles = true,  code = { 'a[b][c] = 1' } },
  { compiles = true,  code = { 'a.b[c] = 1' } },
  { compiles = true,  code = { 'a[b].c = 1' } },
  { compiles = false, code = { '0 =' } },
  { compiles = false, code = { '"x" =' } },
  { compiles = false, code = { 'true =' } },
  { compiles = false, code = { '(a) =' } },
  { compiles = false, code = { 'a = 1 2' } },
  { compiles = false, code = { 'a = b = 2' } },

  { compiles = true,  code = { '(1)()' } },
  { compiles = true,  code = { '("foo")()' } },
  { compiles = true,  code = { '(a)()()' } },
  { compiles = true,  code = { 'a"foo"' } },
  { compiles = true,  code = { 'a[[foo]]' } },

  { compiles = true,  code = { 'do end' } },
  { compiles = false, code = { 'do do end' } },
  { compiles = false, code = { 'do end do' } },

  { compiles = false, code = { 'while 1 do 2 end' } },
  { compiles = false, code = { 'while 1 end' } },
  { compiles = false, code = { 'repeat until' } },
  { compiles = true,  code = { 'repeat until 0' } },

  { compiles = true,  code = { 'for i=1, 5 do print(i) end' } },
  { compiles = false, code = { 'for' } },
  { compiles = false, code = { 'for do' } },
  { compiles = false, code = { 'for end' } },
  { compiles = false, code = { 'for 1' } },
  { compiles = true,  code = { 'for a in b do end' } },
  { compiles = false, code = { 'for a b in' } },
  { compiles = false, code = { 'for a =' } },
  { compiles = false, code = { 'for a, b =' } },
  { compiles = false, code = { 'for a = 1, 2, 3, 4 do end' } },
  { compiles = true,  code = { 'for a = 1, 2 do end' } },
  {
    compiles = true,
    code = {
      'for i=1,5 do',
      '  print(i)',
      'end',
    }
  },
  {
    compiles = false,
    code = {
      'for i=1,5',
      '  print(i)',
      'end',
    }
  },
  {
    compiles = false,
    code = {
      'for i=1,5 then',
      '  print(i)',
      'end',
    }
  },
  {
    compiles = false,
    code = {
      'for i=1,5 do',
      '  print(i)',
    }
  },

  { compiles = false, code = { 'return return' } },
  -- { compiles = false, code = { 'return 1,' } },
  { compiles = true,  code = { 'return 1' } },

  { compiles = false, code = { 'if' } },
  { compiles = false, code = { 'elseif' } },
  { compiles = false, code = { 'then' } },
  { compiles = false, code = { 'if then' } },
  { compiles = true,  code = { 'if 1 then end' } },
  { compiles = true,  code = { 'if 1 then return end' } },
  { compiles = true,  code = { 'if 1 then else end' } },
  { compiles = true,  code = { 'if 1 then elseif 2 then end' } },

  { compiles = false, code = { 'function' } },
  { compiles = false, code = { 'function end' } },
  { compiles = false, code = { 'function f end' } },
  { compiles = false, code = { 'function f( end' } },
  { compiles = true,  code = { 'function f() end' } },
  { compiles = true,  code = { 'function f(p) end' } },
  -- { compiles = false, code = { 'function f(p,) end' } },
  { compiles = true,  code = { 'function a.f() end' } },
  { compiles = true,  code = { 'function a:f() end' } },
  { compiles = true,  code = { 'function f(...) end' } },
  { compiles = false, code = { 'function f(..., end' } },
  { compiles = true,  code = { 'function f(p, ...) end' } },
  -- tables
  { compiles = true,  code = { 'a = { a=1, b="foo", c=nil }' } },
  { compiles = true,  code = { 'a = {  }' } },
  { compiles = true,  code = { 'a = {{{}}}' } },
  { compiles = false, code = { 'a = {' } },
  { compiles = false, code = { 'a = {,}' } },
  { compiles = true,  code = { 'a = { ["foo"]="bar" }' } },
  { compiles = true,  code = { 'a = { [1]=a, [2]=b, }' } },
  { compiles = true,  code = { 'a = { true, a=1; ["foo"]="bar", }' } },
  -- comments
  {
    compiles = true,
    code = {
      '-- this loop is rad',
      'for i=1,5 do',
      '  print(i)',
      'end',
    }
  },
  {
    compiles = true,
    code = {
      '--- it foos the bar',
      '---@param bar table',
      'function foo(bar)',
      'end',
    }
  },
  {
    compiles = true,
    code = {
      'function foo()',
      '  -- TODO: foo the bar',
      'end',
    }
  },
  {
    compiles = true,
    code = {
      'for i=1,5 do',
      '  print(i)',
      'end -- done',
    }
  },
  {
    compiles = true,
    code = {
      "--[[ multiline",
      "comment",
      'あいうえお --]]',
    }
  },
  {
    compiles = true,
    code = {
      "--[[ multiline",
      "    =-=",
      "comment --]] -- another comment",
    }
  },
  {
    compiles = true,
    code = {
      "-- comment",
      "  --[[ multiline",
      " |-|",
      "comment --]]",
    }
  },
  {
    compiles = true,
    code = {
      "local a = 1 --[[ multiline",
      "comment --]] -- another comment",
      "a = 2",
    }
  },
  {
    compiles = true,
    code = {
      "local a",
      "  -- comment",
      "--[[ multiline",
      "comment --]]",
      "a = 2",
    }
  },
  {
    compiles = true,
    code = {
      "print('когда') --[[ function foo()",
      'end --]]',
    }
  },
  {
    compiles = false,
    code = {
      'for i=1,5 do --[[ inserting',
      '  a multiline comment',
      '  without closing',
      '  fp',
      'end',
    }
  },
  multiline string
{
  compiles = false,
  code = {
    'local ml = [[',
    '  multiline string',
    '  without closing',
  }
},
  {
    compiles = true,
    code = {
      'local ml = [[ multi',
      '  line',
      '  string',
      ']]',
    }
  },
  {
    compiles = true,
    code = {
      'local ml = [[ multiline',
      '  string',
      ']] -- comment',
    }
  },
}

local parser_debug = os.getenv("PARSER_DEBUG")
describe('parse #parser', function()
  -- print(Debug.print_t(parser))
  for i, input in ipairs(inputs) do
    local tag = 'input #' .. i
    it('parses ' .. tag, function()
      local ok, r = parser.parse(input.code)
      -- print(Debug.text_table(input.code, true))
      -- print(Debug.terse_t(r))
      if parser_debug then
        print(tag, string.join(input.code, '⏎ '))
        if not ok then
          local l, c, err = parser.get_error(r)
          local error = l .. ':' .. c .. ' | ' .. err
          if string.is_non_empty_string(err) then
            term.print_c(Color.red, error)
          end
        else
          local pp = parser.pprint(input.code)
          if string.is_non_empty_string(pp) then
            term.print_c(Color.green, pp)
          end
        end
      end
      assert.equals(ok, input.compiles)
    end)
  end
end)

local highlighter_debug = os.getenv("HL_DEBUG")
describe('highlight #parser', function()
  for i, input in ipairs(inputs) do
    local tag = 'input #' .. i
    it('parses ' .. tag, function()
      local tokens = parser.tokenize(input.code)
      local hl = parser.syntax_hl(tokens)
      -- print(Debug.text_table(input.code, true))
      if highlighter_debug then
        for l, line in ipairs(input.code) do
          local rowc = hl[l] or {}
          for j = 1, #line do
            local c = tokenHL.colorize(rowc[j])
            term.print_c(c, string.sub(line, j, j), true)
          end
          print()
        end
        print(term.reset)
      end
    end)
  end
end)
