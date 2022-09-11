local newport = require "classes.ports"
local inputs = require "classes.inputs"
local v2d = require "vector"
local seg = require "graphics.7seg"

local calcTable = require "components/f$boolLogic/truthTable"

local image = love.graphics.newImage("components/f$boolLogic/wireGroup/sprite.png")

local gate=calcTable[[
0?0?
?11?
01z?
????]]

local function initComponent(self)
  --these are the defaults, but it doesn't matter for this case.
  self.w = 1
  self.h = 1

  self.inputs={}

  self.groups={}
  self.control={}
  self.out_ports={}

  for i=1,5 do
    self.groups[i] = {i={},o={}}
    for l=1,5 do
      self.groups[i].i[l]=newport(self,3+(l-1)*6,12+(i-1)*16,true,"boolean")
      self.groups[i].o[l]=newport(self,3+(l-1)*6,22+(i-1)*16,false,"boolean")
    end
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
    --[[
    0?0?
    ?11?
    01z?
    ????]]
    for i=1,5 do
      local v=gate(self.groups[i].i[1].lastValue,self.groups[i].i[2].lastValue)
      for l=3,5 do
        v=gate(v,self.groups[i].i[l].lastValue)
      end
      for l=1,5 do
        self.groups[i].o[l]:send(v)
      end
    end
  end
end

return initComponent