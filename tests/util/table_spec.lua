require("util.table")

describe('table utils #table', function()
  describe('is_array', function()
    local t1 = { 1, 2, 3 }
    local t2 = { 'a', 'b', 'c' }
    local t3 = { key = 'asd' }
    local t4 = { 1, 2, key = 'asd' }
    it('determines if table is pure array', function()
      assert.is_true(table.is_array(t1))
      assert.is_true(table.is_array(t2))
      assert.is_false(table.is_array(t3))
      assert.is_false(table.is_array(t4))
    end)
  end)
end)
