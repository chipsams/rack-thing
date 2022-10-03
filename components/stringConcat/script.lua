local newport = require "classes.ports"
local seg = require "graphics.7seg"

local image = love.graphics.newImage("components/stringConcat/sprite.png")

local function initComponent(self)

  self.a=newport(self,11,19,true,"stringRibbon")
  self.b=newport(self,21,29,true,"stringRibbon")
  self.output=newport(self,16,78,false,"stringRibbon")
  
  function self:draw(pos)
    love.graphics.draw(image,pos.x,pos.y)
    love.graphics.print(tostring(self.output.lastSent),pos.x,pos.y-32)
  end

  function self:genOutputs()
    local st="("..self.a.lastValue..")("..self.b.lastValue..")"
    if #st > 1000 then
      self.output:send("")
    else
      self.output:send(st)
    end
  end
  
  function self:tickEnd()
  end

end

return initComponent