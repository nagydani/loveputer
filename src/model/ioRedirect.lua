local function set_print(M)
  if not M or not M.output or not M.output.push then
    error('Cannot write to model')
  end
  local origPrint = _G.print
  _G.orig_print = origPrint
  local magicPrint = function(...)
    local arg = { ... }
    -- origPrint('t', string.join(arg, '\t'))
    for _, v in ipairs(arg) do
      origPrint(v)
      M.output:push(v)
    end
    -- M.output:push(arg)
  end
  _G.print = magicPrint
end

local function set_write(M)
  if not M or not M.output or not M.output.write then
    error('Cannot write to model')
  end
  local origWrite = io.write
  local defaultOut = io.output()
  local write = function(...)
    origWrite(...)
    local out = io.output()
    if out == defaultOut then
      local arg = { ... }
      for _, v in ipairs(arg) do
        M.output:write(v)
      end
    end
  end
  io.write = write
end

local function redirect_to(M)
  set_print(M)
  set_write(M)
end

return redirect_to
