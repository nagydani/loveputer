local class = require('util.class')

describe('Working code', function()
  it('chain inheritance', function()
    --- Base class A
    local A = {}
    A.__index = A

    function A:new(x)
      local instance = setmetatable({}, self)
      instance.a = 'a'
      instance.x = x
      return instance
    end

    function A:a_method()
      return 'aaa'
    end

    --- Derived class B inheriting from A
    local B = {}
    B.__index = B
    setmetatable(B, { __index = A })

    function B:new(x, y)
      local instance = A.new(self, x) --- Call A's constructor
      instance.b = 'b'
      instance.y = y
      return instance
    end

    function B:b_method()
      return 'bbb'
    end

    --- Derived class C inheriting from B
    local C = {}
    C.__index = C
    setmetatable(C, { __index = B })

    function C:new(x, y, z)
      local instance = B.new(self, x, y) --- Call B's constructor
      instance.c = 'c'
      instance.z = z
      return instance
    end

    function C:c_method()
      return 'ccc'
    end

    local c = C:new(1, 2, 3)
    assert.same('c', c.c)
    assert.same('b', c.b)
    assert.same('a', c.a)
    assert.same(1, c.x)
    assert.same(2, c.y)
    assert.same(3, c.z)

    assert.same('aaa', c:a_method())
    assert.same('bbb', c:b_method())
    assert.same('ccc', c:c_method())
  end)
end)

describe('Class factory `create` handles', function()
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
