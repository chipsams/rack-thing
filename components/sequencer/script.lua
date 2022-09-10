local newport = require "classes.ports"
local inputs = require "classes.inputs"
local v2d = require "vector"

local image = love.graphics.newImage("components/sequencer/sprite.png")
local toggle = love.graphics.newImage("components/sequencer/toggle.png")

local function initComponent(self)
  --these are the defaults, but it doesn't matter for this case.
  self.w = 2
  self.h = 1

  self.inputs={}

  self.buttons = {}

  for lx=0,3 do
    self.buttons[lx]={}
    for ly=0,16 do
      local button=inputs.simpleButton.create(self,v2d(18+lx*8,8+ly*5),toggle)
      self.buttons[lx][ly]=button
      self.inputs[#self.inputs+1]=button
    end
  end

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
  end
end

return initComponent