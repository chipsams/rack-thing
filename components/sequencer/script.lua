local newport = require "classes.ports"
local inputs = require "classes.inputs"
local v2d = require "vector"

local image = love.graphics.newImage("components/bias/sprite.png")

local function initComponent(self)
  --these are the defaults, but it doesn't matter for this case.
  self.w = 1
  self.h = 1

  self.inputs={}

  inputs.simpleButton.create(self,v2d(4,4))
  

  self.value=0

  self.input=newport(self,16,16,true)
  self.output=newport(self,16,80)
  
  function self:draw(pos)
    love.graphics.draw(image,pos.x,pos.y)
    for _,input in pairs(self.inputs) do
      input:draw(input.r_pos+pos)
    end
  end
  
  function self:tickStarted()
  end

  function self:genOutputs()
    print("generating")
    self.output:send(self.input.lastValue+self.inputs.offset.value)
  end
end

return initComponent