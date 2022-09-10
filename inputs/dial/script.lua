local v2d = require "vector"

local input={}

function input:initInput(pos,settings)
  settings=settings or {}
  self.r_pos=pos or v2d(0,0)
  self.radius=settings.radius or 8
  self.value=0
  self.editValue=0
  self.min=settings.min or -math.huge
  self.max=settings.max or math.huge
end

function input:touchStart(mouse)
  self.mouseLock=v2d(love.mouse.getPosition())
  self.mousePrev=mouse
  --print("started:",mouse.x)
end

function input:touchEnd(mouse)
  love.mouse.setGrabbed(false)
end

function input:touching(mouse)
  --print("new:",mouse.x)
  local diff=self.mousePrev-mouse
  if diff.x~=0 then
    self.editValue=math.max(self.min,math.min(self.editValue-diff.x/2,self.max))
    --print(self.editValue,(diff.x>=0 and "+" or "")..diff.x)
  end
  self.value=math.floor(self.editValue+0.5)
  love.mouse.setPosition(self.mouseLock.x,self.mouseLock.y+10)
end

function input:draw(drawPos)
  local r=math.floor(self.radius)+.5
  drawPos=drawPos:floor()+v2d(0.5,0.5)
  love.graphics.setColor(1,1,1)
  love.graphics.circle("fill",drawPos.x,drawPos.y,r)
  local dir=(((self.value-self.min)/(self.max-self.min)-0.5)*-0.75+0.5)*math.pi*2
  love.graphics.setLineWidth(1)
  love.graphics.setColor(0.7,0.7,0.8)
  love.graphics.line(drawPos.x-math.sin(dir)*0.5,drawPos.y-math.cos(dir)*0.5,drawPos.x+math.sin(dir)*r,drawPos.y+math.cos(dir)*r)
  love.graphics.setColor(1,1,1)
end

function input:isOverlapping(mouse)
  local r=self.radius+2
  if (mouse-(self.r_pos+self.owner.v_pos)):squaredMagnitude() < r*r then
    return true
  end
end

function input:update(dt)
  
end

return input