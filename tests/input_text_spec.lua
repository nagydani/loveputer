require("model.input.inputText")
require("model.input.cursor")

require("util.dequeue")
require("util.table")
require("util.debug")

describe('InputText', function()
  local l1 = 'local a = 1 --[[ ml'
  local l2 = 'c --]] -- ac'
  local l3 = 'a = 2'
  local t = Dequeue:new()
  t:append(l1)
  t:append(l2)
  t:append(l3)
  local text = InputText:new(t)

  it('inherits Dequeue', function()
    local empty = InputText:new()
    assert.same({ 1 }, keys(empty))
    assert.same({ l1, l2, l3 }, text)
  end)

  it('traverses', function()
    local from   = Cursor:new(1, 12)
    local to     = Cursor:new(2, 7)
    local trav   = text:traverse(from, to)
    local trav_s = text:traverse(from, to, { slow = true })
    local exp    = {
      ' --[[ ml',
      'c --]] ',
    }

    assert.same(exp, trav)
    assert.same(exp, trav_s)

    local rem    = {
      'local a = 1',
      '-- ac',
      'a = 2',
    }
    local trav_d = text:traverse(from, to, { delete = true })
    assert.same(exp, trav_d)
    assert.same(rem, text)

    local text2  = InputText:new(t)
    to           = Cursor:new(3, 0)
    local exp2   = {
      ' --[[ ml',
      'c --]] -- ac',
      '',
    }
    local rem2   = {
      'local a = 1',
      'a = 2',
    }
    local trav_2 = text2:traverse(from, to, { delete = true })
    assert.same(exp2, trav_2)
    assert.same(rem2, text2)
  end)
end)
