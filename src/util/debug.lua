Debug = {}


function Debug:printT(t)
  if not t then return '' end
  local res = ''
  if type(t) == 'table' then
    for k, v in pairs(t) do
      local header = '---- ' .. k .. ' ----\n'
      res = res .. header
      res = res .. Debug:printT(v)
      res = res .. '\n'
    end
  elseif type(t) == 'string' then
    res = res .. t .. '\n'
  end
  return res
end
