local class = require('util.class')

describe('Class factory `create`', function()
  it('very simple', function()
    local ctr_a = function()
      return { a = 'a' }
    end
    A = class.create(ctr_a)
    local a = A()
    assert.same('a', a.a)
  end)
  it('params', function()
    local ctr = function(x, y)
      return { x = x, y = y }
    end
    K = class.create(ctr)
    local v1, v2 = 'x1', 'y1'
    local c = K(v1, v2)
    assert.same(v1, c.x)
    assert.same(v2, c.y)
  end)
  it('kwargs', function()
    local ctr = function(args)
      local ret = {}
      for k, v in pairs(args) do
        ret[k] = v
      end
      return ret
    end
    K = class.create(ctr)
    local kwargs = {
      x = 1, y = 2, z = 'z'
    }
    local k = K(kwargs)
    assert.same(1, k.x)
    assert.same(2, k.y)
    assert.same('z', k.z)
  end)

  it('methods', function()
    M = class.create()
    function M.method1()
      return 'hello'
    end

    function M:method2()
      self.hello = true
    end

    local m = M()

    assert.same('hello', m.method1())
    M:method2()
    assert.is_true(M.hello)
  end)
end)

describe('Class factory `newclass`', function()
  it('', function()
    -- assert.same('<expected>', '<value under test>')
  end)
end)
