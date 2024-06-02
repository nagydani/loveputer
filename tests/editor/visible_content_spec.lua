require("view.editor.visibleContent")

require("util.utf")

describe('VisibleContent #wrap', function()
  local turtle_doc = {
    '',
    'Turtle graphics game inspired the LOGO family of languages.',
    '',
  }

  local content1 = VisibleContent(80, {}, Range(0, 0))
  local content2 = VisibleContent(30, turtle_doc, Range(0, 3))
  describe('produces forward mapping', function()
    it('1', function()
      local fwd1 = { { 1 } }
      assert.same(fwd1, content1.wrap_forward)
    end)
    it('2', function()
      local fwd2 = { { 1 }, { 2, 3 }, { 4 }, { 5 } }
      assert.same(fwd2, content2.wrap_forward)
    end)
  end)
  describe('produces reverse mapping', function()
    it('1', function()
      local rev1 = { 0 }
      assert.same(rev1, content1.wrap_reverse)
    end)
    it('2', function()
      local rev2 = { 1, 2, 2, 3, 4 }
      assert.same(rev2, content2.wrap_reverse)
    end)
  end)
end)
