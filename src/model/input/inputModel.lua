require("model.interpreter.item")
require("model.input.inputText")
require("model.input.selection")

require("util.wrapped_text")
require("util.dequeue")
require("util.string")
require("util.debug")

--- @class InputModel
--- @field oneshot boolean
--- @field entered InputText
--- @field evaluator EvalBase
--- @field type InputType
--- @field cursor Cursor
--- @field wrapped_text WrappedText
--- @field get_wrapped_text function
--- @field selection table
--- @field cfg Config
--- methods
--- @field new function
--- @field add_text function
--- @field line_feed function
--- @field get_text function
--- @field get_text_line function
--- @field get_n_text_lines function
InputModel = {}

--- @param cfg Config
--- @param eval EvalBase
--- @param oneshot boolean?
function InputModel:new(cfg, eval, oneshot)
  local im = {
    oneshot = oneshot,
    entered = InputText:new(),
    evaluator = eval,
    type = eval.kind,
    cursor = Cursor:new(),
    wrapped_text = WrappedText.new(cfg.view.drawableChars),
    selection = Selection:new(),

    cfg = cfg,
  }
  setmetatable(im, self)
  self.__index = self

  return im
end

----------------
--  entered   --
----------------

--- @param text string
function InputModel:add_text(text)
  if type(text) == 'string' then
    self:pop_selected_text()
    local sl, cc    = self:_get_cursor_pos()
    local cur_line  = self:get_text_line(sl)
    local pre, post = string.split_at(cur_line, cc)
    local lines     = string.lines(text)
    local n_added   = #lines
    if n_added == 1 then
      local nval = string.interleave(pre, text, post)
      self:_set_text_line(nval, sl, true)
      self:_advance_cursor(string.ulen(text))
    else
      for k, line in ipairs(lines) do
        if k == 1 then
          local nval = pre .. line
          self:_set_text_line(nval, sl, true)
        elseif k == n_added then
          local nval = line .. post
          local last_line_i = sl + k - 1
          self:_set_text_line(nval, last_line_i, true)
          self:move_cursor(last_line_i, string.ulen(line) + 1)
        else
          self:_insert_text_line(line, sl + k - 1)
        end
      end
    end
    self:text_change()
  end
end

--- @param text string
--- @param keep_cursor boolean
function InputModel:set_text(text, keep_cursor)
  self.entered = nil
  if type(text) == 'string' then
    local lines = string.lines(text)
    local n_added = #lines
    if n_added == 1 then
      self.entered = InputText:new({ text })
    end
    if not keep_cursor then
      self:_update_cursor(true)
    end
  elseif type(text) == 'table' then
    self.entered = InputText:new(text)
  end
  self:jump_end()
  self:text_change()
end

--- @private
--- @param text string|string[]
--- @param ln integer
--- @param keep_cursor boolean
function InputModel:_set_text_line(text, ln, keep_cursor)
  if type(text) == 'string' then
    local ent = self:get_text()
    if ent then
      ent:update(text, ln)
      if not keep_cursor then
        self:_update_cursor(true)
      end
    elseif type(text) == 'table' and ln == 1 then
      self.entered = InputText:new(text)
    end
  end
end

--- @private
--- @param ln integer
function InputModel:_drop_text_line(ln)
  self:get_text():remove(ln)
end

--- @private
--- @param text string
--- @param li integer
function InputModel:_insert_text_line(text, li)
  local l = li or self:get_cursor_y()
  self.cursor.l = l + 1
  self:get_text():insert(text, l)
end

function InputModel:line_feed()
  local cl, cc = self:_get_cursor_pos()
  local cur_line = self:get_text_line(cl)
  local pre, post = string.split_at(cur_line, cc)
  self:_set_text_line(pre, cl, true)
  self:_insert_text_line(post, cl + 1)
  self:move_cursor(cl + 1, 1)
  self:text_change()
end

--- @return InputText
function InputModel:get_text()
  return self.entered or InputText:new()
end

--- @param l integer
--- @return string
function InputModel:get_text_line(l)
  local ent = self:get_text()
  return ent:get(l) or ''
end

--- @return integer
function InputModel:get_n_text_lines()
  local ent = self:get_text()
  return ent:length()
end

--- @return WrappedText
function InputModel:get_wrapped_text()
  return self.wrapped_text
end

--- @param l integer
--- @return string
function InputModel:get_wrapped_text_line(l)
  return self.wrapped_text:get_line(l)
