local function set_print(M)
  if not M or not M.output or not M.output.push then
    error('Cannot write to model')
  end
  local origPrint = _G.print
  _G.orig_print = origPrint
  local magicPrint = function(...)
    local arg = { ... }
    if type(arg) == 'string' then
      -- origPrint('s', arg)
      M.output:push({ arg .. '\n' })
    end
    if type(arg) == 'table' then
      -- origPrint('t', string.join(arg, '\t'))
      for _, v in ipairs(arg) do
        origPrint(v)
        M.output:push(v)
      end
      -- M.output:push(arg)
    end
  end
  _G.print = magicPrint
end

local function redirect_to(M)
  set_print(M)
end

return redirect_to
