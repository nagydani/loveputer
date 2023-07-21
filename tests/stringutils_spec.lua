require("util/string")

describe("StringUtils", function()
  local utest1 = 'когда'
  local utest2 = 'あいうえお'

  describe("splits", function()
    it('ASCII text', function()
      local atest1 = 'asdf'
      local pre, post = string.split_at(atest1, 1)
      assert.equal('', pre)
      assert.equal(atest1, post)
      pre, post = string.split_at(atest1, 2)
      assert.equal('a', pre)
      assert.equal('sdf', post)
    end)

    it('UTF-8 text', function()
      local pre, post = string.split_at(utest1, 1)
      assert.equal('', pre)
      assert.equal('когда', post)
      pre, post = string.split_at(utest1, 2)
      assert.equal('к', pre)
      assert.equal('огда', post)
    end)
  end)

  describe('substrings UTF-8 text with the other impl', function()
    it('splits', function()
      local s = StringUtils.utf8_sub(utest1, 1, 3)
      assert.equal('ког', s)
    end)

    it('splits the first char', function()
      local s = StringUtils.utf8_sub(utest1, 1, 1)
      assert.equal('к', s)
    end)

    it('trivially splits', function()
      local s = StringUtils.utf8_sub(utest1, 1, 5)
      assert.equal(utest1, s)
    end)

    it('trivially splits (negative end)', function()
      local s = StringUtils.utf8_sub(utest1, 1, -1)
      assert.equal(utest1, s)
    end)

    it('handles overindexing', function()
      local s = StringUtils.utf8_sub(utest1, 1, 6)
      assert.equal(utest1, s)
    end)

    it('handles overindexing from the start', function()
      local s = StringUtils.utf8_sub(utest1, 6)
      assert.equal("", s)
    end)

    describe('indexes negatively', function()
      it('one off', function()
        local s = StringUtils.utf8_sub(utest1, 1, -2)
        assert.equal('когд', s)
      end)

      it('two off', function()
        local s = StringUtils.utf8_sub(utest1, 1, -3)
        assert.equal('ког', s)
      end)

      it('off by one', function()
        local s = StringUtils.utf8_sub(utest1, 1, -5)
        assert.equal('к', s)
      end)

      it('suffix 1', function()
        local s = StringUtils.utf8_sub(utest1, -1)
        assert.equal('а', s)
      end)

      it('suffix 2', function()
        local s = StringUtils.utf8_sub(utest1, -2)
        assert.equal('да', s)
      end)

      it('suffix 2 ja', function()
        local s = StringUtils.utf8_sub(utest2, -2)
        assert.equal('えお', s)
      end)
    end)
  end)

  describe('splits on char', function()
    local test1 = 'first\nsecond'
    local test1_l1 = 'first'
    local test1_l2 = 'second'
    it('splits on one', function()
      local res = string.lines(test1)
      assert.same({ test1_l1, test1_l2 }, res)
    end)

    it('splits on none', function()
      local test = 'text'
      local res = string.lines(test)
      assert.same({ test }, res)
    end)
  end)
end)