end

--- @private
--- @return string
function InputModel:_get_current_line()
  local cl = self:get_cursor_y() or 1
  return self:get_text():get(cl)
end

function InputModel:paste(text)
  local sel = self:get_selection()
  local start = sel.start
  local fin = sel.fin
  if start and start.l and fin and fin.l and fin.c then
    local from, to = self:diff_cursors(start, fin)
    self:get_text():traverse(from, to, { delete = true })
    self:move_cursor(from.l, from.c)
  end
  self:add_text(text)
  self:clear_selection()
end

function InputModel:backspace()
  self:pop_selected_text()
  local line = self:_get_current_line()
  local cl, cc = self:_get_cursor_pos()
  local newcl = cl - 1
  local pre, post

  if cc == 1 then
    if cl == 1 then -- can't delete nothing
      return
    end
    -- line merge
    pre = self:get_text_line(newcl)
    local pre_len = string.ulen(pre)
    post = line
    local nval = pre .. post
    self:_set_text_line(nval, newcl, true)
    self:move_cursor(newcl, pre_len + 1)
    self:_drop_text_line(cl)
  else
    -- regular merge
    pre = string.usub(line, 1, cc - 2)
    post = string.usub(line, cc)
    local nval = pre .. post
    self:_set_text_line(nval, cl, true)
    self:cursor_left()
  end
  self:text_change()
end

function InputModel:delete()
  self:pop_selected_text()
  local line = self:_get_current_line()
  local cl, cc = self:_get_cursor_pos()
  local pre, post

  local n = self:get_n_text_lines()

  local llen = string.ulen(line)
  if cc == llen + 1 then
    if cl == n then
      return
    end
    -- line merge
    post = self:get_text_line(cl + 1)
    pre = line
    self:_drop_text_line(cl + 1)
  else
    -- regular merge
    pre = string.usub(line, 1, cc - 1)
    post = string.usub(line, cc + 1)
  end
  local nval = pre .. post
  self:_set_text_line(nval, cl, true)
  self:text_change()
end

function InputModel:clear_input()
  self.entered = InputText:new()
  self:text_change()
  self:clear_selection()
  self:_update_cursor(true)
  self.tokens = nil
end

function InputModel:reset()
  self:clear_input()
end

function InputModel:text_change()
  local ev = self.evaluator
  if ev.kind == 'lua' then
    -- TODO enforce this kind-parser invariant in types
    ---@diagnostic disable-next-line: undefined-field
    local ts = ev.parser.tokenize(self:get_text())
    self.tokens = ts
  end
  self.wrapped_text:wrap(self.entered)
end

--- @return Highlight?
function InputModel:highlight()
  local ev = self.evaluator
  if ev.highlight then
    -- TODO enforce this highligh-parser invariant in types
    ---@diagnostic disable-next-line: undefined-field
    local p = ev.parser
    local text = self:get_text()
    local lex = p.stream_tokens(text)
    -- iterating over the stream exhausts it
    local tokens = p.realize_stream(lex)
    local ok, err = p.parse_prot(text)
    local parse_err
    if not ok then
      local l, c, msg = p.get_error(err)
      parse_err = { l = l, c = c, msg = msg }
    end

    return {
      parse_err = parse_err,
      hl = p.syntax_hl(tokens),
    }
  end
end

----------------
--   cursor   --
----------------

--- @private
--- @param replace_line boolean
function InputModel:_update_cursor(replace_line)
  local cl = self:get_cursor_y()
  local t = self:get_text()
  if replace_line then
    self.cursor.c = string.ulen(t[cl]) + 1
    self.cursor.l = #t
  else

  end
end

--- @private
--- @param x integer
--- @param y integer
function InputModel:_advance_cursor(x, y)
  local cur_l, cur_c = self:_get_cursor_pos()
  local move_x = x or 1
  local move_y = y or 0
  if move_y == 0 then
    local next = cur_c + move_x
    self.cursor.c = next
  else
    self.cursor.l = cur_l + move_y
    -- TODO multiline
  end
end

function InputModel:move_cursor(y, x, selection)
  local prev_l, prev_c = self:_get_cursor_pos()
  local c, l
  local line_limit = self:get_n_text_lines() + 1 -- allow for line just being added
  if y and y >= 1 and y <= line_limit then
    l = y
  else
    l = prev_l
  end
  local llen = #(self:get_text_line(l))
  local char_limit = llen + 1
  if x and x >= 1 and x <= char_limit then
    c = x
  else
    c = prev_c
  end
  self.cursor = {
    c = c,
    l = l
  }

  if selection == 'keep' then
  elseif selection == 'move' then
  else
    self:clear_selection()
  end
