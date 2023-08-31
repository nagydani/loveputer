require("util/debug")

describe('debugger #debug', function()
  it('empty', function()
    local t = {}
    local res = Debug.terse_t(t)
    --     local exp = [[{
    -- }, ]]
    local exp = [[{}, ]]
    assert.same(exp, res)
  end)
end)
