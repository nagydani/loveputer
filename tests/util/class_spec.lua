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

  it('new', function()
    N = class.create()
    local sample = 'sample'
    N.new = function(cfg)
      local self = setmetatable({
        sample = sample,
        cfg = cfg,
      }, N)

      return self
    end

    local cfg = 'config'
    local n = N(cfg)
    assert.same(cfg, n.cfg)
    assert.same(sample, n.sample)

    R = class.create()
    R.new = function(dim)
      local width = dim.width or 10
      local height = dim.height or 5
      local self = setmetatable({
        width = width,
        height = height,
        area = width * height,
      }, R)

      return self
    end

    local rect = R({ width = 80, height = 25 })
    assert.same(80, rect.width)
    assert.same(25, rect.height)
    assert.same(2000, rect.area)
  end)
end)

describe('Class factory `newclass`', function()
  it('', function()
    -- assert.same('<expected>', '<value under test>')
  end)
end)
