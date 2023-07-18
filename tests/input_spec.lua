require("../model/eval")
require("../model/inputModel")


describe("input model spec", function()
  -----------------
  --   ASCII     --
  -----------------
  describe('basics', function()
    local model = InputModel:new()

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
      model:set_text(test1)
      assert.same({ test1 }, model:get_text())
    end)

    it('clears text', function()
      model:clear()
      assert.same({ '' }, model:get_text())
    end)

    it('appends text', function()
      model:set_text(test1)
      assert.same({ test1 }, model:get_text())
    end)

    it('appends characters', function()
      model:add_text(test_char1)
      assert.same(test1 .. test_char1, model:get_current_line())
      model:clear()
      model:add_text(test_char1)
      assert.is_equal(test_char1, model:get_current_line())
      model:add_text(test_char2)
      assert.is_equal(test_char1 .. test_char2,
        model:get_current_line())
    end)
  end)

  -----------------
  --   cursor    --
  -----------------
  describe('cursor', function()
    local model = InputModel:new()
    local test1 = 'text'
    local test_char1 = 'x'

    it('is at base', function()
      assert.same({ '' }, model:get_text())
    end)

    it('advances by one', function()
      model:add_text(test_char1)
      local cl, cc = model:get_cursor_pos()
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
      local cl, cc = model:get_cursor_pos()
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
      local cl, cc = model:get_cursor_pos()
      local ent = model:get_text()
      local ll = #(ent[cl]) -- first line length
      local len = #ent      -- number of lines
      assert.same(1 + ll, cc)
      assert.same(cl, len)
    end)
  end)


  -----------------
  --   UTF-8     --
  -----------------
  describe('handles UTF-8', function()
    local model = InputModel:new()

    local test1 = 'когда'
    local test2 = 'あいうえお'
    local test1_len = utf8.len(test1)
    local test2_len = utf8.len(test2)
    local test_char1 = 'd'
    local test_char2 = 'い'

    it('sets UTF-8 text', function()
      model:set_text(test1)
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
          local _, cc = model:get_cursor_pos()
          assert.is_equal(line_end - 1, cc)
        end)

        it('once again', function()
          model:cursor_left()
          local _, cc = model:get_cursor_pos()
          assert.is_equal(line_end - 2, cc)
        end)

        it('three more times', function()
          model:cursor_left()
          model:cursor_left()
          model:cursor_left()
          local _, cc = model:get_cursor_pos()
          assert.is_equal(base, cc)
        end)

        it('then it stops', function()
          model:cursor_left()
          model:cursor_left()
          model:cursor_left()
          local _, cc = model:get_cursor_pos()
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
        local _, cc = model:get_cursor_pos()
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
    local model = InputModel:new()

    local test1 = 'когда'
    local test2 = 'asdf'
    local test1_len = utf8.len(test1)
    local test2_len = utf8.len(test2)

    describe('deletes', function()
      local line_end = 1 + utf8.len(test2)
      it('none at the end', function()
        model:set_text(test2)
        local cc = model:get_cursor_x()
        assert.is_equal(line_end, cc)
        model:delete()
        assert.same({ test2 }, model:get_text())
      end)

      it('one', function()
        model:retreat_cursor()
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
          model:retreat_cursor()
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
      local line_end = utf8.len(test1)
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
        local res = 'когда'
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
          local _, cc = model:get_cursor_pos()
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
    local model = InputModel:new()
    local test1 = 'first\nsecond'
    local test1_l1 = 'first'
    local test2 = 'когда\nброжу'
    local test2_l1 = 'когда'
    local test2_l2 = 'брожу'
    local test1_l2 = 'second'
    local char1 = 'a'
    local char2 = 'd'
    local test3 = '1st\n2nd\n3rd'
    local test3_l1 = '1st'
    local test3_l2 = '2nd'
    local test3_l3 = '3rd'

    it('paste two', function()
      model:add_text(test1)
      assert.same({
        test1_l1,
        test1_l2,
      }, model:get_text())
    end)

    it('paste UTF-8', function()
      model:clear()
      model:add_text(test2)
      assert.same({
        test2_l1,
        test2_l2,
      }, model:get_text())
    end)

    it('paste into existing', function()
      model:clear()
      model:add_text(char1)
      model:add_text(char2)
      model:cursor_left(char2)
      model:add_text(test2)
      assert.same({
        char1 .. test2_l1,
        test2_l2 .. char2,
      }, model:get_text())
    end)

    it('paste more than two', function()
      model:clear()
      model:add_text(char1)
      model:add_text(test3)
      assert.same({
        char1 .. test3_l1,
        test3_l2,
        test3_l3,
      }, model:get_text())
    end)
  end)



  describe('', function()
    it('', function()
    end)
  end)
end)
