require("util.debug")
require("util.string")
require("util.dequeue")

return function(lib)
  local l = lib or 'metalua'
  local add_paths = {
    '',
    'lib/' .. l .. '/?.lua',
    'lib/?.lua',
    -- 'lib/lua/5.1/?'
  }
  if love and not TESTING then
    local love_paths = string.join(add_paths, ';')
    love.filesystem.setRequirePath(
      love.filesystem.getRequirePath() .. love_paths)
  else
    local lib_paths = string.join(add_paths, ';src/')
    package.path = lib_paths .. ';' .. package.path
  end

  local mlc = require('metalua.metalua.compiler').new()

  --- Iterates over lexstream
  --- @param stream table
  --- @return table tokens
  local realize_stream = function(stream)
    local tokens = Dequeue()
    local n
    repeat
      n = stream:next()
      tokens:append(n)
    until n.tag == 'Eof'
    return tokens
  end

  --- Parses text table to lexstream
  --- @param code table
  --- @return table lexstream
  local stream_tokens = function(code)
    local c = string.unlines(code)
    local lexstream = mlc:src_to_lexstream(c)
    return lexstream
  end

  --- Parses text table to tokens
  --- @param code table
  --- @return table
  local tokenize = function(code)
    local stream = stream_tokens(code)
    return realize_stream(stream)
  end

  --- Parses lexstream to AST
  --- @param stream table
  --- @return table|string ast|errmsg
  local parse_stream = function(stream)
    return mlc:lexstream_to_ast(stream)
  end

  local ast_to_src = function(ast, ...)
    return mlc:ast_to_src(ast, ...)
  end

  --- Parses code to AST
  --- @param code table
  --- @return boolean success
  --- @return any result
  --- @return any ...
  local parse_prot = function(code)
    local stream = stream_tokens(code)
    -- return parse_stream_prot(stream)
    return pcall(parse_stream, stream)
  end

  --- Parses code to AST
  --- @param code string[]
  --- @return table|string ast|errmsg
  local parse = function(code)
    local stream = stream_tokens(code)
    return parse_stream(stream)
  end

  --- Finds error location and message in parse result
  --- @param result string
  --- @return number line
  --- @return number char
  --- @return string err_msg
  local get_error = function(result)
    local err_lines = string.lines(result)
    local err_first_line = err_lines[1]
    local err_second_line = err_lines[2]
    local colons = string.split(err_first_line, ':')
    local colons2 = string.split(err_second_line, ':')
    local match2 = string.gmatch(colons2[2] or '', '%d+')
    local line = tonumber(match2() or '') or -1
    local char = tonumber(match2() or '') or -1
    local errmsg = string.trim(colons[4])
    return line, char, errmsg
  end

  local pprint = function(code)
    local pprinter = require('metalua.metalua.pprint')
    local c = string.unlines(code)
    return pprinter.tostring(c)
  end

  --- Read lexstream and determine highlighting
  --- @param tokens table
  --- @return SyntaxColoring
  local syntax_hl = function(tokens)
    if not tokens then return {} end

    --- @type SyntaxColoring
    local colored_tokens = {}
    setmetatable(colored_tokens, {
      __index = function(table, key)
        --- default value is an empty array
        table[key] = {}
        return table[key]
      end
    })

    --- @param tag string
    --- @param single boolean
    --- @return TokenType?
    local function getType(tag, single)
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
        return nil
      end
    end

    --- @param first Cursor
    --- @param last Cursor
    --- @param text string
    --- @param lex_t LexType
    --- @param tl integer
    local function multiline(first, last, text, lex_t, tl)
      local ls = first.l
      local le = last.l
      local cs = first.c
      local ce = last.c
      local lines = string.lines(text)

      local n_lines = #lines
      local till = le + 1 - ls
      -- if the first line has no text after the block starter,
      -- we need to add an empty line on the front
      if n_lines + 1 == till then
        table.insert(lines, 1, '')
      end

      -- first line
      for i = cs, cs + string.ulen(lines[1]) + tl do
        colored_tokens[ls][i] = lex_t
      end
      for i = 2, till - 1 do
        local e = string.ulen(lines[i])
        for j = 1, e + 2 do
          colored_tokens[ls + i - 1][j] = lex_t
        end
      end
      -- last line
      for i = 1, ce do
        colored_tokens[le][i] = lex_t
      end
    end

    --- @param t token
    local function colorize(t)
      local text     = t[1]
      local tag      = t.tag
      local lfi      = t.lineinfo.first
      local lla      = t.lineinfo.last
      local first    = { l = lfi.line, c = lfi.column }
      local last     = { l = lla.line, c = lla.column }
      -- local first_f = lfi.facing
      -- local last_f  = lla.facing
      local comments = {}
      local function add_comment(c)
        local id = c.lineinfo.first.id
        if not comments[id] then
          local comment_text = c[1]
          if string.sub(comment_text, 1, 2) == '[[' then
            -- TODO unclosed comment block
            -- orig_print(Debug.terse_t(c))
          end

          local cfi    = c.lineinfo.first
          local cla    = c.lineinfo.last
          local cfirst = { l = cfi.line, c = cfi.column }
          local clast  = { l = cla.line, c = cla.column }
          local li     = {
            first = cfirst,
            last = clast,
            text = comment_text,
          }
          comments[id] = li
        end
      end
      if lfi.comments then
        for _, c in ipairs(lfi.comments) do
          add_comment(c)
        end
      end
      if lla.comments then
        for _, c in ipairs(lla.comments) do
          add_comment(c)
        end
      end

      -- normal tokens
      if first.l == last.l then
        local l = first.l
        local single = false
        if string.ulen(text) == 1 then
          single = true
        end
        for i = first.c, last.c do
          colored_tokens[l][i] = getType(tag, single)
        end
      else
        local tl = 2 --- a string block starts with '[['
        multiline(first, last, text, 'string', tl)
      end

      -- comments
      for _, co in pairs(comments) do
        local ls = co.first.l
        local le = co.last.l
        local cs = co.first.c
        local ce = co.last.c
        if ls == le then
          for i = cs, ce do
            colored_tokens[ls][i] = 'comment'
          end
        else
          local tl = 4 --- a block comment starts with '--[['
          multiline(co.first, co.last, co.text, 'comment', tl)
        end
      end
    end -- colorize

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
    parse_prot     = parse_prot,
    parse_stream   = parse_stream,
    pprint         = pprint,
    get_error      = get_error,
    syntax_hl      = syntax_hl,
    ast_to_src     = ast_to_src,
  }
end
