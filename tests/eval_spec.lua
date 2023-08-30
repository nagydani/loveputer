require("model.input.eval.textEval")
require("model.input.eval.luaEval")

describe('TextEval #eval', function()
  local eval = TextEval:new()
  it('returns', function()
    local input = 'asd'

    assert.same(input, eval.apply(input))
  end)
  it('returns multiline', function()
    local input = { 'asd', 'qwer' }

    assert.same(input, eval.apply(input))
  end)

  it('returns multiline with empties', function()
    local input = { '', 'asd', 'qwer' }

    assert.same(input, eval.apply(input))
  end)
end)