end

--- @private
--- @return integer l
--- @return integer c
function InputModel:_get_cursor_pos()
  return self.cursor.l, self.cursor.c
end

--- @return CursorInfo
function InputModel:get_cursor_info()
  return {
    cursor = self.cursor,
  }
end

function InputModel:get_cursor_x()
  return self.cursor.c
end

function InputModel:get_cursor_y()
  return self.cursor.l
end

--- @param dir VerticalDir
--- @return boolean? limit
function InputModel:cursor_vertical_move(dir)
  local cl, cc = self:_get_cursor_pos()
  local w = self.wrapped_text.wrap_w
  local n = self:get_n_text_lines()
  local llen = string.ulen(self:get_text_line(cl))
  local full_lines = math.floor(llen / w)

  --- @param is_inline function
  --- @param is_not_last_line function
  --- @return boolean? limit
  local function move(is_inline, is_not_last_line)
    local keep = (function()
      if self.selection:is_held() then
        return 'keep'
      end
    end)()
    local function sgn(back, fwd)
      if dir == 'up' then
        return back()
      elseif dir == 'down' then
        return fwd()
      end
    end
    if llen > w and is_inline() then
      local newc = sgn(
        function() return math.max(cc - w, 0) end,
        function() return math.min(cc + w, llen + 1) end
      )
      self:move_cursor(cl, newc, keep)
      if keep then self:end_selection() end
      return
    end
    if is_not_last_line() then
      local nl = sgn(
        function() return cl - 1 end,
        function() return cl + 1 end
      )
      local target_line = self:get_text_line(nl)
      local target_len = string.ulen(target_line)
      local offset = math.fmod(cc, w)
      local newc
      if target_len > w then
        local base = sgn(
          function() return math.floor(target_len / w) * w end,
          function() return 0 end
        )
        local t_offset = sgn(
          function() return math.fmod(target_len, w) + 1 end,
          function() return math.fmod(w, target_len) end
        )

        local new_off = math.min(offset, t_offset)
        newc = base + new_off
      else
        newc = math.min(offset, 1 + string.ulen(target_line))
      end
      self:move_cursor(nl, newc, keep)
      if keep then self:end_selection() end
    else
      if self:is_selection_held() then
        sgn(
          function() self:jump_home() end,
          function() self:jump_end() end
        )
      end
      return true
    end
  end

  local limit
  if dir == 'up' then
    limit = move(
      function() return cc - w > 0 end,
      function() return cl > 1 end
    )
  elseif dir == 'down' then
    limit = move(
      function() return cc <= full_lines * w end,
      function() return cl < n end
    )
  else
    return
  end
  return limit
end

function InputModel:cursor_left()
  local cl, cc = self:_get_cursor_pos()
  local nl, nc = (function()
    if cc > 1 then
      local next = cc - 1
      return nil, next
    elseif cl > 1 then
      local cpl = cl - 1
      local pl = self:get_text_line(cpl)
      local cpc = 1 + string.ulen(pl)
      return cpl, cpc
    end
  end)()

  if self.selection:is_held() then
    self:move_cursor(nl, nc, 'keep')
    self:end_selection()
  else
    self:move_cursor(nl, nc)
  end
end

function InputModel:cursor_right()
  local cl, cc = self:_get_cursor_pos()
  local line = self:get_text_line(cl)
  local len = string.ulen(line)
  local next = cc + 1
  local nl, nc = (function()
    if cc <= len then
      return nil, next
    elseif cl < self:get_n_text_lines() then
      return cl + 1, 1
    end
  end)()

  if self.selection:is_held() then
    self:end_selection(cl, cc + 1)
    self:move_cursor(nl, nc, 'keep')
  else
    self:move_cursor(nl, nc)
  end
end

function InputModel:jump_home()
  local keep = (function()
    if self.selection:is_held() then
      return 'keep'
    end
  end)()
  local nl, nc = 1, 1
  self:end_selection(nl, nc)
  self:move_cursor(nl, nc, keep)
end

