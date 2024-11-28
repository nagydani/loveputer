require('util.tree')

--- @alias token_id string
--- @alias blocknum integer

--- @class BufferLocation
--- @field block blocknum
--- @field line integer
--- @field lineinfo? lineinfo

--- @class Assignment
--- @field name string
--- @field line integer

--- @class Definition: Assignment
--- @field id token_id
--- @field loc BufferLocation
-- --- @field type? Type

--- @alias DefBlockMap { [blocknum]: token_id[] }
-- --- @alias DefBlock token_id[][]

--- TODO: come up with a better name
--- @class SemanticDB
--- @field assignments Assignment[]

local keywords_list = {
  "and",
  "break",
  "do",
  "else",
  "elseif",
  "end",
  "false",
  "for",
  "function",
  "if",
  "in",
  "local",
  "nil",
  "not",
  "or",
  "repeat",
  "return",
  "then",
  "true",
  "until",
  "while",
}
local keywords = {}
for _, kw in pairs(keywords_list) do
  keywords[kw] = true
end

--- @param ast AST
--- @return string?
local function get_idx_stack(ast)
  --- @return string?
  local function go(node)
    local tag = node.tag
    if tag == "Index" then
      return go(node[1]) .. '.' .. node[2][1]
    elseif tag == "Id" then
      local acc = node[1]
      return acc
    else
      return
    end
  end
  return go(ast)
end

--- @param node AST
--- @return boolean
local function is_idx_stack(node)
  local st = get_idx_stack(node)
  if st then return true end
  return false
end

local function is_ident(id)
  -- HACK:
  if type(id) ~= "string" then
    return false
  end
  return string["match"](id, "^[%a_][%w_]*$") and not keywords[id]
end

--- @param node AST
--- @return table?
local function definition_extractor(node)
  local deftags = { 'Local', 'Localrec', 'Set', 'Table' }

  local function get_line_number(n)
    local li = n.lineinfo
    local li_f = type(li) == 'table' and li.first
    return type(li_f) == 'table' and li_f.line
  end
  local function get_lhs_name(n)
    return n[1]
  end

  if type(node) == 'table' and node.tag then
    local tag = node.tag
    if table.is_member(deftags, tag) then
      local ret = {}
      -- ret.tag = tag

      local lhs = node[1]
      local rhs = node[2]

      local name = ''
      if tag == 'Table' then
        --- TODO traverse Pairs
        return
      elseif tag == 'Set'
          and lhs[1].tag == "Index"
          and rhs[1].tag == "Function"
          and rhs[1][1][1] and rhs[1][1][1][1] == "self"
          and is_idx_stack(lhs[1][1])
          and is_ident(lhs[1][2][1])
      then
        local class = lhs[1][1][1]
        local method = lhs[1][2][1]
        name = class .. ':' .. method
      elseif tag == 'Set'
          and rhs[1].tag == "Function"
          and is_idx_stack(lhs[1])
      then
        name = get_idx_stack(lhs[1]) or ''
      else
        --- @type token[]?
        local lhss = table.odds(node)
        local rets = {}
        ---@diagnostic disable-next-line: param-type-mismatch
        for _, v in ipairs(lhss) do
          for _, w in ipairs(v) do
            local n = get_lhs_name(w)
            if type(n) == 'string' then
              table.insert(rets, {
                name = n,
                line = get_line_number(w)
              })
            end
          end
        end
        return rets
      end

      ret.name = name
      ret.line = node.lineinfo.first.line
      return { ret }
    end
  end
end

--- @param ast AST
--- @return SemanticDB
local function analyze(ast)
  local t = table.flatten(
    Tree.preorder(ast, definition_extractor)
  )
  return { assignments = t }
end

return {
  analyze = analyze
}
