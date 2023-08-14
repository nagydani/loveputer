require("util/string")

return function(parserlib)
  local lib = parserlib or 'dummy'

  local parsers = {
    dummy = {
      parse = function(code)
        return true, ''
      end,
      pprint = function(code)
        return ''
      end,
      get_error = function(result)
        local line = 0
        local char = 0
        local errmsg = ''
        return line, char, errmsg
      end,
    },

  }

  local add_paths = {
    '',
    'lib/' .. lib .. ' /?.lua',
    'lib/?.lua'
  }
  if love then
    local love_paths = string.join(add_paths, ';')
    love.filesystem.setRequirePath(love.filesystem.getRequirePath() .. love_paths)
  else
    local lib_paths = string.join(add_paths, ';src/')
    package.path = package.path .. lib_paths
  end

  return parsers[lib]
end