function InputModel:jump_end()
  local ent = self:get_text()
  local last_line = #ent
  local last_char = string.ulen(ent[last_line]) + 1
  local keep = (function()
    if self.selection:is_held() then
      return 'keep'
    end
  end)()
  self:end_selection(last_line, last_char)
  self:move_cursor(last_line, last_char, keep)
end

function InputModel:get_status()
  return {
    input_type = self.type,
    cursor = self.cursor,
    n_lines = self:get_n_text_lines(),
  }
end

----------------
-- evaluation --
----------------

--- @return string[]
function InputModel:finish()
  local ent = self:get_text()
  --- @diagnostic disable-next-line: param-type-mismatch
  if self.oneshot then love.event.push('userinput', ent) end
  return ent
end

function InputModel:cancel()
  self:clear_input()
end

----------------
-- selection  --
----------------
function InputModel:translate_grid_to_cursor(l, c)
  local wt       = self.wrapped_text.wrap_reverse
  local li       = wt[l] or wt[#wt]
  local line     = self:get_wrapped_text_line(l)
  local llen     = string.ulen(line)
  local c_offset = math.min(llen + 1, c)
  local c_base   = l - li
  local ci       = c_base * self.wrapped_text.wrap_w + c_offset
  return li, ci
end

function InputModel:diff_cursors(c1, c2)
  if c1 and c2 then
    local d = c1:compare(c2)
    if d > 0 then
      return c1, c2
    else
      return c2, c1
    end
  end
end

function InputModel:text_between_cursors(from, to)
  if from and to then
    return self:get_text():traverse(from, to)
  else
    return { '' }
  end
end

function InputModel:start_selection(l, c)
  local start = (function()
    if l and c then
      return Cursor:new(l, c)
    else -- default to current cursor position
      return Cursor:new(self:_get_cursor_pos())
    end
  end)()
  self.selection.start = start
end

function InputModel:end_selection(l, c)
  local start         = self.selection.start
  local fin           = (function()
    if l and c then
      return Cursor:new(l, c)
    else -- default to current cursor position
      return Cursor:new(self:_get_cursor_pos())
    end
  end)()
  local from, to      = self:diff_cursors(start, fin)
  local sel           = self:text_between_cursors(from, to)
  self.selection.fin  = fin
  self.selection.text = sel
end

function InputModel:hold_selection(is_mouse)
  if not is_mouse then
    local cur_start = self:get_selection().start
    local cur_end = self:get_selection().fin
    if cur_start and cur_start.l and cur_start.c then
      self:start_selection(cur_start.l, cur_start.c)
    else
      self:start_selection()
    end
    if cur_end and cur_end.l and cur_end.c then
      self:end_selection(cur_end.l, cur_end.c)
    else
      self:end_selection()
    end
  end
  self.selection.held = true
end

function InputModel:release_selection()
  self.selection.held = false
end

function InputModel:get_selection()
  return self.selection
end

function InputModel:is_selection_held()
  return self.selection.held
end

function InputModel:get_ordered_selection()
  local sel = self.selection
  local s, e = self:diff_cursors(sel.start, sel.fin)
  local ret = Selection:new()
  ret.start = s
  ret.fin = e
  ret.text = sel.text
  ret.held = sel.held
  return ret
end

function InputModel:get_selected_text()
  return self.selection.text
end

function InputModel:pop_selected_text()
  local t = self.selection.text
  local start = self.selection.start
  local fin = self.selection.fin
  if start and fin then
    local from, to = self:diff_cursors(start, fin)
    self:get_text():traverse(from, to, { delete = true })
    self:text_change()
    self:move_cursor(from.l, from.c)
    self:clear_selection()
    return t
  end
end

function InputModel:clear_selection()
  self.selection = Selection:new()
  self:release_selection()
end

function InputModel:mouse_click(l, c)
  local li, ci = self:translate_grid_to_cursor(l, c)
  self:clear_selection()
  self:start_selection(li, ci)
  self:hold_selection(true)
end

function InputModel:mouse_release(l, c)
  local li, ci = self:translate_grid_to_cursor(l, c)
  self:release_selection()
  self:end_selection(li, ci)
  self:move_cursor(li, ci, 'keep')
end

function InputModel:mouse_drag(l, c)
  local li, ci = self:translate_grid_to_cursor(l, c)
  local sel = self:get_selection()
  if sel.start and sel.held then
    self:end_selection(li, ci)
    self:move_cursor(li, ci, 'move')
  end
end
