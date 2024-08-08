--- @diagnostic disable: invisible
require("model.editor.editorModel")
require("controller.editorController")
require("view.editor.editorView")
require("view.editor.visibleContent")

local mock = require("tests.mock")

describe('Editor #editor', function()
  local love = {
    state = {
      --- @type AppState
      app_state = 'ready',
    },
  }
  mock.mock_love(love)
  local turtle_doc = {
    '',
    'Turtle graphics game inspired the LOGO family of languages.',
    '',
  }

  local sierpinski = {
    "function sierpinski(depth)",
    "  lines = { '*' }",
    "  for i = 2, depth + 1 do",
    "    sp, tmp = string.rep(' ', 2 ^ (i - 2))",
    "    tmp = {}",
    "    for idx, line in ipairs(lines) do",
    "      tmp[idx] = sp .. line .. sp",
    "      tmp[idx + #lines] = line .. ' ' .. line",
    "    end",
    "    lines = tmp",
    "  end",
    "  return table.concat(lines, '\n')",
    "end",
    "",
    "print(sierpinski(4))",
  }

  describe('opens', function()
    it('no wrap needed', function()
      local w = 80
      local mockConf = {
        view = {
          drawableChars = w,
          lines = 16,
          input_max = 14
        },
      }

      local model = EditorModel(mockConf)
      local controller = EditorController(model)
      EditorView(mockConf.view, controller)

      controller:open('turtle', turtle_doc)

      local buffer = controller:get_active_buffer()
      local bc = buffer:get_content()

      assert.same(turtle_doc, bc)
      assert.same(#turtle_doc, buffer:get_content_length())

      local sel = buffer:get_selection()
      local sel_t = buffer:get_selected_text()
      --- default selection is at the end
      assert.same(#turtle_doc + 1, sel)
      --- and it's an empty line, of course
      assert.same({}, sel_t)
    end)
  end)

  describe('plaintext works', function()
    describe('with wrap', function()
      local w = 16
      local mockConf = {
        view = {
          drawableChars = w,
          lines = 16,
          input_max = 14
        },
      }

      local model = EditorModel(mockConf)
      local controller = EditorController(model)
      local view = EditorView(mockConf.view, controller)

      love.state.app_state = 'editor'
      controller:open('turtle', turtle_doc)
      view.buffer:open(model.buffer)

      local function press(...)
        controller:keypressed(...)
      end

      local buffer = controller:get_active_buffer()
      local start_sel = #turtle_doc + 1

      it('opens', function()
        local bc = buffer:get_content()

        assert.same(turtle_doc, bc)
        assert.same(#turtle_doc, buffer:get_content_length())

        local sel = buffer:get_selection()
        local sel_t = buffer:get_selected_text()
        --- default selection is at the end
        assert.same(start_sel, sel)
        --- and it's an empty line, of course
        assert.same({}, sel_t)
      end)

      --- additional tests
      it('interacts', function()
        --- select middle line
        mock.keystroke('up', press)
        assert.same(start_sel - 1, buffer:get_selection())
        mock.keystroke('up', press)
        assert.same(start_sel - 2, buffer:get_selection())
        assert.same(turtle_doc[2], model.buffer:get_selected_text())
        --- load it
        local input = function()
          return controller.interpreter:get_text():items()
        end
        mock.keystroke('escape', press)
        assert.same({ turtle_doc[2] }, input())
        --- moving selection clears input
        mock.keystroke('down', press)
        assert.same(start_sel - 1, buffer:get_selection())
        assert.same({ '' }, input())
        --- add text
        controller:textinput('-')
        controller:textinput('-')
        controller:textinput(' ')
        controller:textinput('t')
        controller:textinput('e')
        controller:textinput('s')
        controller:textinput('t')
        assert.same({ '-- test' }, input())
        --- replace line with input content
        mock.keystroke('return', press)
        --- input clears
        assert.same({ '' }, input())
        --- highlight moves down
        assert.same(start_sel, buffer:get_selection())

        mock.keystroke('up', press)
        --- replace
        controller:textinput('i')
        controller:textinput('n')
        controller:textinput('s')
        controller:textinput('e')
        controller:textinput('r')
        controller:textinput('t')
        assert.same({ 'insert' }, input())
        mock.keystroke('escape', press)
        assert.same({ '-- test' }, input())
      end)
    end)


    describe('with scroll', function()
      local l = 6
      local mockConf = {
        view = {
          drawableChars = 80,
          lines = l,
          input_max = 14
        },
      }

      local model = EditorModel(mockConf)
      local controller = EditorController(model)
      local view = EditorView(mockConf.view, controller)

      --- use it as plaintext for this test
      controller:open('sierpinski.txt', sierpinski)
      view.buffer:open(model.buffer)

      local visible = view.buffer.content
      local scroll = view.buffer.SCROLL_BY

      local off = #sierpinski - l + 1
      local start_range = Range(off + 1, #sierpinski + 1)

      it('loads', function()
        --- inital scroll is at EOF, meaning last l lines are visible
        --- plus the phantom line
        assert.same(off, view.buffer.offset)
        assert.same(start_range, visible.range)
      end)
      local base = Range(1, l)
      it('scrolls up', function()
        controller:keypressed('pageup')
        assert.same(start_range:translate(-scroll), visible.range)
        controller:keypressed('pageup')
        assert.same(start_range:translate(-scroll * 2), visible.range)
        controller:keypressed('pageup')
        assert.same(start_range:translate(-scroll * 3), visible.range)
        controller:keypressed('pageup')
      end)
      it('tops out', function()
        assert.same(base, visible.range)
      end)
      it('scrolls down', function()
        controller:keypressed('pagedown')
        assert.same(base:translate(scroll), visible.range)
        controller:keypressed('pagedown')
        assert.same(base:translate(scroll * 2), visible.range)
        controller:keypressed('pagedown')
        assert.same(base:translate(scroll * 3), visible.range)
        controller:keypressed('pagedown')
        assert.same(base:translate(scroll * 4), visible.range)
        controller:keypressed('pagedown')
      end)
      it('bottoms out', function()
        local limit = #sierpinski + visible.overscroll
        assert.same(Range(limit - l + 1, limit), visible.range)
      end)
    end)

    describe('with scroll and wrap', function()
      local l = 6
      local mockConf = {
        view = {
          lines = l,
          drawableChars = 27,
          input_max = 14,
        },
      }

      local model = EditorModel(mockConf)
      local controller = EditorController(model)
      local view = EditorView(mockConf.view, controller)

      controller:open('sierpinski.txt', sierpinski)

      local function press(...)
        controller:keypressed(...)
      end

      local buffer = controller:get_active_buffer()
      --- @type BufferView
      local bv = view.buffer
      bv:open(model.buffer)

      --- @type VisibleContent
      local visible = view.buffer.content
      local scroll = view.buffer.SCROLL_BY

      local clen = visible:get_content_length()
      local off = clen - l + 1
      local start_range = Range(off + 1, clen + 1)
      it('loads', function()
        --- inital scroll is at EOF, meaning last l lines are visible
        --- plus the phantom line
        assert.same(off, view.buffer.offset)
        assert.same(start_range, visible.range)
      end)
      local base = Range(1, l)
      describe('scrolls', function()
        it('scrolls up', function()
          mock.keystroke('pageup', press)
          assert.same(start_range:translate(-scroll), visible.range)
          mock.keystroke('pageup', press)
          assert.same(start_range:translate(-scroll * 2), visible.range)
          mock.keystroke('pageup', press)
          assert.same(start_range:translate(-scroll * 3), visible.range)
          mock.keystroke('pageup', press)
          assert.same(start_range:translate(-scroll * 4), visible.range)
        end)
        it('tops out', function()
          mock.keystroke('pageup', press)
          assert.same(base, visible.range)
        end)
        it('scrolls down', function()
          mock.keystroke('pagedown', press)
          assert.same(base:translate(scroll), visible.range)
          mock.keystroke('pagedown', press)
          assert.same(base:translate(scroll * 2), visible.range)
          mock.keystroke('pagedown', press)
          assert.same(base:translate(scroll * 3), visible.range)
          mock.keystroke('pagedown', press)
          assert.same(base:translate(scroll * 4), visible.range)
          mock.keystroke('pagedown', press)
          assert.same(base:translate(scroll * 5), visible.range)
        end)
        it('bottoms out', function()
          mock.keystroke('pagedown', press)
          mock.keystroke('pagedown', press)
          mock.keystroke('pagedown', press)
          local limit = clen + visible.overscroll
          assert.same(Range(limit - l + 1, limit), visible.range)
        end)

        describe('moving the selection affects scrolling', function()
          local sel = buffer:get_selection()
          local sel_t = buffer:get_selected_text()

          --- default selection is at the end
          assert.same(#sierpinski + 1, sel)
          --- and it's an empty line, of course
          assert.same({}, sel_t)

          it('from below', function()
            mock.keystroke('pageup', press)
            mock.keystroke('up', press)
            --- it's now one above the starting range, the phantom line not visible
            --- assert.same(start_range:translate(-1), visible.range)
            mock.keystroke('pageup', press)
            mock.keystroke('down', press)
            --- after scrolling up and moving the sel back, we are back to the start
            assert.same(start_range, visible.range)
          end)
          it('to above', function()
            local srs = visible.range.start
            --- let's move up a screen's worth with the sel
            for _ = 1, l do
              mock.keystroke('up', press)
            end
            local cs = bv:_get_wrapped_selection()[1][1]
            local d = cs - srs
            assert.same(start_range:translate(d), visible.range)
            mock.keystroke('up', press)
            assert.same(start_range:translate(d - 1), visible.range)
          end)
          it('tops out', function()
            --- move up to the first line
            for _ = 1, clen do
              mock.keystroke('up', press)
            end
            assert.same(base, visible.range)
          end)
          it('from above', function()
            mock.keystroke('pagedown', press)
            mock.keystroke('pagedown', press)
            mock.keystroke('down', press)
            assert.same(base:translate(1), visible.range)
          end)
          it('to below', function()
            for _ = 2, l do
              mock.keystroke('down', press)
            end
            mock.keystroke('pageup', press)
            mock.keystroke('down', press)
            local ws = bv:_get_wrapped_selection()[1]
            local cs = ws[#ws]
            assert.same(Range(cs - l + 1, cs), visible.range)
          end)
          it('bottoms out', function()
            local s = buffer:get_selection()
            for _ = s, #sierpinski do
              mock.keystroke('down', press)
            end
            assert.same(start_range, visible.range)
            mock.keystroke('down', press)
            mock.keystroke('down', press)
            assert.same(start_range, visible.range)
          end)
        end)
      end)

      describe('jumps', function()
        local sel = table.clone(buffer:get_selection())
        it('to top', function()
          mock.keystroke('C-pageup', press)
          --- scrolls to top
          assert.same(base, visible.range)
          --- and selection is unaffected
          assert.same(sel, buffer:get_selection())
        end)
        it('to bottom', function()
          mock.keystroke('C-pagedown', press)
          --- scrolls to bottom
          assert.same(start_range, visible.range)
          --- and selection is unaffected
          assert.same(sel, buffer:get_selection())
        end)
      end)
      describe('warps selection', function()
        mock.keystroke('up', press)
        local sel = table.clone(buffer:get_selection())
        it('to bottom', function()
          mock.keystroke('C-end', press)
          --- warps to bottom
          assert.same(start_range, visible.range)
          assert.is_not.same(sel, buffer:get_selection())
        end)
        it('to top', function()
          mock.keystroke('C-home', press)
          --- warps to top
          assert.same(base, visible.range)
          assert.is_not.same(sel, buffer:get_selection())
        end)
      end)
      describe('input', function()
        --- @type InterpreterController
        local inter = controller.interpreter
        it('loads', function()
          inter:add_text('asd')
          local selected = buffer:get_selected_text()
          mock.keystroke('escape', press)
          --- TODO
          -- assert.same(inter:get_text(), selected[1])
        end)
        it('clears', function()
          mock.keystroke('C-end', press)
          assert.same({ '' }, inter:get_text())
        end)
        it('inserts', function()
          mock.keystroke('up', press)
          local prefix = 'asd '
          local selected = buffer:get_selected_text()
          inter:add_text(prefix)
          mock.keystroke('S-escape', press)
          local res = string.join(inter:get_text())
          assert.same(prefix .. selected, res)
        end)
      end)
    end)
  end)
end)
