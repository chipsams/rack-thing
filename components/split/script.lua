local newport = require "classes.ports"
local inputs = require "classes.inputs"
local v2d = require "vector"

local image = love.graphics.newImage("components/split/sprite.png")


local function initComponent(self)
  self.w = 1
  self.h = 1
  
  self.inputs={
    digit=inputs.switch.create(self,v2d(6,88))
  }
  
  self.input=newport(self,16,16,true)
  self.outPorts={}
  for l=0,3 do
    self.outPorts[l]=newport(self,22-l*4,32+l*16)
  end

  
  
  local powersOf10={[0]=1,10,100,1000}

  function self.genOutputs()
    local value=self.input.lastValue
    if self.inputs.digit.toggle then
      self.outPorts[0]:send(value<0 and -999 or 999)
      for l=0,2 do
        self.outPorts[3-l]:send(math.abs(value)/powersOf10[l]%10)
      end
    else
      for l=0,3 do
        self.outPorts[l]:send(value)
      end
    end
  end
  
  function self:tickStarted()
    
  end

  function self:draw(pos)
    love.graphics.draw(image,pos.x,pos.y)
    for _,input in pairs(self.inputs) do
      input:draw(input.r_pos+pos)
    end
  end
end

return initComponent