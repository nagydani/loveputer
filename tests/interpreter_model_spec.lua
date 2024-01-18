require("model.interpreter.interpreterModel")

if not orig_print then
  _G.orig_print = function() end
end

describe("interpreter model spec #interpreter", function()
  local mockConf = {
    view = {},
    drawableChars = 80,
  }

  describe('basics', function()
    local model = InterpreterModel:new(mockConf)

    it('initializes', function()
      assert.are.equal(getmetatable(model), InterpreterModel)
    end)
  end)

  ----------------------
  -- Very long lines  --
  ----------------------
  -- describe('very long lines', function()
  --   local cfg = {
  --     drawableChars = 80,
  --   }
  --   local model = InterpreterModel:new(cfg)
  --   local w = cfg.drawableChars
  --   local n_char = w * 2 + 4
  --   local char1 = 'щ'
  --   describe('cursor and history', function()
  --     for _ = 1, n_char do
  --       model.input:add_text(char1)
  --     end
  --     local cl0, cc0 = model.input:_get_cursor_pos()
  --     assert.same(1, cl0)
  --     assert.same(n_char + 1, cc0)
  --     it('moves up inside long line', function()
  --       model.input:cursor_vertical_move('up')
  --       model.input:cursor_vertical_move('up')
  --       local cl, cc = model.input:_get_cursor_pos()
  --       assert.same(1, cl)
  --       assert.same(n_char + 1 - w, cc)
  --       model.input:cursor_vertical_move('up')
  --       cl, cc = model.input:_get_cursor_pos()
  --       assert.same(1, cl)
  --       assert.same(n_char + 1 - w - w, cc)
  --       -- -- history action
  --       -- model:cursor_vertical_move('up')
  --       -- cl, cc = model:_get_cursor_pos()
  --       -- assert.same(1, cl)
  --       -- assert.same(1, cc)
  --     end)
  --     it('moves down inside long line', function()
  --       -- -- history action
  --       -- model:cursor_vertical_move('down')
  --       model.input:jump_home()
  --       local cl, cc = model.input:_get_cursor_pos()
  --       assert.same(1, cl)
  --       assert.same(1, cc)
  --       model.input:cursor_vertical_move('down')
  --       cl, cc = model.input:_get_cursor_pos()
  --       assert.same(1, cl)
  --       assert.same(1 + w, cc)
  --       model.input:cursor_vertical_move('down')
  --       cl, cc = model.input:_get_cursor_pos()
  --       assert.same(1, cl)
  --       assert.same(1 + w + w, cc)
  --       -- history action
  --       model.input:cursor_vertical_move('down')
  --       cl, cc = model.input:_get_cursor_pos()
  --       assert.same(1, cl)
  --       assert.same(1, cc)
  --     end)

  --     model:cancel()
  --     assert.same({ '' }, model:get_entered_text())
  --     it('moves up in history on first line', function()
  --       model.input:cursor_vertical_move('up')
  --       local cl, cc = model.input:_get_cursor_pos()
  --       assert.same(1, cl)
  --       assert.same(n_char + 1, cc)
  --       model.input:cursor_vertical_move('up')
  --     end)
  --     it('moves down in history on last line', function()
  --       local t2 = 'text2 Привет'
  --       model:cancel()
  --       model.input:add_text(t2)
  --       model:history_back()
  --       local cl, cc = model.input:_get_cursor_pos()
  --       assert.same(1, cl)
  --       assert.same(n_char + 1, cc)
  --       model.input:cursor_vertical_move('down') -- should result in history_fwd
  --       assert.same({ t2 }, model:get_entered_text())
  --       cl, cc = model.input:_get_cursor_pos()
  --       assert.same(1, cl)
  --       assert.same(string.ulen(t2) + 1, cc)
  --     end)
  --   end)
  -- end)

  -- -----------------
  -- --   History   --
  -- -----------------
  -- describe('history', function()
  --   local model = InterpreterModel:new(mockConf)
  --   local test1_l1 = 'first'
  --   local test1_l2 = 'second'

  --   it('keeps entries', function()
  --     model.input:add_text(test1_l1)
  --     model:evaluate()
  --     local he = model:_get_history_entries()
  --     assert.same({ test1_l1 }, he[1])
  --     assert.same({ { test1_l1 } }, he)
  --     local h1 = model:_get_history_entry(1)
  --     assert.same(test1_l1, h1[1])

  --     model:cancel()
  --     model.input:add_text(test1_l2)
  --     model.input:cursor_vertical_move('up')
  --     local t = model:get_entered_text()
  --     assert.same({ test1_l1 }, t)
  --   end)

  --   local test2 = 'Вкусив историй тёмных вкус\nВ ночи слетающих из уст'
  --   local test2_l1 = 'Вкусив историй тёмных вкус'
  --   local test2_l2 = 'В ночи слетающих из уст'
  --   it('pages history down', function()
  --     model.input:cursor_vertical_move('down')
  --     model.input:cursor_vertical_move('down')
  --     local t = model:get_entered_text()
  --     assert.same({ '' }, t) -- next is empty
  --   end)
  --   it('pages history up', function()
  --     model.input:cursor_vertical_move('up')
  --     local t = model:get_entered_text()
  --     orig_print(Debug.terse_t(t))
  --     local cl, cc = model.input:_get_cursor_pos()
  --     local ent = model:get_entered_text()
  --     local len = #ent                 -- number of lines
  --     local ll = string.ulen(ent[len]) -- last line length
  --     -- assert.same({ test2_l1, test2_l2 }, t) -- brings it back
  --     -- assert.same(cc, 1 + string.ulen(test2_l2))
  --     -- assert.same(1 + ll, 1 + string.ulen(test2_l2))
  --     -- assert.same(cl, #string.lines(test2))
  --   end)
  --   -- TODO: test traversal
  -- end)
end)
