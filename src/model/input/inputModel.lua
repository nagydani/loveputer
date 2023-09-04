require("model.input.eval.textEval")
require("model.input.eval.luaEval")
require("model.input.inputText")
require("model.input.selection")

require("util.dequeue")
require("util.string")
require("util.debug")


InputModel = {}

function InputModel:new(cfg)
  local textEval = TextEval:new()
  local luaEval = LuaEval:new('metalua')
  local im = {
    entered = InputText:new(),
    n_lines = 1,
    history = Dequeue:new(),
    evaluator = luaEval,
    textEval = textEval,
    luaEval = luaEval,
    cursor = Cursor:new(),
    error = nil,
    wrap = cfg.drawableChars,
    wrapped_text = {},
    cursor_wrap = {},
    wrap_reverse = {},
    n_breaks = 0,
    selection = Selection:new()
  }
  setmetatable(im, self)
  self.__index = self

  return im
end

----------------
--  entered   --
----------------
function InputModel:add_text(text)
  if type(text) == 'string' then
    local sl, cc = self:_get_cursor_pos()
    local cur_line = self:get_text_line(sl)
    local pre, post = string.split_at(cur_line, cc)
    local lines = string.lines(text)
    local n_added = #lines
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

function InputModel:_set_text(text, keep_cursor)
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

function InputModel:_set_text_line(text, ln, keep_cursor)
  if type(text) == 'string' then
    local ent = self.entered
    if ent then
      ent:update(text, ln)
      if not keep_cursor then
        self:_update_cursor(true)
      end
    elseif ln == 1 then
      self.entered = InputText:new(text)
    end
  end
end

function InputModel:_drop_text_line(ln)
  self.entered:remove(ln)
end

function InputModel:_insert_text_line(text, li)
  local l = li or self:get_cursor_y()
  self.cursor.y = l + 1
  self.entered:insert(text, l)
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

function InputModel:get_text()
  return self.entered or InputText:new()
end

function InputModel:get_text_line(l)
  local ent = self.entered or InputText:new()
  return ent:get(l)
end

function InputModel:get_n_text_lines()
  local ent = self.entered or InputText:new()
  return ent:length()
end

function InputModel:get_wrapped_text()
  return self.wrapped_text
end

function InputModel:get_wrapped_text_line(l)
  local wt = self:get_wrapped_text()
  return wt[l]
end

function InputModel:_get_current_line()
  local cl = self:get_cursor_y() or 1
  return self.entered:get(cl)
end

function InputModel:paste(text)
  self:add_text(text)
end

function InputModel:backspace()
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

function InputModel:clear()
  self.entered = InputText:new()
  self:_update_cursor(true)
  self.historic_index = nil
  self.tokens = nil
end

----------------
--   cursor   --
----------------
function InputModel:_update_cursor(replace_line)
  local cl = self:get_cursor_y()
  local t = self:get_text()
  if replace_line then
    self.cursor.c = string.ulen(t[cl]) + 1
    self.cursor.l = #t
  else

  end
end

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
  local line_limit = self.n_lines + 1 -- allow for line just being added
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

function InputModel:_get_cursor_pos()
  return self.cursor.l, self.cursor.c
end

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

function InputModel:cursor_vertical_move(dir)
  local cl, cc = self:_get_cursor_pos()
  local w = self.wrap
  local n = self:get_n_text_lines()
  local llen = string.ulen(self:get_text_line(cl))
  local full_lines = math.floor(llen / w)
  local function move(is_inline, is_not_last_line)
    local function sgn(back, fwd)
      if dir == 'up' then
        return back()
      elseif dir == 'down' then
        return fwd()
      end
    end
    if llen > w and is_inline() then
      local newc = sgn(
        function() return math.max(cc - self.wrap, 0) end,
        function() return math.min(cc + self.wrap, llen + 1) end
      )
      self:move_cursor(cl, newc)
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
      self:move_cursor(nl, newc)
    else
      sgn(
        function() self:history_back() end,
        function() self:history_fwd() end
      )
    end
  end

  if dir == 'up' then
    move(
      function() return cc - w > 0 end,
      function() return cl > 1 end
    )
  elseif dir == 'down' then
    move(
      function() return cc <= full_lines * w end,
      function() return cl < n end
    )
  else
    return
  end
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

  if self.selection:isHeld() then
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

  if self.selection:isHeld() then
    self:end_selection(cl, cc + 1)
    self:move_cursor(nl, nc, 'keep')
  else
    self:move_cursor(nl, nc)
  end
end

function InputModel:jump_home()
  self:move_cursor(1, 1)
end

function InputModel:jump_end()
  local ent = self:get_text()
  local last_line = #ent
  local last_char = string.ulen(ent[last_line]) + 1
  self:move_cursor(last_line, last_char)
end

----------------
-- evaluation --
----------------
function InputModel:get_status()
  return {
    input_type = self.evaluator.kind,
    cursor = self.cursor,
    n_lines = self:get_n_text_lines(),
  }
end

function InputModel:evaluate()
  return self:_handle(true)
end

function InputModel:cancel()
  self:_handle(false)
end

