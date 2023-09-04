require("model.input.cursor")

Selection = {}

function Selection:new()
  return {
    start = {},
    fin = {},
    text = { '' },
    held = false,
  }
end
