local newport = require "classes.ports"
local seg = require "graphics.7seg"

local image = love.graphics.newImage("components/storage/sprite.png")

local function initComponent(self)
  --these are the defaults, but it doesn't matter for this case.
  self.w = 1
  self.h = 1

  self.value=0

  self.input=newport(self,16,16,true)
  self.save=newport(self,8,34,true,"boolean")
  self.output=newport(self,16,80)
  
  function self:draw(pos)
    love.graphics.draw(image,pos.x,pos.y)
    seg.standardDisplay(self.value,pos.x+4,pos.y+51)
  end

  function self:tickStarted()
    self.output:send(self.value)
  end

  function self:genOutputs()
  end
  
  function self:tickEnd()
    if self.save.lastValue==true then
      self.value=self.input.lastValue
    elseif self.save.lastValue=="?" then
      self.value=math.random(-999,999)
    end
  end

end

return initComponent