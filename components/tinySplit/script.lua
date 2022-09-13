local newport = require "classes.ports"
local inputs = require "classes.inputs"
local v2d = require "vector"

local image = love.graphics.newImage("components/tinySplit/sprite.png")

local function initComponent(self)
  --these are the defaults, but it doesn't matter for this case.
  self.w = 1
  self.h = 1

  self.inA = newport(self,6,6,true,"boolean")
  self.inB = newport(self,6,34,true,"boolean")
  self.inC = newport(self,6,62,true,"boolean")
  self.outA={}
  self.outB={}
  self.outC={}
  for i=0,3 do
    self.outA[i] = newport(self,25, 6+i*6,false,"boolean")
    self.outB[i] = newport(self,25,34+i*6,false,"boolean")
    self.outC[i] = newport(self,25,62+i*6,false,"boolean")
  end
  
  function self:draw(pos)
    love.graphics.draw(image,pos.x,pos.y)
    for _,input in pairs(self.inputs) do
      input:draw(input.r_pos+pos)
    end
  end
  
  function self:tickStarted()
  end

  function self:genOutputs()
    local valA = self.inA.lastValue
    local valB = self.inB.lastValue
    local valC = self.inC.lastValue
    for i=0,3 do
      self.outA[i]:send(valA)
      self.outB[i]:send(valB)
      self.outC[i]:send(valC)
    end
  end
end

return initComponent
