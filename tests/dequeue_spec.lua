require("util.dequeue")


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
end)
