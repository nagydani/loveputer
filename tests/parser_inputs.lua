require("model.input.cursor")


local function test_case(code, compiles, error_loc)
  return {
    code = code,
    compiles = compiles,
    error = error_loc
  }
end

local function valid(code)
  return test_case(code, true)
end
local function invalid(code, error)
  return test_case(code, false, error)
end

return {
  -- identifiers
  valid({ 'local s = "úő"' }),
  valid({ 'local a' }),
  valid({ 'local x = 1', }),
  valid({ 'a = 1' }),
  valid({ 'a = 1, 2' }),
  valid({ 'a, b = 1, 2' }),
  valid({ 'a.b = 1' }),
  valid({ 'a.b.c = 1' }),
  valid({ 'a[b] = 1' }),
  valid({ 'a[b][c] = 1' }),
  valid({ 'a[b].c = 1' }),
  valid({ 'a.b[c] = 1' }),
  valid({ '(1)()' }),
  valid({ '("foo")()' }),
  valid({ '(a)()()' }),
  valid({ 'a"foo"' }),
  valid({ 'a[[foo]]' }),
  valid({ 'do end' }),

  -- branching
  valid({ 'if 1 then end' }),
  valid({ 'if 1 then return end' }),
  valid({ 'if 1 then else end' }),
  valid({ 'if 1 then elseif 2 then end' }),

  -- loops
  valid({ 'repeat until 0' }),
  valid({ 'for i=1, 5 do print(i) end' }),
  valid({ 'for a in b do end' }),
  valid({ 'for a = 1, 2 do end' }),
  valid({
    'for i=1,5 do',
    '  print(i)',
    'end',
  }),

  -- function
  valid({ 'function f() end' }),
  valid({ 'function f(p) end' }),
  valid({ 'function a.f() end' }),
  valid({ 'function a:f() end' }),
  valid({ 'function f(...) end' }),
  valid({ 'function f(p, ...) end' }),
  -- invalid({ 'function f(p,) end' } ),
  -- invalid({ 'function f(..., end' } ),
  valid({ 'return 1' }),

  -- tables
  valid({ 'a = { a=1, b="foo", c=nil }' }),
  valid({ 'a = {  }' }),
  valid({ 'a = {{{}}}' }),
  valid({ 'a = { ["foo"]="bar" }' }),
  valid({ 'a = { [1]=a, [2]=b, }' }),
  valid({ 'a = { true, a=1; ["foo"]="bar", }' }),

  -- comments
  valid({
    '-- this loop is rad',
    'for i=1,5 do',
    '  print(i)',
    'end',
  }),
  valid({
    '--- it foos the bar',
    '---@param bar table',
    'function foo(bar)',
    'end',
  }),
  valid({
    'function foo()',
    '  -- TODO: foo the bar',
    'end',
  }),
  valid({
    'for i=1,5 do',
    '  print(i)',
    'end -- done',
  }),
  valid({
    "--[[ multiline",
    "comment",
    'あいうえお --]]',
  }),
  valid({
    "--[[ multiline",
    "    =-=",
    "comment --]] -- another comment",
  }),
  valid({
    "-- comment",
    "  --[[ multiline",
    " |-|",
    "comment --]]",
  }),
  valid({
    "local a = 1 --[[ multiline",
    "comment --]] -- another comment",
    "a = 2",
  }),
  valid({
    "local a",
    "  -- comment",
    "--[[ multiline",
    "comment --]]",
    "a = 2",
  }),
  valid({
    "print('когда') --[[ function foo()",
    'end --]]',
  }),
  valid({
    '  --[[',
    '     wtf',
    '  --]]',
  }),
  valid({
    'local ml = [[ multi',
    '  line',
    '  string',
    ']]',
  }),
  valid({
    'local ml = [[ multiline',
    '  string',
    ']] -- comment',
  }),
  valid({
    '  local ml = [[',
    '     string',
    ']]',
  }),

  ---------------------------
  --- invalid
  ---------------------------

  --- identifiers
  invalid({ 'úő' }, Cursor:inline(0)),
  invalid({ 'local' }, Cursor:inline(0)),
  invalid({ 'local 1' }, Cursor:inline(0)),
  invalid({ '0 =' }, Cursor:inline(3)),
  invalid({ '"x" =' }, Cursor:inline(5)),
  invalid({ 'true =' }, Cursor:inline(6)),
  invalid({ '(a) =' }, Cursor:inline(5)),
  invalid({ 'a = 1 2' }, Cursor:inline(5)),
  invalid({ 'a = b = 2' }, Cursor:inline(5)),

  invalid({ 'do do end' }, Cursor:inline(9)),
  invalid({ 'do end do' }, Cursor:inline(9)),

  -- loop
  invalid({ 'while 1 do 2 end' }, Cursor:inline(10)),
  invalid({ 'while 1 end' }, Cursor:inline(7)),
  invalid({ 'repeat until' }, Cursor:inline(12)),

  invalid({ 'for' }, Cursor:inline(0)),
  invalid({ 'for do' }, Cursor:inline(0)),
  invalid({ 'for end' }, Cursor:inline(0)),
  invalid({ 'for 1' }, Cursor:inline(0)),
  invalid({ 'for a b in' }, Cursor:inline(5)),
  invalid({ 'for a =' }, Cursor:inline(7)),
  invalid({ 'for a, do end' }, Cursor:inline(5)),
  invalid({ 'for a, b =' }, Cursor:inline(6)),
  invalid({ 'for a = 1, 2, 3, 4 do end' }, Cursor:inline(16)),
  invalid({
    'for i=1,5',
    '  print(i)',
    'end',
  }, Cursor:inline(9)),
  invalid({
    'for i=1,5 then',
    '  print(i)',
    'end',
  }, Cursor:inline(9)),
  invalid({
    'for i=1,5 do',
    '  print(i)',
  }, Cursor:new(2, 10)),

  invalid({ 'function' }, Cursor:inline(0)),
  invalid({ 'function end' }, Cursor:inline(0)),
  invalid({ 'function f end' }, Cursor:inline(10)),
  invalid({ 'function f( end' }, Cursor:inline(10)),
  invalid({ 'return return' }, Cursor:inline(6)),
  -- invalid({ 'return 1,' }),

  invalid({ 'if' }, Cursor:inline(0)),
  invalid({ 'elseif' }, Cursor:inline(0)),
  invalid({ 'then' }, Cursor:inline(0)),
  invalid({ 'if then' }, Cursor:inline(2)),

  -- tables
  invalid({ 'a = {' }, Cursor:inline(5)),
  invalid({ 'a = {,}' }, Cursor:inline(5)),

  -- comments
  invalid({
    'for i=1,5 do --[[ inserting',
    '  a multiline comment',
    '  without closing',
    '  fp',
    'end',
  }, Cursor:inline(12)),

  -- multiline string
  invalid({
    'local ml = [[',
    '  multiline string',
    '  without closing',
  }, Cursor:inline(10)),

  -- literal
  invalid({ "local x = 'asd" }, Cursor:inline(9)),
}
