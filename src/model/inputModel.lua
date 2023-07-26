local utf8 = require("utf8")

require("model/textEval")
require("util/dequeue")
require("util/string")

require("util/debug")

InputModel = {}

function InputModel:new()
  local im = {
    entered = { '' },
    history = Dequeue:new(),
    evaluator = TextEval:new(),
    cursor = { c = 1, l = 1 },
  }
  setmetatable(im, self)
  self.__index = self

  return im
end

function InputModel:remember(input)
  if string.is_non_empty_string_array(input) then
    self.history:push(input)
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
      self:set_text_line(nval, sl, true)
      self:advance_cursor(string.ulen(text))
    else
      for k, line in ipairs(lines) do
        if k == 1 then
          local nval = pre .. line
          self:set_text_line(nval, sl, true)
          -- self:advance_cursor(0, 1)
        elseif k == n_added then
          local nval = line .. post
          local last_line_i = sl + k - 1
          self:set_text_line(nval, last_line_i, true)
          self:move_cursor(last_line_i, string.ulen(line) + 1)
        else
          self:insert_text_line(line, sl + k - 1)
        end
        -- local last_len = string.ulen(lines[n_added])
      end
    end
  end
end

function InputModel:set_text(text, keep_cursor)
  if type(text) == 'string' then
    local lines = string.lines(text)
    local n_added = #lines
    if n_added == 1 then
      self.entered = { text }
    else
    end
    if not keep_cursor then
      self:update_cursor(true)
    end
  elseif type(text) == 'table' then
    self.entered = text
  end
  self:jump_end()
end

function InputModel:set_text_line(text, ln, keep_cursor)
  if type(text) == 'string' then
    -- TODO: multiline
    self.entered[ln] = text
    if not keep_cursor then
      self:update_cursor(true)
    end
  end
end

function InputModel:insert_text_line(text, li)
  local l = li or self:get_cursor_y()
  local old = self.entered
  self.cursor.y = l + 1
  return table.insert(old, l, text)
end

function InputModel:line_feed()
  local cl, cc = self:get_cursor_pos()
  local cur_line = self:get_text_line(cl)
  local pre, post = string.split_at(cur_line, cc)
  self:set_text_line(pre, cl, true)
  self:insert_text_line(post, cl + 1)
  self:move_cursor(cl + 1, 1)
end

function InputModel:get_text()
  return self.entered or { '' }
end

function InputModel:get_text_line(l)
  return self.entered[l]
end

function InputModel:get_n_text_lines()
  return #self.entered
end

function InputModel:get_current_line()
  local cl = self:get_cursor_y() or 1
  return self.entered[cl]
end

function InputModel:update_cursor(replace_line)
  local cl = self:get_cursor_y()
  local t = self:get_text()
  if replace_line then
    self.cursor.c = string.ulen(t[cl]) + 1
    self.cursor.l = #t
  else

  end
end

function InputModel:advance_cursor(x, y)
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
  self.cursor = { c = x, l = y }
end

function InputModel:paste(text)
  self:add_text(text)
end

function InputModel:backspace()
  local line = self:get_current_line()
  local cl, cc = self:get_cursor_pos()
  if cc == 1 then
    -- TODO: multiline
    if cl == 1 then return end
  end

  local pre = StringUtils.utf8_sub(line, 1, cc - 2)
  local post = StringUtils.utf8_sub(line, cc)
  local nval = pre .. post
  self:set_text_line(nval, cl, true)
  self:cursor_left()
end

function InputModel:delete()
  local line = self:get_current_line()
  local cl, cc = self:get_cursor_pos()
  -- TODO: multiline
  local pre = StringUtils.utf8_sub(line, 1, cc - 1)
  local post = StringUtils.utf8_sub(line, cc + 1)
  local nval = pre .. post
  self:set_text_line(nval, cl, true)
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

-- TODO: refractor these into a single function
function InputModel:cursor_up()
  local cl, cc = self:get_cursor_pos()
  if cl > 1 then
    local nl = cl - 1
    local target_line = self:get_text_line(nl)
    local newc = math.min(cc, 1 + string.ulen(target_line))
    self:move_cursor(nl, newc)
  else
    self:history_back()
  end
end

function InputModel:cursor_down()
  local cl, cc = self:get_cursor_pos()
  local n = self:get_n_text_lines()
  if cl < n then
    local nl = cl + 1
    local target_line = self:get_text_line(nl)
    local newc = math.min(cc, 1 + string.ulen(target_line))
    self:move_cursor(nl, newc)
  else
    self:history_fwd()
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
  self:set_text({ '' })
  self:update_cursor(true)
  self.historic_index = nil
end

function InputModel:get_status()
  return {
    input_type = self.evaluator.kind,
    cursor = self.cursor,
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
  local result
  if string.is_non_empty_string_array(ent) then
    self:remember(ent)
    if eval then
      result = self.evaluator.apply(ent)
    end
    self:clear()
  end
  return result
end

function InputModel:history_back()
  local ent = self:get_text()
  if self.historic_index then
    local hi = self.historic_index
    local prev = self.history[hi - 1]
    if prev then
      local current = self:get_text()
      if string.is_non_empty_string_array(current) then
        self.history[hi] = current
      end
      self:set_text(prev)
      local last_line_len = string.ulen(prev[#prev])
      self:move_cursor(#prev, last_line_len + 1)
      self.historic_index = hi - 1
    end
  else
    self.historic_index = self.history:get_last_index()
    self:remember(ent)
    local prev = self.history[self.historic_index] or ''
    self:set_text(prev)
    self:jump_end()
  end
  self:jump_end() -- TODO: remember cursor pos?
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
      self:set_text(next)
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
