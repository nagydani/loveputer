require("util.range")

describe('Range', function()
  local r1 = Range(5, 10)

  it('includes', function()
    assert.is_true(r1:inc(5))
    assert.is_true(r1:inc(6))
    assert.is_true(r1:inc(10))

    assert.is_false(r1:inc(11))
    assert.is_false(r1:inc(1))
  end)
end)
