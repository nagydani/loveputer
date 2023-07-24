require("util/dequeue")
require("util/string")

local Terminal = require "lib/terminal"

local G = love.graphics

CanvasModel = {}


function CanvasModel:new(cfg)
  local w = G.getWidth() - 2 * cfg.border
  local h = cfg.get_drawable_height() + cfg.fh
  local linesN = math.floor(cfg.get_drawable_height() / cfg.fh)
  local colsN = math.floor(w / cfg.fw)
  local term = Terminal(w, h, cfg.font_main)

  -- term:hide_cursor()
  local cm = {
    terminal = term,
    cfg = cfg,
  }
  setmetatable(cm, self)
  self.__index = self


  cm.background = function()
    G.setColor(cm.terminal.colors.bg)
    G.rectangle("fill", 0, 0, cfg.w, cfg.h)
  end

  return cm
end

function CanvasModel:_manipulate(commands)
  self.canvas:renderTo(function()
    for _, c in ipairs(commands) do
      local f = load(c)
      if f then f() end
    end
  end)
end

function CanvasModel:write(text)
  if string.is_non_empty_string(text) then
    self.terminal:print(text)
  end
end

function CanvasModel:push(newResult)
  if type(newResult) == 'table' then
    for _, v in ipairs(newResult) do
      self:write(v)
    end
  end
end

function CanvasModel:clear()
  self.terminal:clear()
end

function CanvasModel:update(dt)
  self.terminal:update(dt)
end
