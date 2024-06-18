local parser = require("model.lang.parser")('metalua')
local tokenHL = require("model.lang.tokenHighlighter")
local term = require("util.termcolor")
require("util.color")
require("util.debug")

local inputs = require("tests.interpreter.ast_inputs")

if not orig_print then
  _G.orig_print = print
end

if not _G.unpack then
  _G.unpack = table.unpack
end

local show_ast = os.getenv("SHOW_AST")
local parser_debug = os.getenv("PARSER_DEBUG") or show_ast

local w = 64

describe('parser #ast', function()
  local function do_code(ast, seen_comments)
    local code, comments = parser.ast_to_src(ast, seen_comments, w)
    local seen = seen_comments or {}
    for k, v in pairs(comments) do
      --- if a table was passed in, this modifies it
      seen[k] = v
    end
    local tokens = parser.tokenize(code)
    local hl = parser.syntax_hl(tokens)
    if parser_debug then
      local code_t = string.lines(code)
      for l, line in ipairs(code_t) do
        io.write("'")
        for j = 1, #code do
          local c = tokenHL.colorize(hl[l][j])
          term.print_c(c, string.usub(line, j, j), true)
        end
        io.write(term.reset)
        io.write("'")
        print()
      end
      io.write(term.reset)
    end
    if show_ast then
      -- Log.info(parser.pprint(v, { hide_lineinfo = false }))
      -- Log.debug(Debug.terse_hash(v, nil, nil, true))
    end
    return code, seen_comments
  end

  describe('produces ASTs', function()
    for i, tc in ipairs(inputs) do
      local input = tc[1]
      local output = tc[2]

      local ok, r = parser.parse_prot(input)
      local result = {}
      if ok then
        if parser_debug then
          io.write(string.rep('=', 80))
          print(Debug.text_table(input))
        end
        local has_lines = false
        local seen_comments = {}
        for _, v in ipairs(r) do
          has_lines = true
          local ct, _ = do_code(v, seen_comments)
          for _, cl in ipairs(string.lines(ct) or {}) do
            table.insert(result, cl)
          end
        end
        --- corner case, e.g comments only
        --- it is valid code, but gets parsed a bit differently
        if not has_lines then
          result = string.lines(do_code(r)) or {}
        end

        --- remove trailing newline
        if result[#result] == '' then
          table.remove(result)
        end
        it('matches ' .. i, function()
          assert.same(output, result)
          assert.is_true(parser.parse_prot(output))
        end)
      else
        Log.warn('syntax error in input #' .. i)
        Log.error(r:gsub('\\n', '\n'))
      end
    end
  end)
end)
