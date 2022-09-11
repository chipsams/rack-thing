local newport = require "classes.ports"
local inputs = require "classes.inputs"
local v2d = require "vector"
local seg = require "graphics.7seg"

local image = love.graphics.newImage("components/boolDisplay/sprite.png")
local light = love.graphics.newImage("components/boolDisplay/light.png")

local function initComponent(self)
  self.w = 1
  self.h = 1

  self.inputs={}
  self.outputs={}

  self.in_ports={}
  for l=0,14 do
    self.in_ports[l] = newport(self,4,5+l*6,true,"boolean")
  end
  
  function self:draw(pos)
 
    love.graphics.draw(image,pos.x,pos.y)

    for l=0,14 do
      if self.in_ports[l].lastValue then love.graphics.draw(light,pos.x+18,pos.y+3+l*6) end
    end
    
    love.graphics.setColor(1,1,1)
  end
  

  function self:tickStarted()
  end

  function self:genOutputs()
    
  end
end

return initComponent