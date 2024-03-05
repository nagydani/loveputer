require("util.dequeue")
require("util.string")
require("util.view")
local Terminal = require("lib.terminal")

local G = love.graphics

--- @class CanvasModel
--- @field terminal table
--- @field canvas love.Canvas
--- @field cfg table
--- @field write function
--- @field push function
--- @field reset function
--- @field update function
--- @field get_canvas function
--- @field draw_to function
--- @field restore_main function
CanvasModel = {}
CanvasModel.__index = CanvasModel

setmetatable(CanvasModel, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

function CanvasModel.new(cfg)
  local w, h
  if cfg.sizedebug then
    w = cfg.debugwidth * cfg.fw
    h = cfg.debugheight * cfg.fh
  else
    w = cfg.view.w
    h = ViewUtils.get_drawable_height(cfg.view)
  end
  local canvas = love.graphics.newCanvas(w, cfg.view.h)
  local custom_height = cfg.view.fh * cfg.view.lh
  local term = Terminal(w, h, cfg.view.font, nil, custom_height)

  local color = cfg.view.colors.terminal
  term:hide_cursor()
  term:set_cursor_color(unpack(color.fg))
  term:set_cursor_backcolor(unpack(color.bg))
  term:clear()
  local t_canvas = term.canvas
  local self = setmetatable({
    terminal = term,
    canvas = canvas,
    term_canvas = t_canvas,
    cfg = cfg,
  }, CanvasModel)

  return self
end

function CanvasModel:write(text)
  if string.is_non_empty_string(text) then
    self.terminal:print(text)
  end
end

function CanvasModel:push(newResult)
  if type(newResult) == 'table' then
    local t = string.join(newResult, '\n')
    self:write(t)
  else
    self:write(tostring(newResult) .. '\n')
  end
end

function CanvasModel:reset()
  self.terminal:clear()
  self.terminal:move_to(1, 1)
end

function CanvasModel:invalidate_terminal()
  self.terminal:redraw()
end

function CanvasModel:update(dt)
  self.terminal:update(dt)
end

function CanvasModel:get_canvas()
  return self.canvas
end

function CanvasModel:draw_to()
  G.setCanvas(self.canvas)
end

function CanvasModel:restore_main()
  G.setCanvas()
end
