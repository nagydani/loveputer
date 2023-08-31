require("model.input.inputModel")

if not orig_print then
  _G.orig_print = function() end
end

describe("input model spec #input", function()
  local mockConf = {
    drawableChars = 80,
  }

  -----------------
  --   ASCII     --
  -----------------
  describe('basics', function()
    local model = InputModel:new(mockConf)

    it('initializes', function()
      assert.are.equal(getmetatable(model), InputModel)
    end)
    local test1 = 'asdf'
    local test_char1 = 'd'
    local test_char2 = 'n'

    it('is empty at first', function()
      assert.same({ '' }, model:get_text())
    end)

    it('sets text', function()
      model:_set_text(test1)
      local t = model:get_text()
      assert.same({ test1 }, t)
    end)

    it('clears text', function()
      model:clear()
      assert.same({ '' }, model:get_text())
    end)

    it('appends text', function()
      model:_set_text(test1)
      assert.same({ test1 }, model:get_text())
    end)

    it('appends characters', function()
      model:add_text(test_char1)
      assert.same(test1 .. test_char1, model:_get_current_line())
      model:clear()
      model:add_text(test_char1)
      assert.is_equal(test_char1, model:_get_current_line())
      model:add_text(test_char2)
      assert.is_equal(test_char1 .. test_char2,
        model:_get_current_line())
    end)
  end)

  -----------------
  --   cursor    --
  -----------------
  describe('cursor', function()
    local model = InputModel:new(mockConf)
    local test1 = 'text'
    local test_char1 = 'x'

    it('is at base', function()
      assert.same({ '' }, model:get_text())
    end)

    it('advances by one', function()
      model:add_text(test_char1)
      local cl, cc = model:_get_cursor_pos()
      assert.same(2, cc)
      assert.same(1, cl)
    end)

    it('returns on backspace', function()
      model:backspace()
      assert.is_equal(1, model:get_cursor_x())
    end)

    it('advances by multiple', function()
      model:add_text(test1)
      assert.is_equal(1 + #test1, model:get_cursor_x())
    end)

    it('moves forward', function()
      model:cursor_right()
      model:cursor_right()
      assert.same(1 + #test1, model:get_cursor_x())
    end)

    it("doesn't move forward at the end", function()
      model:cursor_right()
      model:cursor_right()
      assert.same(1 + #test1, model:get_cursor_x())
    end)

    it("jumps to start on Home", function()
      model:jump_home()
      local cl, cc = model:_get_cursor_pos()
      assert.same(1, cl)
      assert.same(1, cc)
    end)

    it("doesn't move back at the start", function()
      model:cursor_left()
      model:cursor_left()
      assert.same(1, model:get_cursor_x())
    end)

    it("jumps to the end on End", function()
      model:jump_end()
      local cl, cc = model:_get_cursor_pos()
      local ent = model:get_text()
      local ll = #(ent[cl]) -- first line length
      local len = #ent      -- number of lines
      assert.same(1 + ll, 1 + string.ulen(test1))
      assert.same(1 + ll, cc)
      assert.same(cl, len)
    end)
  end)


  -----------------
  --   UTF-8     --
  -----------------
  describe('handles UTF-8', function()
    local model = InputModel:new(mockConf)

    local test1 = 'когда'
    local test2 = 'あいうえお'
    local test1_len = utf8.len(test1)
    local test2_len = utf8.len(test2)
    local test_char1 = 'd'
    local test_char2 = 'い'

    it('sets UTF-8 text', function()
      model:_set_text(test1)
      assert.same({ test1 }, model:get_text())
      assert.is_equal(1 + test1_len, model:get_cursor_x())
    end)

    it('clears text', function()
      model:clear()
      assert.same({ '' }, model:get_text())
    end)

    it('appends text', function()
      model:add_text(test1)
      assert.same({ test1 }, model:get_text())
    end)

    describe('appends', function()
      model:add_text(test_char2)
      it('UTF-8 characters', function()
        assert.same({ test1 .. test_char2 }, model:get_text())
      end)

      it('ASCII characters', function()
        model:backspace()
        assert.same({ test1 }, model:get_text())
        model:add_text(test_char1)
        assert.same({ test1 .. test_char1 }, model:get_text())
      end)
    end)

    local line_end = 1 + utf8.len(test2)
    local base = line_end - utf8.len(test2)
    describe('moves cursor correctly', function()
      it('', function()
        model:clear()
        model:add_text(test2)
        assert.same({ test2 }, model:get_text())
        local cc = model:get_cursor_x()
        assert.is_equal(line_end, cc)
      end)

      describe('backwards', function()
        it('once', function()
          model:cursor_left()
          local _, cc = model:_get_cursor_pos()
          assert.is_equal(line_end - 1, cc)
        end)

        it('once again', function()
          model:cursor_left()
          local _, cc = model:_get_cursor_pos()
          assert.is_equal(line_end - 2, cc)
        end)

        it('three more times', function()
          model:cursor_left()
          model:cursor_left()
          model:cursor_left()
          local _, cc = model:_get_cursor_pos()
          assert.is_equal(base, cc)
        end)

        it('then it stops', function()
          model:cursor_left()
          model:cursor_left()
          model:cursor_left()
          local _, cc = model:_get_cursor_pos()
          assert.is_equal(base, cc)
        end)
      end)
    end)

    describe('forward', function()
      it('once', function()
        model:cursor_right()
        local cc = model:get_cursor_x()
        assert.is_equal(base + 1, cc)
      end)
      it('three more times', function()
        model:cursor_right()
        model:cursor_right()
        model:cursor_right()
        local cc = model:get_cursor_x()
        assert.is_equal(base + 4, cc)
      end)
    end)

    describe('jumps', function()
      it('to the end', function()
        model:jump_end()
        local cc = model:get_cursor_x()
        assert.is_equal(line_end, cc)
      end)

      it("then doesn't step more", function()
        model:cursor_right()
        model:cursor_right()
        model:cursor_right()
        local _, cc = model:_get_cursor_pos()
        assert.is_equal(line_end, cc)
      end)

      it('to the start', function()
        model:jump_home()
        local cc = model:get_cursor_x()
        assert.is_equal(base, cc)
      end)
    end)
  end)

  -----------------
  --   Del/Bksp  --
  -----------------
  describe('delete and backspace', function()
    local model = InputModel:new(mockConf)

    local test1 = 'когда'
    local test2 = 'asdf'
    local test1_len = utf8.len(test1)
    local test2_len = utf8.len(test2)

    describe('deletes', function()
      local line_end = 1 + utf8.len(test2)
      it('none at the end', function()
        model:_set_text(test2)
        local cc = model:get_cursor_x()
        assert.is_equal(line_end, cc)
        model:delete()
        assert.same({ test2 }, model:get_text())
      end)

      it('one', function()
        model:cursor_left()
        model:delete()
        local cc = model:get_cursor_x()
        assert.is_equal(line_end - 1, cc)
        assert.same({ string.sub(test2, 1, line_end - 2) },
          model:get_text())
      end)

      it('all', function()
        local cl = model:get_cursor_y()
        local ll = #(model:get_text()[cl])
        for i = 1, ll do
          model:cursor_left()
        end
        local cc = model:get_cursor_x()
        assert.is_equal(1, cc)
        for i = 1, ll do
          model:delete()
        end
        assert.same({ '' }, model:get_text())
      end)
    end)

    describe('moves cursor correctly', function()
      it('', function()
        model:clear()
        model:add_text(test1)
        assert.same({ test1 }, model:get_text())
        model:cursor_left()
        model:cursor_left()
        local cc = model:get_cursor_x()
        assert.is_equal(1 + test1_len - 2, cc)
      end)

      describe('backwards', function()
        it('deletes', function()
          model:delete()
          assert.same({ 'кога' }, model:get_text())
        end)

        it('does backspace', function()
          model:backspace()
          assert.same({ 'коа' }, model:get_text())
        end)

        it('jumps home', function()
          model:jump_home()
          local cc = model:get_cursor_x()
          assert.is_equal(1, cc)
        end)

        it('deletes', function()
          model:delete()
          assert.same({ 'оа' }, model:get_text())
        end)

        it('jumps to the end', function()
          model:jump_end()
          local pos = utf8.len('оа') + 1
          local _, cc = model:_get_cursor_pos()
          assert.is_equal(pos, cc)
        end)

        it('does backspace', function()
          model:backspace()
          assert.same({ 'о' }, model:get_text())
        end)
      end)
    end)
  end)

  -----------------
  --  Multiline  --
  -----------------
  describe('handles multiline', function()
    local model = InputModel:new(mockConf)
    local test1 = 'first\nsecond'
    local test1_l1 = 'first'
    local test1_l2 = 'second'
    local test2 = 'когда\nброжу'
    local test2_l1 = 'когда'
    local test2_l2 = 'брожу'
    local char1 = 'a'
    local char2 = 'd'
    local test3 = '1st\n2nd\n3rd'
    local test3_l1 = '1st'
    local test3_l2 = '2nd'
    local test3_l3 = '3rd'

    it('pastes two', function()
      model:add_text(test1)
      assert.same({
        test1_l1,
        test1_l2,
      }, model:get_text())
      local cl, cc = model:_get_cursor_pos()
      assert.same(2, cl)
      assert.same(1 + string.ulen(test1_l2), cc)
    end)

    it('pastes UTF-8', function()
      model:clear()
      model:add_text(test2)
      assert.same({
        test2_l1,
        test2_l2,
      }, model:get_text())
      local cl, cc = model:_get_cursor_pos()
      assert.same(2, cl)
      assert.same(1 + string.ulen(test2_l2), cc)
    end)

    it('pastes into existing', function()
      model:clear()
      model:add_text(char1)
      model:add_text(char2)
      model:cursor_left()
      model:add_text(test2)
      assert.same({
        char1 .. test2_l1,
        test2_l2 .. char2,
      }, model:get_text())
      local cl, cc = model:_get_cursor_pos()
      assert.same(2, cl)
      assert.same(1 + string.ulen(test2_l2), cc)
    end)

    it('pastes more than two lines', function()
      model:clear()
      model:add_text(char1)
      model:add_text(test3)
      assert.same({
        char1 .. test3_l1,
        test3_l2,
        test3_l3,
      }, model:get_text())
    end)

    it('enters newline', function()
      model:clear()
      model:add_text(char1)
      model:add_text(char2)
      model:cursor_left()
      model:line_feed()
      assert.same({
        char1,
        char2,
      }, model:get_text())
      model:line_feed()
      assert.same({
        char1,
        '',
        char2,
      }, model:get_text())
    end)
    it('enters newline in UTF-8 text', function()
      model:clear()
      model:add_text(test2_l1)
      model:cursor_left()
      model:cursor_left()
      model:line_feed()
      assert.same({
        'ког',
        'да',
      }, model:get_text())
    end)
  end)
  --   cursor    --
  describe('multiline cursor', function()
    local model = InputModel:new(mockConf)
    local test1 = 'first\nsecond'
    local test1_l1 = 'first'
    local test1_l2 = 'second'

    local test2 = 'Вкусив историй тёмных вкус\nВ ночи слетающих из уст'
    local test2_len = 2
    local test2_l1 = 'Вкусив историй тёмных вкус'
    local test2_l2 = 'В ночи слетающих из уст'

    local test3 = 'Вселяя\nстрах'
    local test3_len = 2
    local test3_l1 = 'Вселяя'
    local test3_l2 = 'страх'

    it("jumps to start on [Home]", function()
      model:add_text(test1)
      model:jump_home()
      local cl, cc = model:_get_cursor_pos()
      assert.same(1, cl)
      assert.same(1, cc)
    end)

    it("doesn't move back at the start", function()
      model:cursor_left()
      model:cursor_left()
      assert.same(1, model:get_cursor_x())
      assert.same(1, model:get_cursor_y())
    end)

    it("jumps to the end on [End]", function()
      model:jump_end()
      local cl, cc = model:_get_cursor_pos()
      local ent = model:get_text()
      local len = #ent                 -- number of lines
      local ll = string.ulen(ent[len]) -- last line length
      assert.same(1 + ll, cc)
      assert.same(cl, len)
      assert.same(1 + ll, 1 + string.ulen(test1_l2))
      assert.same(cl, #string.lines(test1))
    end)

    -- UTF-8
    it("UTF-8 jumps to start on Home", function()
      model:clear()
      model:add_text(test2)
      model:jump_home()
      local cl, cc = model:_get_cursor_pos()
      assert.same(1, cl)
      assert.same(1, cc)
    end)

    it("UTF-8 doesn't move back at the start", function()
      model:cursor_left()
      model:cursor_left()
      assert.same(1, model:get_cursor_x())
      assert.same(1, model:get_cursor_y())
    end)

    it("UTF-8 jumps to the end on End", function()
      model:jump_end()
      local cl, cc = model:_get_cursor_pos()
      local ent = model:get_text()
      local len = #ent                 -- number of lines
      local ll = string.ulen(ent[len]) -- last line length
      assert.same(1 + ll, cc)
      assert.same(cl, len)
      assert.same(cl, test2_len)
      assert.same(cc, 1 + string.ulen(test2_l2))
      assert.same(1 + ll, 1 + string.ulen(test2_l2))
      assert.same(cl, #string.lines(test2))
    end)

    it('moves up', function()
      model:cursor_vertical_move('up')
      local cl, cc = model:_get_cursor_pos()
      assert.same(cl, test2_len - 1) -- second last row ( in this case, first )
      assert.same(1 + math.min(
        string.ulen(test2_l2),
        string.ulen(test2_l1)
      ), cc)
    end)
    it('moves down', function()
      model:jump_home()
      model:cursor_vertical_move('down')
      local cl, cc = model:_get_cursor_pos()
      assert.same(cl, 2)         -- second row
      assert.same(cl, test2_len) -- same as last
      assert.same(cc, 1)         -- first char
    end)

    it('pages history down', function()
      model:cursor_vertical_move('down')
      local t = model:get_text()
      assert.same({ '' }, t) -- next is empty
    end)
    it('pages history up', function()
      model:cursor_vertical_move('up')
      local t = model:get_text()
      local cl, cc = model:_get_cursor_pos()
      local ent = model:get_text()
      local len = #ent                       -- number of lines
      local ll = string.ulen(ent[len])       -- last line length
      assert.same({ test2_l1, test2_l2 }, t) -- brings it back
      assert.same(cc, 1 + string.ulen(test2_l2))
      assert.same(1 + ll, 1 + string.ulen(test2_l2))
      assert.same(cl, #string.lines(test2))
    end)

    it('traverses over line breaks', function()
      model:jump_home()
      model:cursor_vertical_move('down')
      local cl1, cc1 = model:_get_cursor_pos()
      assert.same(cl1, 2)
      assert.same(cc1, 1)
      model:cursor_left()
      local cl2, cc2 = model:_get_cursor_pos()
      assert.same(cl2, 1)
      assert.same(cc2, 1 + string.ulen(test2_l1))

      model:clear()
      model:add_text(test3)
      model:jump_end()
      local cl3, cc3 = model:_get_cursor_pos()
      assert.same(cl3, test3_len)
      assert.same(cc3, 1 + string.ulen(test3_l2))
      model:cursor_vertical_move('up')
      local cl4, cc4 = model:_get_cursor_pos()
      assert.same(cl4, test3_len - 1)
      assert.same(1 + math.min(
        string.ulen(test3_l2),
        string.ulen(test3_l1)
      ), cc4)
      model:cursor_right() -- to line end
      model:cursor_right() -- wrap to next line
      local cl5, cc5 = model:_get_cursor_pos()
      assert.same(cl5, test3_len)
      assert.same(cc5, 1)
    end)
  end)

  --   Del/Bksp  --
  describe('multiline delete', function()
    local model = InputModel:new(mockConf)
    local test1 = 'firstsecond'
    local test1_l1 = 'first'
    local test1_l2 = 'second'
    it('forward', function()
      model:add_text(test1_l1)
      model:line_feed()
      model:add_text(test1_l2)
      model:cursor_vertical_move('up')
      model:delete()
      local res = model:get_text()
      assert.same({ test1 }, res)
      model:jump_end()
      model:delete()
      model:delete()
      res = model:get_text()
      assert.same({ test1 }, res)
    end)
    it('backward', function()
      model:clear()
      model:add_text(test1_l1)
      model:line_feed()
      model:add_text(test1_l2)
      model:jump_home()
      model:cursor_vertical_move('down')
      model:backspace()
      local res = model:get_text()
      assert.same({ test1 }, res)
      model:jump_home()
      model:backspace()
      model:backspace()
      local res = model:get_text()
      assert.same({ test1 }, res)
    end)
  end)

  -----------------
  --   History   --
  -----------------
  describe('history', function()
    local model = InputModel:new(mockConf)
    local test1_l1 = 'first'
    local test1_l2 = 'second'

    it('keeps entries', function()
      model:add_text(test1_l1)
      model:evaluate()
      local he = model:_get_history_entries()
      assert.same({ test1_l1 }, he[1])
      assert.same({ { test1_l1 } }, he)
      local h1 = model:_get_history_entry(1)
      assert.same(test1_l1, h1[1])

      model:cancel()
      model:add_text(test1_l2)
      model:cursor_vertical_move('up')
      local t = model:get_text()
      assert.same({ test1_l1 }, t)
    end)

    -- TODO: test traversing
  end)

  ----------------------
  -- Very long lines  --
  ----------------------
  describe('very long lines', function()
    local cfg = {
      drawableChars = 80,
    }
    local model = InputModel:new(cfg)
    local w = cfg.drawableChars
    local n_char = w * 2 + 4
    local char1 = 'щ'
    describe('cursor and history', function()
      for _ = 1, n_char do
        model:add_text(char1)
      end
      local cl0, cc0 = model:_get_cursor_pos()
      assert.same(1, cl0)
      assert.same(n_char + 1, cc0)
      it('moves up inside long line', function()
        model:cursor_vertical_move('up')
        model:cursor_vertical_move('up')
        local cl, cc = model:_get_cursor_pos()
        assert.same(1, cl)
        assert.same(n_char + 1 - w, cc)
        model:cursor_vertical_move('up')
        cl, cc = model:_get_cursor_pos()
        assert.same(1, cl)
        assert.same(n_char + 1 - w - w, cc)
        -- -- history action
        -- model:cursor_vertical_move('up')
        -- cl, cc = model:_get_cursor_pos()
        -- assert.same(1, cl)
        -- assert.same(1, cc)
      end)
      it('moves down inside long line', function()
        -- -- history action
        -- model:cursor_vertical_move('down')
        model:jump_home()
        local cl, cc = model:_get_cursor_pos()
        assert.same(1, cl)
        assert.same(1, cc)
        model:cursor_vertical_move('down')
        cl, cc = model:_get_cursor_pos()
        assert.same(1, cl)
        assert.same(1 + w, cc)
        model:cursor_vertical_move('down')
        cl, cc = model:_get_cursor_pos()
        assert.same(1, cl)
        assert.same(1 + w + w, cc)
        -- history action
        model:cursor_vertical_move('down')
        cl, cc = model:_get_cursor_pos()
        assert.same(1, cl)
        assert.same(1, cc)
      end)

      model:cancel()
      assert.same({ '' }, model:get_text())
      it('moves up in history on first line', function()
        model:cursor_vertical_move('up')
        local cl, cc = model:_get_cursor_pos()
        assert.same(1, cl)
        assert.same(n_char + 1, cc)
        -- model:cursor_vertical_move('up')
      end)
      it('moves down in history on last line', function()
        local t2 = 'text2 Привет'
        model:cancel()
        model:add_text(t2)
        model:history_back()
        local cl, cc = model:_get_cursor_pos()
        assert.same(1, cl)
        assert.same(n_char + 1, cc)
        model:cursor_vertical_move('down') -- should result in history_fwd
        assert.same({ t2 }, model:get_text())
        cl, cc = model:_get_cursor_pos()
        assert.same(1, cl)
        assert.same(string.ulen(t2) + 1, cc)
      end)
    end)
  end)
end)
