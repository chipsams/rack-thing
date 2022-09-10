local newport = require "classes.ports"

local image = love.graphics.newImage("components/random/sprite.png")

local function recieveInput(self,port,value)
end

local function startTick()
  
end

local function initComponent(self)
  self.p_out=newport(self,16,80)
  

  function self:onInput(port,value)

  end
  
  function self:tickStarted()
    
  end
  
  function self:genOutputs()
    self.p_out:send(love.math.random(-999,999))
  end

  function self:draw(pos)
    love.graphics.draw(image,pos.x,pos.y)
  end
end


return initComponent