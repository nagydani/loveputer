Eval = {
  apply = function(input)
    local cpy = {}
    -- TODO logic
    for i = #input, 1, -1 do
      table.insert(cpy, input[i])
    end
    return cpy
  end
}
