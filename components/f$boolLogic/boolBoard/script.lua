local newport = require "classes.ports"
local inputs = require "classes.inputs"
local v2d = require "vector"
local seg = require "graphics.7seg"

local image = love.graphics.newImage("components/f$boolLogic/boolBoard/sprite.png")
local button = love.graphics.newImage("components/f$boolLogic/boolBoard/button.png")

local function initComponent(self)
  --these are the defaults, but it doesn't matter for this case.
  self.w = 1
  self.h = 1

  self.inputs={}
  self.outputs={}

  for l=0,14 do
    self.inputs[l] = inputs.simpleButton.create(self,v2d(2,2+l*6),button)
    self.outputs[l] = newport(self,27,5+l*6,false,"boolean")
  end
  
  function self:draw(pos)
 
    love.graphics.draw(image,pos.x,pos.y)
    for _,input in pairs(self.inputs) do
      input:draw(input.r_pos+pos)
    end
    
    love.graphics.setColor(1,1,1)
  end
  

  function self:tickStarted()
  end

  function self:genOutputs()
    for l=0,14 do
      self.outputs[l]:send(self.inputs[l].toggle or false)
    end
  end
end

return initComponent