local newport = require "classes.ports"
local inputs = require "classes.inputs"
local v2d = require "vector"
local seg = require "graphics.7seg"

local image = love.graphics.newImage("components/constant/sprite.png")

local function initComponent(self)
  --these are the defaults, but it doesn't matter for this case.
  self.w = 1
  self.h = 1

  self.inputs={
    ones=inputs.dial.create(self,v2d(25,13),{min=0,max=9,radius=3}),
    tens=inputs.dial.create(self,v2d(18,6),{min=0,max=9,radius=3}),
    hundreds=inputs.dial.create(self,v2d(11,13),{min=0,max=9,radius=3}),
    switch=inputs.switch.create(self,v2d(3,3)),
    textInput=inputs.textInput.create(self,v2d(3,27),v2d(27,12),{
      keyCallback=function(key)
        if key=="-" or key=="=" then
          self.inputs.switch.toggle=not self.inputs.switch.toggle
        elseif key=="backspace" then
          if self.inputs.textInput.text=="" then self.inputs.switch.toggle=false end
        end
      end,
      callback=function()
      local text=self.inputs.textInput.text
      while not text:find("%d%d%d") do
        text="0"..text
      end
      self.inputs.ones.value=tonumber(text:sub(3,3))
      self.inputs.tens.value=tonumber(text:sub(2,2))
      self.inputs.hundreds.value=tonumber(text:sub(1,1))
    end,maxChars=3,mask="0123456789"})
  }

  self.output=newport(self,16,80)
  
  function self:draw(pos)
    self.inputs.textInput.text=""..math.abs(self:calcValue())
 
    love.graphics.draw(image,pos.x,pos.y)
    for _,input in pairs(self.inputs) do
      input:draw(input.r_pos+pos)
    end

    seg.standardDisplay(self:calcValue(),pos.x+4,pos.y+27)
    
    love.graphics.setColor(1,1,1)
  end
  
  function self:calcValue()
    return (self.inputs.switch.toggle and -1 or 1)*(self.inputs.ones.value+self.inputs.tens.value*10+self.inputs.hundreds.value*100)
  end

  function self:tickStarted()
  end

  function self:genOutputs()
    self.output:send(self:calcValue())
  end
end

return initComponent