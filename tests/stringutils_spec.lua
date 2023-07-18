require("../util/string")

describe("StringUtils", function()
  local test1 = 'когда'
  local test2 = 'あいうえお'

  describe('splits UTF-8 text', function()
    local pre, post = StringUtils.utf8_split_at(test1, 1)
    assert.equal('', pre)
    assert.equal('когда', post)
    pre, post = StringUtils.utf8_split_at(test1, 2)
    assert.equal('к', pre)
    assert.equal('огда', post)
  end)

  describe('substrings UTF-8 text with the other impl', function()
    it('splits', function()
      local s = StringUtils.utf8_sub(test1, 1, 3)
      assert.equal('ког', s)
    end)

    it('splits the first char', function()
      local s = StringUtils.utf8_sub(test1, 1, 1)
      assert.equal('к', s)
    end)

    it('trivially splits', function()
      local s = StringUtils.utf8_sub(test1, 1, 5)
      assert.equal(test1, s)
    end)

    it('trivially splits (negative end)', function()
      local s = StringUtils.utf8_sub(test1, 1, -1)
      assert.equal(test1, s)
    end)

    it('handles overindexing', function()
      local s = StringUtils.utf8_sub(test1, 1, 6)
      assert.equal(test1, s)
    end)

    it('handles overindexing from the start', function()
      local s = StringUtils.utf8_sub(test1, 6)
      assert.equal("", s)
    end)

    describe('indexes negatively', function()
      it('one off', function()
        local s = StringUtils.utf8_sub(test1, 1, -2)
        assert.equal('когд', s)
      end)

      it('two off', function()
        local s = StringUtils.utf8_sub(test1, 1, -3)
        assert.equal('ког', s)
      end)

      it('off by one', function()
        local s = StringUtils.utf8_sub(test1, 1, -5)
        assert.equal('к', s)
      end)

      it('suffix 1', function()
        local s = StringUtils.utf8_sub(test1, -1)
        assert.equal('а', s)
      end)

      it('suffix 2', function()
        local s = StringUtils.utf8_sub(test1, -2)
        assert.equal('да', s)
      end)

      it('suffix 2 ja', function()
        local s = StringUtils.utf8_sub(test2, -2)
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
