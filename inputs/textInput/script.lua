local v2d = require "vector"

local light = love.graphics.newImage("inputs/switch/light.png")
local lightquads={}

for l=0,6 do
  lightquads[l]=love.graphics.newQuad(l*4,0,4,4,light:getDimensions())
end

local input={}

function input:initInput(pos,size,settings)
  settings=settings or {}
  self.r_pos=pos or v2d(0,0)
  self.size=size or v2d(10,10)
  self.text=settings.default or ""
  self.callback=settings.callback
  self.keyCallback=settings.keyCallback
  self.mask=settings.mask
  self.maxChars=settings.maxChars or math.huge
end

function input:update(dt)
end

function input:keyPressed(key)
  if self.keyCallback then self.keyCallback(key) end
  if key=="backspace" then
    self.text=self.text:sub(1,-2)
    if self.callback then self.callback() end
  end
end

function input:textInput(char)
  if #self.text<self.maxChars and ((not self.mask) or self.mask:find(char,1,true)) then
    self.text=self.text..char
  end
  if self.callback then self.callback() end
end

function input:draw(drawPos)
  love.graphics.setColor(1,1,1)
  --love.graphics.rectangle("line",drawPos.x,drawPos.y,self.size.x,self.size.y)
end

function input:isOverlapping(mouse)
  return mouse>=self.r_pos+self.owner.v_pos-v2d(1,1) and mouse<=self.r_pos+self.owner.v_pos+self.size
end

return input