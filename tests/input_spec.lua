require("../model/eval")
require("../model/inputModel")


describe("input model spec", function()
  -----------------
  --   ASCII     --
  -----------------
  describe('basics', function()
    local model = InputModel:new()

    it('initializes', function()
      assert.are.equal(getmetatable(model), InputModel)
    end)
    local test1 = 'asdf'
    local test_char1 = 'd'
    local test_char2 = 'n'

    it('is empty at first', function()
      assert.same('', model:get_text())
    end)

    it('sets text', function()
      model:set_text(test1)
      assert.is_equal(test1, model:get_text())
    end)

    it('clears text', function()
      model:clear()
      assert.is_equal('', model:get_text())
    end)

    it('appends text', function()
      model:set_text(test1)
      assert.is_equal(test1, model:get_text())
    end)

    it('appends characters', function()
      model:add_text(test_char1)
      assert.is_equal(test1 .. test_char1, model:get_text())
      model:clear()
      model:add_text(test_char1)
      assert.is_equal(test_char1, model:get_text())
      model:add_text(test_char2)
      assert.is_equal(test_char1 .. test_char2, model:get_text())
    end)
  end)

  -----------------
  --   cursor    --
  -----------------
  describe('cursor', function()
    local model = InputModel:new()
    local test1 = 'text'
    local test_char1 = 'x'

    it('is at base', function()
      assert.same('', model:get_text())
    end)

    it('advances by one', function()
      model:add_text(test_char1)
      local _, cc = model:get_cursor_pos()
      assert.same(2, cc)
    end)

    it('returns on backspace', function()
      model:backspace()
      assert.same(1, model:get_cursor_x())
    end)

    it('advances by multiple', function()
      model:add_text(test1)
      assert.same(1 + #test1, model:get_cursor_x())
    end)

    it('moves back', function()
      model:cursor_left()
      model:cursor_left()
      assert.same(1 + #test1 - 2, model:get_cursor_x())
    end)

    it('moves forward', function()
      model:cursor_right()
      model:cursor_right()
      assert.same(1 + #test1, model:get_cursor_x())
    end)

    it("doesn't move forward at the end", function()
      model:cursor_right()
      model:cursor_right()
      assert.same(1 + #test1, model:get_cursor_x())
    end)

    it("jumps to start on Home", function()
      model:jump_home()
      local cl, cc = model:get_cursor_pos()
      assert.same(1, cl)
      assert.same(1, cc)
    end)

    it("doesn't move back at the start", function()
      model:cursor_left()
      model:cursor_left()
      assert.same(1, model:get_cursor_x())
    end)
    it("jumps to the end on End", function()
      model:jump_end()
      local _, cc = model:get_cursor_pos()
      local l = #(model:get_text())
      assert.same(1 + l, cc)
    end)
  end)

  it('', function()
  end)
end)