function InputModel:_handle(eval)
  local ent = self:get_text()
  self.historic_index = nil
  local ok, result
  if string.is_non_empty_string_array(ent) then
    self:_remember(ent)
    if eval then
      ok, result = self.evaluator.apply(ent)
      if ok then
        self:clear()
      else
        local l, c, err = self:get_eval_error(result)
        self:move_cursor(l, c + 1)
        self.error = err
      end
    else
      self:clear()
    end
  end
  return ok, result
end

----------------
--   error    --
----------------
function InputModel:clear_error()
  self.error = nil
end

function InputModel:get_error()
  return self.error
end

function InputModel:set_error(error, is_load_error)
  if string.is_non_empty_string(error) then
    self.error = error
    if not is_load_error then
      self:history_back()
    end
  end
end

function InputModel:get_eval_error(errors)
  local ev = self.evaluator
  if ev.kind == 'lua' and string.is_non_empty_string_array(self:get_text()) then
    return ev.parser.get_error(errors)
  end
end

----------------
--  history   --
----------------
function InputModel:_remember(input)
  if string.is_non_empty_string_array(input) then
    self.history:append(input)
  end
end

function InputModel:text_change()
  local ev = self.evaluator
  self.n_lines = #(self.entered)
  if ev.kind == 'lua' then
    local ts = ev.parser.tokenize(self:get_text())
    self.tokens = ts
  end
  self:wrap_text()
end

function InputModel:wrap_text()
  local drawableChars = self.wrap
  local text = self:get_text()
  local display = {}
  local cursor_wrap = {}
  local wrap_reverse = {}
  local breaks = 0
  local revi = 1
  for i, l in ipairs(text) do
    local n = math.floor(string.ulen(l) / drawableChars)
    -- remember how many apparent lines will be overall
    local ap = n + 1
    cursor_wrap[i] = ap
    for _ = 1, ap do
      wrap_reverse[revi] = i
      revi = revi + 1
    end
    breaks = breaks + n
    local lines = string.wrap_at(l, drawableChars)
    for _, tl in ipairs(lines) do
      table.insert(display, tl)
    end
  end
  self.wrapped_text = display
  self.cursor_wrap = cursor_wrap
  self.wrap_reverse = wrap_reverse
  self.n_breaks = breaks
end

function InputModel:highlight()
  local ev = self.evaluator
  if ev.kind == 'lua' then
    local p = ev.parser
    local text = self:get_text()
    local lex = p.stream_tokens(text)
    -- iterating over the stream exhausts it
    local tokens = p.realize_stream(lex)
    local ok, err = p.parse(text)
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

function InputModel:history_back()
  local ent = self:get_text()
  local hi = self.historic_index
  -- TODO: remember cursor pos?
  if hi and hi > 0 then
    local prev = self.history[hi - 1]
    if prev then
      local current = self:get_text()
      if string.is_non_empty_string_array(current) then
        self.history[hi] = current
      end
      self:_set_text(prev)
      local last_line_len = string.ulen(prev[#prev])
      self.historic_index = hi - 1
      self:jump_end()
    end
  else
    self.historic_index = self.history:get_last_index()
    self:_remember(ent)
    local prev = self.history[self.historic_index] or ''
    self:_set_text(prev)
    self:jump_end()
  end
end

function InputModel:history_fwd()
  if self.historic_index then
    local hi = self.historic_index
    local next = self.history[hi + 1]
    local current = self:get_text()
    if string.is_non_empty_string_array(current) then
      self.history[hi] = current
    end
    if next then
      self:_set_text(next)
      self.historic_index = hi + 1
    else
      self:clear()
    end
  else
    self:cancel()
  end
  self:jump_end() -- TODO: remember cursor pos?
end

function InputModel:_get_history_length()
  return #(self.history)
end

function InputModel:_get_history_entry(i)
  return self.history[i]
end

function InputModel:_get_history_entries()
  return self.history:items()
end

----------------
-- selection  --
----------------
function InputModel:translate_grid_to_cursor(l, c)
  local wt       = self.wrap_reverse
  local li       = wt[l] or wt[#wt]
  local line     = self:get_wrapped_text_line(l)
  local llen     = string.ulen(line)
  local c_offset = math.min(llen + 1, c)
  local c_base   = l - li
  local ci       = c_base * self.wrap + c_offset
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
    return self.entered:traverse(from, to)
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

function InputModel:hold_selection()
  local cur_start = self:get_selection().start
  self:start_selection(cur_start.l, cur_start.c)
  self.selection.held = true
end

function InputModel:release_selection()
  self.selection.held = false
end

function InputModel:get_selection()
  return self.selection
end

function InputModel:get_selected_text()
  return self.selection.text
end

function InputModel:pop_selected_text()
  local t = self.selection.text
  local start = self.selection.start
  local fin = self.selection.fin
  local from, to = self:diff_cursors(start, fin)
  self.entered:traverse(from, to, { delete = true })
  self:text_change()
  self:move_cursor(from.l, from.c)
  self:clear_selection()
  return t
end

function InputModel:clear_selection()
  self.selection = Selection:new()
end

function InputModel:mouse_click(l, c)
  local li, ci = self:translate_grid_to_cursor(l, c)
  self:clear_selection()
  self:start_selection(li, ci)
  self:hold_selection()
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
