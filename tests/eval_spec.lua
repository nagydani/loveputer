require("model.interpreter.eval.textEval")
require("model.interpreter.eval.luaEval")

describe('TextEval #eval', function()
  local eval = TextEval:new()

  local function head(obj)
    if obj then
      if type(obj) == 'table' then
        return obj[1]
      end
    else
      return obj
    end
    return nil
  end

  it('returns', function()
    local input = { 'asd' }
    local ok, ret = eval.apply(input)

    assert.truthy(ok)
    assert.same(input, head(ret))
  end)
  it('returns multiline', function()
    local input = { 'asd', 'qwer' }

    local ok, ret = eval.apply(input)
    assert.truthy(ok)
    assert.same(input, head(ret))
  end)

  it('returns multiline with empties', function()
    local input = { '', 'asd', 'qwer' }

    local ok, ret = eval.apply(input)
    assert.truthy(ok)
    assert.same(input, head(ret))
  end)
end)
