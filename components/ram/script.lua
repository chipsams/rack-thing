local newport = require "classes.ports"
local seg = require "graphics.7seg"

local font = love.graphics.newImageFont("components/ram/smallnumber.png","0123456789")
local image = love.graphics.newImage("components/ram/sprite.png")

local function initComponent(self)
  --these are the defaults, but it doesn't matter for this case.
  self.w = 3
  self.h = 1

  self.data={}
  for l=0,49 do self.data[l]=0 end

  self.addr=newport(self,9,21,true)
  self.currentAddr=0

  self.dataIn=newport(self,76,21,true)
  self.dataOut=newport(self,89,21)
  self.enable=newport(self,54,21,true)
  
  function self:draw(pos)
    love.graphics.draw(image,pos.x,pos.y)

    local prev=love.graphics.getFont()
    love.graphics.setFont(font)
    love.graphics.setLineWidth(1)
    for lx=0,4 do
      for ly=0,9 do
        if self.data[lx*10+ly]<0 then
          love.graphics.line(pos.x+13+17*lx,pos.y+37+5*ly,pos.x+15+17*lx,pos.y+38+5*ly)
        end
        love.graphics.print(self.data[lx*10+ly],pos.x+16+17*lx,pos.y+35+5*ly)
      end
    end
    love.graphics.setFont(prev)

    if self.currentAddr>9 then
      seg.drawChar((math.floor(self.currentAddr/10)%10),pos.x+17,pos.y+16)
    end
    
    seg.drawChar((self.currentAddr%10),pos.x+24,pos.y+16)
  end
  
  function self:tickStarted()
    self.dataOut:send(self.data[self.currentAddr])
  end
  
  function self:recieveInput(port,value)
    if port==self.addr then
      self.currentAddr=math.max(0,math.min(value,49))
    end
  end
  
  function self:genOutputs()
  end
  
  function self:tickEnd()
    if self.enable.lastValue > 0 then
      self.data[self.currentAddr]=self.dataIn.lastValue
    end
  end
  
end

return initComponent