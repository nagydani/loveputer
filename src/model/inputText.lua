InputText = {}
function InputText:new(values)
  local text = Dequeue:new(values)
  if not values then text:append('') end
  return text
end
