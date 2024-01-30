--- @class BGView
--- @field cfg Config
BGView = {}
BGView.__index = BGView

setmetatable(BGView, {
  __call = function(cls, ...)
    return cls.new(...)
  end,
})

function BGView.new(cfg)
  local self = setmetatable({
    cfg = cfg
  }, BGView)

  return self
end

function BGView:draw(drawable_height)
  local vcfg = self.cfg.view
  local colors = vcfg.colors
  local b = vcfg.border
  local fac = vcfg.fac
  local w = vcfg.w
  local fh = vcfg.fh

  G.push('all')
  G.setColor(colors.terminal.bg)

  -- I don't what this was supposed to do
  -- G.rectangle("fill",
  --   b,
  --   b + drawable_height - 2 * fac,
  --   w - b,
  --   fh
  -- )
  G.pop()
end