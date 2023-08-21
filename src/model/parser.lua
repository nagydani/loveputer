require("util/string")
require("util/dequeue")

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
      compiler = require 'metalua/metalua/compiler'.new(),
      tokenize = function(code, lc)
        local c = string.join(code, '\n')
        local lexer = lc:src_to_lexstream(c)
        local tokens = Dequeue:new()
        local n
        repeat
          n = lexer:next()
          tokens:append(n)
        until n.tag == 'Eof'
        return tokens
      end,
      parse = function(code, lc)
        local c = string.join(code, '\n')
        local parser = lc.src_to_ast
        return pcall(parser, lc, c)
      end,

      get_error = function(result)
        local err_lines = string.split(result, '\n')
        local err_first_line = err_lines[1]
        local colons = string.split(err_first_line, ':')
        local ms = string.gmatch(colons[3], '%d+')
        local line = tonumber(ms())
        local char = tonumber(ms())
        local errmsg = string.trim(colons[4])
        return line, char, errmsg
      end,

      pprint = function(code)
        local pprinter = require 'metalua/metalua/pprint'
        local c = string.join(code, '\n')
        return pprinter.tostring(c)
      end,
    }
  }

  local library = parsers[lib]
  local lc = library.compiler

  local tokenize = function(code)
    return library.tokenize(code, lc)
  end
  local parse = function(code)
    return library.parse(code, lc)
  end

  return {
    tokenize = tokenize,
    parse = parse,
    pprint = library.pprint,
    get_error = library.get_error
  }
end
