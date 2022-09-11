local newport = require "classes.ports"
local inputs = require "classes.inputs"
local v2d = require "vector"
local seg = require "graphics.7seg"

local calcTable = require "components/f$boolLogic/truthTable"
--  0 1 z ? <- data
-- /-------
--0|z z z z
-- |
--1|0 1 z ?
-- |
--z|z z z z
-- |
--?|? ? ? ?

--^^^ control

local gate=calcTable[[
zzzz
01z?
zzzz
????]]

local image = love.graphics.newImage("components/f$boolLogic/transistorBoard/sprite.png")

local function initComponent(self)
  --these are the defaults, but it doesn't matter for this case.
  self.w = 1
  self.h = 1

  self.inputs={}

  self.in_ports={}
  self.control={}
  self.out_ports={}

  for l=0,9 do
    self.in_ports[l] = newport(self,4,14+l*8,true,"boolean")
    self.control[l] = newport(self,10,10+l*8,true,"boolean")
    self.out_ports[l] = newport(self,27,14+l*8,false,"boolean")
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
    for l=0,9 do
      self.out_ports[l]:send(gate(self.control[l].lastValue,self.in_ports[l].lastValue))
    end
  end
end

return initComponent