require("util.dequeue")
require("util.debug")


describe('Dequeue', function()
  it('instantiates empty', function()
    local q = Dequeue()
    assert.same({}, q)
  end)

  it('instantiates with starting values', function()
    local t = { 1 }
    local q = Dequeue(t)
    assert.same(t, q)
    local t2 = { 'asd' }
    local q2 = Dequeue(t2)
    assert.same(t2, q2:items())
  end)

  it('appends', function()
    local q = Dequeue()
    local v = 'asdf'
    q:push_back(v)
    assert.same({ v }, q)

    local t = { v }
    local q2 = Dequeue(t)
    assert.same({ v }, q2)
    local v2 = '123'
    q2:push_back(v2)
    assert.same({ v, v2 }, q2)
  end)

  it('prepends', function()
    local q = Dequeue()
    local v = 'asdf'
    q:push_front(v)
    assert.same({ v }, q)

    local t = { v }
    local q2 = Dequeue(t)
    local v2 = '123'
    q2:push_front(v2)
    assert.same({ v2, v }, q2)
  end)

  local st = { 'first', 'second', 'third' }
  local q = Dequeue(st)
  it('inserts', function()
    assert.same(st, q)
    local i = 'inserted'
    q:insert(i, 2)

    assert.same({
      'first',
      'inserted', -- insert at 2
      'second',
      'third',
    }, q)
  end)

  it('removes', function()
    q:remove(3)

    assert.same({
      'first',
      'inserted',
      'third',
    }, q)
  end)

  it('replaces', function()
    local qr = Dequeue(st)
    assert.same(st, qr)
    local i = 'inserted'
    q:update(i, 2)

    assert.same({
      'first',
      'inserted', -- replace at 2
      'third',
    }, q)
  end)

  describe('pops', function()
    it('at the front', function()
      local st = { 'a', 'b', 'c', 'd' }
      local q = Dequeue(st)
      assert.same(st[1], q:get(1))
      assert.same(st[1], q:pop_front())
      assert.same(st[2], q:get(1))
    end)
    it('at the back', function()
      local st = { 'a', 'b', 'c', 'd' }
      local q = Dequeue(st)
      assert.same(st[4], q:last())
      assert.same(st[4], q:pop_back())
      assert.same(st[3], q:last())
    end)
  end)

  describe('validates indices', function()
    it('empty', function()
      local e = Dequeue()
      assert.is_false(e:is_valid(-1))
      assert.is_false(e:is_valid(0))
      assert.is_false(e:is_valid(1))
      assert.is_false(e:is_valid(2))
    end)
    it('nonempty', function()
      local ne = Dequeue({ 1, 2, 3 })
      assert.is_false(ne:is_valid(-1))
      assert.is_false(ne:is_valid(0))
      assert.is_true(ne:is_valid(1))
      assert.is_true(ne:is_valid(2))
      assert.is_true(ne:is_valid(3))
      assert.is_false(ne:is_valid(4))
      assert.is_false(ne:is_valid(100))
    end)
  end)

  describe('moves elements', function()
    local td = Dequeue({ 'a', 'b', 'c', 'd' })

    it('unless invalid indices are specified', function()
      assert.is_false(td:move(15, 2))
      assert.is_false(td:move(1, 20))
      assert.is_false(td:move(0, 0))
    end)
    it('same is noop, but valid', function()
      assert.is_true(td:move(1, 1))
    end)
    it('test cases', function()
      local t1 = table.clone(td)
      local r1 = Dequeue({ 'b', 'c', 'a', 'd' })
      assert.is_true(t1:move(1, 3))
      assert.same(r1, t1)

      local t2 = table.clone(td)
      local r2 = Dequeue({ 'd', 'a', 'b', 'c' })
      assert.is_true(t2:move(4, 1))
      assert.same(r2, t2)

      local t3 = table.clone(td)
      local t4 = table.clone(td)
      assert.is_true(t3:move(2, 3))
      assert.is_true(t4:move(3, 2))
      assert.same(t3, t4)
    end)
  end)
end)
