require("util.table")
require("util.debug")

describe('table utils #table', function()
  local t1 = { 1, 2, 3 }
  local t2 = { 'a', 'b', 'c' }
  local t3 = { key = 'asd' }
  local t4 = { 1, 2, key = 'asd' }
  describe('is_array', function()
    it('determines if table is pure array', function()
      assert.is_true(table.is_array(t1))
      assert.is_true(table.is_array(t2))
      assert.is_false(table.is_array(t3))
      assert.is_false(table.is_array(t4))
    end)
  end)

  describe('odds', function()
    it('returns odd-indexed elements', function()
      assert.same({}, table.odds({}))
      assert.same({ 1, 3 }, table.odds(t1))
      assert.same({ 'a', 'c' }, table.odds(t2))
      assert.same({}, table.odds(t3))
      assert.same({ 1 }, table.odds(t4))
    end)
  end)

  describe('flatten', function()
    it('one deep', function()
      assert.same({}, table.flatten({}))

      local d1 = {
        {
          { name = 'x', line = 1, },
        },
        {
          { name = 'w',  line = 4, },
          { name = 'ww', line = 4, },
        },
      }
      local r1 = {
        { name = 'x',  line = 1, },
        { name = 'w',  line = 4, },
        { name = 'ww', line = 4, },
      }
      assert.same(r1, table.flatten(d1))

      local d2 = {
        {
          {
            { name = 'x', line = 1, },
          },
        },
        {
          { name = 'w',  line = 4, },
          { name = 'ww', line = 4, },
        },
      }
      local r2 = {
        {
          { name = 'x', line = 1, },
        },
        { name = 'w',  line = 4, },
        { name = 'ww', line = 4, },
      }
      assert.same(r2, table.flatten(d2))
    end)
  end)

  describe('find', function()
    it('by value', function()
      assert.equal(3, table.find(t2, 'c'))
      assert.is_nil(table.find(t1, 15))
      assert.is_nil(table.find(t2, 'd'))
      assert.equal('key', table.find(t4, 'asd'))
    end)
    it('by predicate', function()
      local gto = function(x) return x > 1 end
      local isbool = function(b) return type(b) == "boolean" end
      assert.equal(2, table.find_by(t1, gto))
      assert.is_nil(table.find(t1, isbool))

      local tt = {
        { i = 1, val = 'a' },
        { i = 2, val = 'b' },
        { i = 3, val = 'c' },
      }
      local function idx(i)
        return function(v) return v.i == i end
      end
      assert.equal(3, table.find_by(tt, idx(3)))
    end)
  end)

  describe('is_member', function()
    it('determines if table contains element', function()
      assert.is_false(table.is_member({}, 1))
      assert.is_false(table.is_member(t1))

      assert.is_true(table.is_member(t1, 1))
      assert.is_true(table.is_member(t1, 2))
      assert.is_true(table.is_member(t1, 3))
      assert.is_false(table.is_member(t1, 5))
      assert.is_false(table.is_member(t1, 'a'))

      assert.is_false(table.is_member(t3, 10))

      assert.is_true(table.is_member(t4, 'asd'))
    end)
  end)

  describe('reftable', function()
    it('works', function()
      local rt = table.new_reftable()

      rt(1)
      local v = rt()
      assert.same(v, rt())

      rt('test')
      v = rt()
      assert.same(v, rt())
    end)
    it('creates new table on every invocation', function()
      local rt1 = table.new_reftable()
      local rt2 = table.new_reftable()

      assert.are_not_equal(rt1, rt2)
      local v1 = '1'
      rt1(v1)
      local v1_r = rt1()
      assert.same(v1, v1_r)

      local v2 = 2
      rt2(v2)
      assert.same(v2, rt2())
    end)
  end)
end)
