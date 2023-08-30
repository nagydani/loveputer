require("util.string")

describe("StringUtils #string", function()
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

    describe('on char', function()
      local test1 = 'first\nsecond'
      local test1_l1 = 'first'
      local test1_l2 = 'second'
      it('one', function()
        local res = string.lines(test1)
        assert.same({ test1_l1, test1_l2 }, res)
      end)

      it('none', function()
        local test = 'text'
        local res = string.lines(test)
        assert.same({ test }, res)
      end)

      it('preceding', function()
        local test = '\nmultiline\ncomment'
        local res = string.lines(test)
        assert.same({ '', 'multiline', 'comment' }, res)
      end)

      it('succeding', function()
        local test = 'multiline\ncomment\n\n'
        local res = string.lines(test)
        assert.same({ 'multiline', 'comment', '', '' }, res)
      end)
    end)

    describe('multiple', function()
      local test1 = { 'first\nsecond', 'third' }
      local test1_l1 = 'first'
      local test1_l2 = 'second'
      local test1_2 = 'third'
      it('', function()
        local res = string.lines(test1)
        assert.same({ test1_l1, test1_l2, test1_2 }, res)
      end)
    end)
  end)

  describe('substrings UTF-8 text with the other impl', function()
    it('splits', function()
      local s = string.usub(utest1, 1, 3)
      assert.equal('ког', s)
    end)

    it('splits the first char', function()
      local s = string.usub(utest1, 1, 1)
      assert.equal('к', s)
    end)

    it('trivially splits', function()
      local s = string.usub(utest1, 1, 5)
      assert.equal(utest1, s)
    end)

    it('trivially splits (negative end)', function()
      local s = string.usub(utest1, 1, -1)
      assert.equal(utest1, s)
    end)

    it('handles overindexing', function()
      local s = string.usub(utest1, 1, 6)
      assert.equal(utest1, s)
    end)

    it('handles overindexing from the start', function()
      local s = string.usub(utest1, 6)
      assert.equal("", s)
    end)

    describe('indexes negatively', function()
      it('one off', function()
        local s = string.usub(utest1, 1, -2)
        assert.equal('когд', s)
      end)

      it('two off', function()
        local s = string.usub(utest1, 1, -3)
        assert.equal('ког', s)
      end)

      it('off by one', function()
        local s = string.usub(utest1, 1, -5)
        assert.equal('к', s)
      end)

      it('suffix 1', function()
        local s = string.usub(utest1, -1)
        assert.equal('а', s)
      end)

      it('suffix 2', function()
        local s = string.usub(utest1, -2)
        assert.equal('да', s)
      end)

      it('suffix 2 ja', function()
        local s = string.usub(utest2, -2)
        assert.equal('えお', s)
      end)
    end)
  end)

  describe('joins', function()
    local words = { 'first', 'second' }
    it('no char specified', function()
      local res = string.join(words)
      assert.same('first second', res)
    end)
    it('newline specified', function()
      local res = string.join(words, '\n')
      assert.same('first\nsecond', res)
    end)
    it('comma specified', function()
      local res = string.join(words, ', ')
      assert.same('first, second', res)
    end)

    it('single word', function()
      local word = 'word'
      local w = { word }
      local res = string.join(w, ', ')
      assert.same(word, res)
      res = string.join(word, ', ')
      assert.same(word, res)
    end)

    it('single line', function()
      local str = 'lorem ipsum dolor'
      local w = { str }
      local res = string.join(w, '\n')
      assert.same(str, res)
      res = string.join(str, ', ')
      assert.same(str, res)
    end)
  end)

  describe('determines emptiness', function()
    it('empty single', function()
      local res = string.is_non_empty_string('')
      assert.is_false(res)
    end)
    it('empty array', function()
      local res = string.is_non_empty_string_array({ '' })
      assert.is_false(res)
    end)
    it('empty array with multiple', function()
      local res = string.is_non_empty_string_array({ '', '' })
      assert.is_false(res)
    end)
    it('nonempty single', function()
      local res = string.is_non_empty_string('a')
      assert.is_true(res)
    end)
    it('nonempty array', function()
      local res = string.is_non_empty_string_array({ 'a', '' })
      assert.is_true(res)
    end)
    it('nonempty array with leading', function()
      local res = string.is_non_empty_string_array({ '', 'a' })
      assert.is_true(res)
    end)
  end)

  describe('wraps strings', function()
    it('even', function()
      local test1 = '123qweдлв'
      local test1_l1 = '123'
      local test1_l2 = 'qwe'
      local test1_l3 = 'длв'
      local res = string.wrap_at(test1, 3)
      assert.same({ test1_l1, test1_l2, test1_l3 }, res)
    end)
    it('with remainder', function()
      local test1 = 'длвqwe1234'
      local test1_l1 = 'длв'
      local test1_l2 = 'qwe'
      local test1_l3 = '123'
      local test1_l4 = '4'
      local res = string.wrap_at(test1, 3)
      assert.same({
        test1_l1,
        test1_l2,
        test1_l3,
        test1_l4 }, res)
    end)
    it('shorter', function()
      local test1 = '1234'
      local res = string.wrap_at(test1, 5)
      assert.same({ test1 }, res)
    end)
    it('empty', function()
      local test1 = ''
      local res = string.wrap_at(test1, 5)
      assert.same({ test1 }, res)
    end)
    it('whitespace', function()
      local test1 = ' '
      local res = string.wrap_at(test1, 5)
      assert.same({ test1 }, res)
    end)
    it('whitespace break', function()
      local test1 = ' '
      local res = string.wrap_at(test1 .. test1, 1)
      assert.same({ test1, test1 }, res)
    end)

    it('unicode', function()
      local test1 = "An expression was expected, and `�' can 't start an expression "
      local exp = { 'An expression was expected, an'
      , "d `�' can 't start an expressi"
      , 'on ' }
      local res = string.wrap_at(test1, 30)
      assert.same(exp, res)
    end)
  end)

  describe('determines length', function()
    it('empty', function()
      assert.same(0, string.ulen(''))
    end)
    it('space', function()
      assert.same(1, string.ulen(' '))
    end)
    it('spaces', function()
      assert.same(3, string.ulen('   '))
    end)
    it('test 1', function()
      assert.same(5, string.ulen(utest1))
    end)
    it('test 2', function()
      assert.same(5, string.ulen(utest2))
    end)
  end)
end)
