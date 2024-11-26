require("view.input.inputView")

local class = require("util.class")

--- @param cfg ViewConfig
--- @param ctrl InterpreterController
local new = function(cfg, ctrl)
  return {
    cfg = cfg,
    controller = ctrl,
    input = InputView(cfg, ctrl.input),
  }
end

--- @class InterpreterView : ViewBase
--- @field controller InterpreterController
--- @field input InputView
InterpreterView = class.create(new)

--- @param input InputDTO
function InterpreterView:draw(input, time)
  local vd = self.controller:get_viewdata()

  local isError = string.is_non_empty_string_array(vd.w_error)
  local err_text = vd.w_error or {}

  local colors = self.cfg.colors
  local b = self.cfg.border
  local fh = self.cfg.fh
  local h = self.cfg.h

  if isError then
    local drawableWidth = self.cfg.drawableWidth
    -- local drawableChars = self.cfg.drawableChars
    local inLines = #err_text
    local inHeight = inLines * fh
    local apparentHeight = #err_text
    local start_y = h - b - inHeight
    local drawBackground = function()
      G.setColor(colors.input.error_bg)
      G.rectangle("fill",
        b,
        start_y,
        drawableWidth,
        apparentHeight * fh)
    end

    drawBackground()
    G.setColor(colors.input.error)
    for l, str in ipairs(err_text) do
      local breaks = 0 -- starting height is already calculated
      ViewUtils.write_line(l, str, start_y, breaks, self.cfg)
    end
  else
    self.input:draw(input, time)
  end
end
