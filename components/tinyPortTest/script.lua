
local newport = require "classes.ports"
local inputs = require "classes.inputs"
local v2d = require "vector"

local image = love.graphics.newImage("components/tinyPortTest/sprite.png")


local function initComponent(self)
  self.w = 1
  self.h = 1
  
  self.input=newport(self,16,31,true)
  self.output=newport(self,16,64,false)
  self.tinyinput=newport(self,6,60,true,"boolean")
  self.tinyoutput=newport(self,25,27,false,"boolean")

  function self:genOutputs()
    self.output:send(self.tinyinput.lastValue and 999 or 0)
    self.tinyoutput:send(self.input.lastValue > 0)
  end

  function self:tickStarted()
    self.tinyoutput:send(self.input.lastValue > 0)
    self.output:send(self.tinyinput.lastValue and 999 or 0)
  end
  
  function self:recieveInput(port,value)
  end
  
  
  

  function self:draw(pos)
    love.graphics.draw(image,pos.x,pos.y)

  end
end

return initComponent