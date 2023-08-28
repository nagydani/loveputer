require("util/string")
require("util/dequeue")

return function(lib)
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

  local mlc = require 'metalua/metalua/compiler'.new()

  --- Iterates over lexstream
  ---@param stream table
  ---@return table tokens
  local realize_stream = function(stream)
    local tokens = Dequeue:new()
    local n
    repeat
      n = stream:next()
      tokens:append(n)
    until n.tag == 'Eof'
    return tokens
  end

  --- Parses text table to lexstream
  ---@param code table
  ---@return table lexstream
  local stream_tokens = function(code)
    local c = string.join(code, '\n')
    local lexstream = mlc:src_to_lexstream(c)
    return lexstream
  end

  --- Parses text table to tokens
  ---@param code table
  ---@return table
  local tokenize = function(code)
    local stream = stream_tokens(code)
    return realize_stream(stream)
  end

  --- Parses lexstream to AST
  ---@param stream table
  ---@return boolean success
  ---@return string? errmsg
  local parse_stream = function(stream)
    local parser = mlc.lexstream_to_ast
    return pcall(parser, mlc, stream)
  end

  local parse = function(code)
    local stream = stream_tokens(code)
    return parse_stream(stream)
  end

  --- Finds error location and message in parse result
  ---@param result table
  ---@return number line
  ---@return number char
  ---@return string err_msg
  local get_error = function(result)
    local err_lines = string.split(result, '\n')
    local err_first_line = err_lines[1]
    local colons = string.split(err_first_line, ':')
    local ms = string.gmatch(colons[3], '%d+')
    local line = tonumber(ms()) or 0
    local char = tonumber(ms()) or 0
    local errmsg = string.trim(colons[4])
    return line, char, errmsg
  end

  local pprint = function(code)
    local pprinter = require 'metalua/metalua/pprint'
    local c = string.join(code, '\n')
    return pprinter.tostring(c)
  end

  --- Read lexstream and determine highlighting
  ---@param tokens table
  ---@return table
  local syntax_hl = function(tokens)
    if not tokens then
      return {}
    end
    local colored_tokens = {}
    local colorize = function(t)
      local text  = t[1]
      local tag   = t.tag
      local lfi   = t.lineinfo.first
      local lla   = t.lineinfo.last
      local first = { l = lfi.line, c = lfi.column }
      local last  = { l = lla.line, c = lla.column }
      -- local first_f = lfi.facing
      -- local last_f  = lla.facing

      if first.l == last.l then
        local l = first.l
        if not colored_tokens[l] then
          colored_tokens[l] = {}
        end
        local single = false
        if string.ulen(text) == 1 then
          single = true
        end
        local type = (function()
          if tag == 'Keyword' then
            if single then
              return 'kw_single'
            else
              return 'kw_multi'
            end
          elseif tag == 'Number' then
            return 'number'
          elseif tag == 'String' then
            return 'string'
          elseif tag == 'Id' then
            return 'identifier'
          else
            -- TODO: comments
            return nil
          end
        end)()
        for i = first.c, last.c do
          colored_tokens[l][i] = type
        end
      else
      end
    end

    if tokens.next then
      repeat
        local t = tokens:next()
        colorize(t)
      until t.tag == 'Eof'
    else
      for _, t in pairs(tokens) do
        colorize(t)
      end
    end
    return colored_tokens
  end

  return {
    stream_tokens  = stream_tokens,
    realize_stream = realize_stream,
    tokenize       = tokenize,
    parse          = parse,
    parse_stream   = parse_stream,
    pprint         = pprint,
    get_error      = get_error,
    syntax_hl      = syntax_hl,
  }
end
