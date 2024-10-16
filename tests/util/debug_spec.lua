require("util.debug")

describe('debugger #debug', function()
  it('empty', function()
    local t = {}
    local res = Debug.terse_hash(t)
    local exp = [[{}, ]]
    assert.same(exp, res)
  end)

  describe('terse', function()
    it('hash', function()
      local t = { 'a', 'b', c = 'd' }
      t[{}] = 1
      t[{ 2 }] = 3
      local res = Debug.terse_t(t)
      --- TODO: order-independent table sameness
      -- assert.same(
      --   "{1: 'a', 2: 'b', {1: 2, }, : 3, {}, : 1, c: 'd', }, ",
      --   res)
    end)
    it('array', function()
      local t = { 1, 2, 3 }
      local res = Debug.terse_t(t)
      assert.same({
          '[',
          '/* 1 */',
          '1, ',
          '/* 2 */',
          '2, ',
          '/* 3 */',
          '3, ',
          ']'
        },
        string.lines(res))
    end)
  end)
end)
