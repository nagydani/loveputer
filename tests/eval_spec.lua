require("model/textEval")
require("model/luaEval")


describe('TextEval', function()
  local eval = TextEval:new()
  it('returns', function()
    local input = 'asd'

    assert.same(input, eval.apply(input))
  end)
  it('returns multiline', function()
    local input = { 'asd', 'qwer' }

    assert.same(input, eval.apply(input))
  end)

  it('returns multiline with empties', function()
    local input = { '', 'asd', 'qwer' }

    assert.same(input, eval.apply(input))
  end)
end)

-- hackery around disparate lua versions
if not unpack then
  _G.unpack = table.unpack
end

if not orig_print then
  _G.orig_print = print
end
------------------------------------------

local inputs = {
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
      'print(i)',
      'end',
    }
  },
  {
    compiles = false,
    code = {
      'for i=1,5',
      'print(i)',
      'end',
    }
  },
  {
    compiles = false,
    code = {
      'for i=1,5 then',
      'print(i)',
      'end',
    }
  },
  {
    compiles = false,
    code = {
      'for i=1,5 do',
      'print(i)',
    }
  },

  { compiles = false, code = { 'return return' } },
  { compiles = false, code = { 'return 1,' } },
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
  { compiles = false, code = { 'function f(p,) end' } },
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
}

describe('LuaEval', function()
  local eval = LuaEval:new()
  it('', function()
    for _, input in ipairs(inputs) do
      local ok, r = eval.apply(input.code)
      assert.equals(ok, input.compiles)
    end
  end)
end)
