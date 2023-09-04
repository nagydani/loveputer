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
end)
