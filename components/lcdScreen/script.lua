local newport = require "classes.ports"
local seg = require "graphics.7seg"

local image = love.graphics.newImage("components/lcdScreen/sprite.png")

local function initComponent(self)
  --these are the defaults, but it doesn't matter for this case.
  self.w = 1
  self.h = 1

  self.value=-123

  self.input=newport(self,16,16,true)
  
  function self:draw(pos)
    love.graphics.draw(image,pos.x,pos.y)
    seg.standardDisplay(self.value,pos.x+4,pos.y+51)
  end
  function self:recieveInput(port,value)
    self.value=value
  end
  
end

return initComponent