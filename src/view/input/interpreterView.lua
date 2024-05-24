require("view.input.inputView")

--- @class InterpreterView
--- @field cfg Config
--- @field controller ConsoleController
--- @field input InputView
InterpreterView = {}

function InterpreterView:new(cfg, ctrl)
  local iv = {
    cfg = cfg,
    controller = ctrl,
    input = InputView:new(cfg, ctrl.input),
  }
  setmetatable(iv, self)
  self.__index = self

  return iv
end

--- @param input InputDTO
function InterpreterView:draw(input)
  local vd = self.controller:get_viewdata()
  local time = self.controller:get_timestamp()

  local isError = string.is_non_empty_string_array(vd.w_error)
  local err_text = vd.w_error or {}

  local colors = self.cfg.view.colors
  local b = self.cfg.view.border
  local fh = self.cfg.view.fh
  local h = self.cfg.view.h

  if isError then
    local drawableWidth = self.cfg.view.drawableWidth
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
      ViewUtils.write_line(l, str, { y = start_y, breaks = #err_text - 1 }, self.cfg.view)
    end
  else
    self.input:draw(input, time)
  end
end;
