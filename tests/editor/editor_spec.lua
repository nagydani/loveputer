require("model.editor.editorModel")
require("controller.editorController")
require("view.editor.editorView")
require("view.editor.visibleContent")

local mock = require("tests.mock")

describe('Editor', function()
  local love = {
    state = {
      --- @type AppState
      app_state = 'ready',
    },
    keyboard = {
      isDown = function() return false end
    }
  }
  mock.mock_love(love)
  local turtle_doc = {
    '',
    'Turtle graphics game inspired the LOGO family of languages.',
    '',
  }

  describe('opens', function()
    it('no wrap needed', function()
      local w = 80
      local mockConf = {
        view = {
          lines = 16,
          drawableChars = w,
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
      -- default selection is at the end
      assert.same({ #turtle_doc + 1 }, sel)
      -- and it's an empty line, of course
      assert.same({}, sel_t)
    end)

    describe('with wrap', function()
      local w = 16
      local mockConf = {
        view = {
          lines = 16,
          drawableChars = w,
        },
      }

      local wrapped_turtle = VisibleContent(w, turtle_doc)

      local model = EditorModel(mockConf)
      local controller = EditorController(model)
      local view = EditorView(mockConf.view, controller)

      love.state.app_state = 'editor'
      controller:open('turtle', turtle_doc)
      view.buffer:open(model.buffer)

      --- same as 1
      it('works', function()
        local buffer = controller:get_active_buffer()
        local bc = buffer:get_content()

        assert.same(turtle_doc, bc)
        assert.same(#turtle_doc, buffer:get_content_length())

        local sel = buffer:get_selection()
        local sel_t = buffer:get_selected_text()
        -- default selection is at the end
        assert.same({ #turtle_doc + 1 }, sel)
        -- and it's an empty line, of course
        assert.same({}, sel_t)
      end)

      --- additional tests
      it('', function()
        -- select middle line
        controller:keypressed('up')
        controller:keypressed('up')
        assert.same({ turtle_doc[2] }, model.buffer:get_selected_text())
        -- load it
        local input = function()
          return controller.input:get_input().text
        end
        controller:keypressed('escape')
        assert.same({ turtle_doc[2] }, input())
        -- moving selection clears input
        controller:keypressed('down')
        assert.same({ '' }, input())
        -- add text
        controller:textinput('t')
        assert.same({ 't' }, input())
        controller:textinput('e')
        controller:textinput('s')
        controller:textinput('t')
        assert.same({ 'test' }, input())
      end)
    end)
  end)
end)
