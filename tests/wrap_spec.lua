require("util.wrapped_text")
require("util.debug")

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
  local wrapper1 = WrappedText(5, ex1)
  local wrapper2 = WrappedText(30, ex2)

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
  end)
end)
