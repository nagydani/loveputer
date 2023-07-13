require("../model/eval")
require("../model/inputModel")


describe("input model spec", function()
  local model = InputModel:new()

  it('initializes', function()
    assert.are.equal(getmetatable(model), InputModel)
  end)

  describe('basics', function()
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

  it('', function()
  end)

  pending("UTF-8")
end)
