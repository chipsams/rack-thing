local v2d = require "vector"

local defaultImg = love.graphics.newImage("inputs/simplebutton/default.png")

local input={}

function input:initInput(pos,image,startState)
  self.r_pos=pos or v2d(0,0)
  self.image=image or defaultImg
  self.w,self.h=self.image:getDimensions()
  self.w=self.w/2
  self.toggle=startState or false
end

function input:update(dt)

  self.slidervel=self.slidervel+((self.toggle and 4 or 0)-self.sliderpos)*dt*200
  self.slidervel=self.slidervel*0.01^(dt*2)
  self.sliderpos=self.sliderpos+self.slidervel*dt

  local target=self.toggle and 6 or 0
  if self.colour>target then self.colour=self.colour-dt*40 end
  if self.colour<target then self.colour=self.colour+dt*40 end
  self.colour=math.max(math.min(self.colour,6),0)
end

function input:touchStart(mouse)
  self.toggle=not self.toggle
end

function input:touchEnd(mouse)
end

function input:touching(mouse)
end

function input:draw(drawPos)
  love.graphics.draw(self.image,self.toggle and self.quadOn or self.quadOff,drawPos.x,drawPos.y)
end

function input:isOverlapping(mouse)
  return mouse>=self.r_pos+self.owner.v_pos-v2d(1,1) and mouse<=self.r_pos+self.owner.v_pos+v2d(9,5)
end

return input