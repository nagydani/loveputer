require("model.input.inputText")
require("model.input.cursor")

require("util.dequeue")
require("util.table")
require("util.debug")

describe('InputText', function()
  local l1 = 'local a = 1 --[[ ml'
  local l2 = 'c --]] -- ac'
  local l3 = 'a = 2'
  local t = Dequeue.typed('string')
  t:append(l1)
  t:append(l2)
  t:append(l3)
  local text = InputText:new(t)

  it('inherits Dequeue', function()
    local empty = InputText:new()
    assert.same({ 1 }, table.keys(empty))
    assert.same({ l1, l2, l3 }, text)
  end)

  it('traverses', function()
    local from = Cursor:new(1, 12)
    local to   = Cursor:new(2, 7 + 1)
    local trav = text:traverse(from, to)
    local exp  = {
      ' --[[ ml',
      'c --]] ',
    }
    assert.same(exp, trav)

    local rem    = {
      'local a = 1-- ac',
      'a = 2',
    }
    local trav_d = text:traverse(from, to, { delete = true })
    assert.same(exp, trav_d)
    assert.same(rem, text)

    local text2  = InputText:new(t)
    -- from   = Cursor:new(1, 12)
    to           = Cursor:new(3, 1)
    local exp2   = {
      ' --[[ ml',
      'c --]] -- ac',
      '',
    }
    local rem2   = {
      'local a = 1a = 2',
      -- 'local a = 1',
      -- 'a = 2',
    }
    local trav_2 = text2:traverse(from, to, { delete = true })
    assert.same(exp2, trav_2)
    assert.same(rem2, text2)

    -- from   = Cursor:new(1, 12)
    to            = Cursor:new(2, string.ulen(l2) + 1)
    local text2b  = InputText:new(t)
    local exp2b   = {
      ' --[[ ml',
      'c --]] -- ac',
    }
    local rem2b   = {
      'local a = 1',
      'a = 2',
    }
    local trav_2b = text2b:traverse(from, to, { delete = true })
    assert.same(exp2b, trav_2b)
    assert.same(rem2b, text2b)

    local text3  = InputText:new(t)
    from         = Cursor:new(2, 7)
    to           = Cursor:new(2, 12 + 1)
    local trav_3 = text3:traverse(from, to)
    local exp3   = {
      ' -- ac',
    }
    assert.same(exp3, trav_3)
    local rem3b = {
      'local a = 1 --[[ ml',
      'c --]]',
      'a = 2',
    }
    local trav_3b = text3:traverse(from, to, { delete = true })
    assert.same(exp3, trav_3b)
    assert.same(rem3b, text3)
  end)
end)
