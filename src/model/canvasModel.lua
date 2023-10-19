require("util.dequeue")
require("util.string")
local Terminal = require("lib.terminal")

local G = love.graphics

CanvasModel = {}


function CanvasModel:new(cfg)
  local w, h
  if cfg.sizedebug then
    w = cfg.debugwidth * cfg.fw
    h = cfg.debugheight * cfg.fh
  else
    w = G.getWidth() - 2 * cfg.border
    h = cfg.get_drawable_height()
  end
  local canvas = love.graphics.newCanvas(w, h)
  local term = Terminal(w, h, cfg.font_main, nil, cfg.fh * cfg.lh, canvas)

  local color = cfg.colors.terminal
  term:hide_cursor()
  term:set_cursor_color(unpack(color.fg))
  term:set_cursor_backcolor(unpack(color.bg))
  term:clear()
  local cm = {
    terminal = term,
    canvas = canvas,
    cfg = cfg,
  }
  setmetatable(cm, self)
  self.__index = self

  return cm
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
