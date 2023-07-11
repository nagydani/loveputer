local utf8 = require("utf8")

local _ = require("model/inputModel")
local _ = require("model/canvasModel")
local _ = require("model/eval")

Console = {}

function Console:new(init)
  local c = {
    n = init or 0,
    input = InputModel:new(),
    canvas = CanvasModel:new(),
  }
  setmetatable(c, self)
  self.__index = self
  return c
end

function Console:incr()
  self.n = self.n + 1
end

function Console:paste(text)
  local t = self.entered
  self.entered = t .. text
end

function Console:evaluate()
  local ent = self.entered
  if ent ~= '' then
    local input = self.entered
    self.input:push(input)
    local result = Eval.apply(self.input.entered)
    if result and result ~= '' then
      self.canvas:push(result)
    end
    self.input:clear()
  end
end
