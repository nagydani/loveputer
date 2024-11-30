require('util.dequeue')

--- Convert Blocks to string array
--- @param blocks Block[]
--- @return Dequeue<string>
local function render_blocks(blocks)
  local ret = Dequeue.typed('string')
  for _, v in ipairs(blocks) do
    if v:is_empty() then
      ret:append('')
    else
      ret:append_all(v.lines)
    end
  end
  ret:append('')
  return ret
end

return {
  render_blocks = render_blocks,
}
