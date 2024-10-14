require('model.editor.bufferModel')
local parser = require('model.lang.parser')()

require('util.table')

describe('Buffer #editor', function()
  local chunker = parser.chunker
  local hl = parser.highlighter

  it('renders plaintext', function()
    local l1 = 'line 1'
    local l2 = 'line 2'
    local l3 = 'x = 1'
    local l4 = 'the end'
    local tst = { l1, l2, l3, l4 }
    local cbuffer = BufferModel('untitled', tst, nil)
    local bc = cbuffer:get_content()
    assert.same(cbuffer.content_type, 'plain')
    assert.same(4, #bc)
    assert.same(l1, bc[1])
    assert.same(l2, bc[2])
    assert.same(l3, bc[3])
    assert.same(l4, bc[4])
  end)

  it('renders lua', function()
    local l1 = '--- comment 1'
    local l2 = '--- comment 2'
    local l3 = 'x = 1'
    local l4 = '--- comment end'
    local tst = { l1, l2, l3, l4 }
    local cbuffer = BufferModel('untitled.lua', tst, chunker, hl)
    local bc = cbuffer:get_content()
    assert.same(cbuffer.content_type, 'lua')
    assert.same(4, #bc)
    assert.same({ l1 }, bc[1].lines)
    assert.same({ l2 }, bc[2].lines)
    assert.same({ l3 }, bc[3].lines)
    assert.same({ l4 }, bc[4].lines)
  end)

  local meat = [[function sierpinski(depth)
  lines = { '*' }
  for i = 2, depth + 1 do
    sp = string.rep(' ', 2 ^ (i - 2))
    tmp = {} -- comment
    for idx, line in ipairs(lines) do
      tmp[idx] = sp .. line .. sp
      tmp[idx + #lines] = line .. ' ' .. line
    end
    lines = tmp
  end
  return table.concat(lines, '\n')
end]]
  local txt = string.lines([[--- @param depth integer
]] .. meat .. [[


print(sierpinski(4))]])

  local buffer = BufferModel('test.lua', txt, chunker, hl)
  it('sets name', function()
    assert.same('test.lua', buffer.name)
  end)
  local bufcon = buffer:get_content()
  it('sets content', function()
    assert.same('block', bufcon:type())
    assert.same(4, #bufcon)
    assert.same({ '--- @param depth integer' }, bufcon[1].lines)
    assert.same(string.lines(meat), bufcon[2].lines)
    assert.is_true(table.is_instance(bufcon[3], 'empty'))
    assert.same({ 'print(sierpinski(4))' }, bufcon[4].lines)
  end)
end)
