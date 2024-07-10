require("view.input.inputView")

--- @class InterpreterView
--- @field cfg ViewConfig
--- @field controller ConsoleController
--- @field input InputView
InterpreterView = {}
InterpreterView.__index = InterpreterView

setmetatable(InterpreterView, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

--- @param cfg ViewConfig
--- @param ctrl ConsoleController
function InterpreterView.new(cfg, ctrl)
  local self = setmetatable({
    cfg = cfg,
    controller = ctrl,
    input = InputView.new(cfg, ctrl.input),
  }, InterpreterView)

  return self
end

--- @param input InputDTO
function InterpreterView:draw(input)
  local vd = self.controller:get_viewdata()
  local time = self.controller:get_timestamp()

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
      local breaks = #err_text - 1
      ViewUtils.write_line(l, str, start_y, breaks, self.cfg)
    end
  else
    self.input:draw(input, time)
  end
end;
