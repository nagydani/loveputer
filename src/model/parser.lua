require("util/string")

return function(parserlib)
  local lib = parserlib or 'metalua'

  local add_paths = {
    '',
    'lib/' .. lib .. '/?.lua',
    'lib/?.lua'
  }
  if love then
    local love_paths = string.join(add_paths, ';')
    love.filesystem.setRequirePath(love.filesystem.getRequirePath() .. love_paths)
  else
    local lib_paths = string.join(add_paths, ';src/')
    package.path = package.path .. lib_paths
  end

  local parsers = {
    metalua = {
      parse = function(code)
        local mlc = require 'metalua/metalua/compiler'.new()
        local parser = mlc.src_to_ast
        local c = string.join(code, '\n')
        return pcall(parser, mlc, c)
      end,
      pprint = function(code)
        local pprinter = require 'metalua/metalua/pprint'
        return pprinter.tostring(code)
      end,
      get_error = function(result)
        local err_lines = string.split(result, '\n')
        local err_first_line = err_lines[1]
        local colons = string.split(err_first_line, ':')
        local ms = string.gmatch(colons[3], '%d+')
        local line = ms()
        local char = ms()
        local errmsg = string.trim(colons[4])
        return line, char, errmsg
      end,
    },

  }

  return parsers[lib]
end
