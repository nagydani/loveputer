local utf8 = require("utf8")

require("model/textEval")
require("model/luaEval")
require("util/dequeue")
require("util/string")

require("util/debug")

InputText = {}
function InputText:new(values)
  local text = Dequeue:new(values)
  if not values then text:append('') end
  -- if values then print(Debug.text_table(values or {})) end
  return text
end

InputModel = {}

function InputModel:new(cfg)
  local textEval = TextEval:new()
  local luaEval = LuaEval:new('metalua')
  local im = {
    entered = InputText:new(),
    history = Dequeue:new(),
    evaluator = luaEval,
    textEval = textEval,
    luaEval = luaEval,
    cursor = { c = 1, l = 1 },
    wrap = cfg.drawableChars,
  }
  setmetatable(im, self)
  self.__index = self

  return im
end

function InputModel:_remember(input)
  if string.is_non_empty_string_array(input) then
    self.history:append(input)
  end
end

function InputModel:add_text(text)
  if type(text) == 'string' then
    local sl, cc = self:get_cursor_pos()
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
  local cl, cc = self:get_cursor_pos()
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

function InputModel:_get_current_line()
  local cl = self:get_cursor_y() or 1
  return self.entered:get(cl)
end

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
  local cur_l, cur_c = self:get_cursor_pos()
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

function InputModel:move_cursor(y, x)
  -- TODO: bounds checks
  local cl, cc = self:get_cursor_pos()
  self.cursor = {
    c = x or cc,
    l = y or cl
  }
end

function InputModel:paste(text)
  self:add_text(text)
end

function InputModel:backspace()
  local line = self:_get_current_line()
  local cl, cc = self:get_cursor_pos()
  local newcl = cl - 1
  local pre, post

  local n = self:get_n_text_lines()

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
  local cl, cc = self:get_cursor_pos()
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

function InputModel:get_cursor_pos()
  return self.cursor.l, self.cursor.c
end

function InputModel:get_cursor_x()
  return self.cursor.c
end

function InputModel:get_cursor_y()
  return self.cursor.l
end

function InputModel:cursor_vertical_move(dir)
  local cl, cc = self:get_cursor_pos()
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
  local cl, cc = self:get_cursor_pos()
  if cc > 1 then
    local next = cc - 1
    self.cursor.c = next
  elseif cl > 1 then
    local cpl = cl - 1
    local pl = self:get_text_line(cpl)
    local cpc = 1 + string.ulen(pl)
    self.cursor.l = cpl
    self.cursor.c = cpc
  end
end

function InputModel:cursor_right()
  local cl, cc = self:get_cursor_pos()
  local line = self:get_text_line(cl)
  local len = string.ulen(line)
  local next = cc + 1
  if cc <= len then
    self.cursor.c = next
  elseif cl < self:get_n_text_lines() then
    self:move_cursor(cl + 1, 1)
  end
end

function InputModel:clear()
  self.entered = InputText:new()
  self:_update_cursor(true)
  self.historic_index = nil
  self.tokens = nil
end

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
      end
    else
      self:clear()
    end
  end
  return ok, result
end

function InputModel:text_change()
  local ev = self.evaluator
  if ev.kind == 'lua' then
    local ts = ev.parser.tokenize(self:get_text())
    self.tokens = ts
  end
end

function InputModel:get_eval_error(errors)
  local ev = self.evaluator
  if ev.kind == 'lua' then
    return ev.parser.get_error(errors)
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

function InputModel:jump_home()
  self.cursor = { c = 1, l = 1 }
end

function InputModel:jump_end()
  local ent = self:get_text()
  local last_line = #ent
  local last_char = string.ulen(ent[last_line]) + 1
  self.cursor = { c = last_char, l = last_line }
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

function InputModel:test_lua_eval()
  local le = self.luaEval
  local ok, res = le.apply({
    'for i=1, 5',
    'print(i)',
    'end',
  })
  print('eval ' .. (function()
    if ok then return 'ok' else return 'no' end
  end)() .. '\n')
end
