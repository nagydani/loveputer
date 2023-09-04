require("model.input.cursor")
require("util.debug")

if not orig_print then
  _G.orig_print = print
end

describe('cursor', function()
  it('compares', function()
    local c1 = Cursor:new(1, 2)
    local c2 = Cursor:new(1, 1)
    local c3 = Cursor:new(1, 1)
    assert.are.equal(-1, c1:compare(c2))
    assert.are.equal(1, c2:compare(c1))
    assert.are.equal(0, c3:compare(c2))
  end)
end)
