require("util.wrapped_text")

describe('WrappedText #wrap', function()
  local ex1 = {
    'ABBA',
    'EDDA AC/DC',
  }
  local ex2 = {
    '',
    'Turtle graphics game inspired the LOGO family of languages.',
    '',
  }
  local ex3 = { 'abc de' }
  local wrapper1 = WrappedText(5, ex1)
  local wrapper2 = WrappedText(30, ex2)
  local wrapper3 = WrappedText(1, ex3)
  local wrapper4 = WrappedText(80, ex3)

  describe('wraps text', function()
    local res1 = {
      'ABBA',
      'EDDA ',
      'AC/DC',
    }
    it('1', function()
      assert.same(res1, wrapper1:get_text())
    end)

    local res2 = {
      '',
      'Turtle graphics game inspired ',
      'the LOGO family of languages.',
      '',
    }
    it('2', function()
      assert.same(res2, wrapper2:get_text())
    end)

    local res3 = {
      'a',
      'b',
      'c',
      ' ',
      'd',
      'e',
    }
    it('3', function()
      assert.same(res3, wrapper3:get_text())
    end)

    local res4 = ex3
    it('4', function()
      assert.same(res4, wrapper4:get_text())
    end)
  end)
  describe('produces forward mapping', function()
    it('1', function()
      local fwd1 = { { 1 }, { 2, 3 } }
      assert.same(fwd1, wrapper1.wrap_forward)
    end)
    it('2', function()
      local fwd2 = { { 1 }, { 2, 3 }, { 4 } }
      assert.same(fwd2, wrapper2.wrap_forward)
    end)
    it('3', function()
      local fwd3 = { { 1, 2, 3, 4, 5, 6 } }
      assert.same(fwd3, wrapper3.wrap_forward)
    end)
    it('4', function()
      local fwd4 = { { 1 } }
      assert.same(fwd4, wrapper4.wrap_forward)
    end)
  end)
  describe('produces reverse mapping', function()
    it('1', function()
      local rev1 = { 1, 2, 2 }
      assert.same(rev1, wrapper1.wrap_reverse)
    end)
    it('2', function()
      local rev2 = { 1, 2, 2, 3 }
      assert.same(rev2, wrapper2.wrap_reverse)
    end)
    it('3', function()
      local rev3 = { 1, 1, 1, 1, 1, 1 }
      assert.same(rev3, wrapper3.wrap_reverse)
    end)
    it('4', function()
      local rev4 = { 1 }
      assert.same(rev4, wrapper4.wrap_reverse)
    end)
  end)

  describe('handles text change', function()
    local nt1 = {
      'ABBA EDDA AC/DC',
    }
    local res1 = {
      'ABBA ',
      'EDDA ',
      'AC/DC',
    }

    it('1', function()
      wrapper1:wrap(nt1)
      assert.same(res1, wrapper1:get_text())
    end)

    local nt2 = {
      'ABBA EDDA',
      'AC/DC',
    }
    local res2 = {
      'ABBA ',
      'EDDA',
      'AC/DC',
    }

    it('2', function()
      wrapper1:wrap(nt2)
      assert.same(res2, wrapper1:get_text())
    end)
  end)
end)
