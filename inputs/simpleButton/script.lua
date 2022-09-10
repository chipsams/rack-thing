local v2d = require "vector"

local defaultImg = love.graphics.newImage("inputs/simplebutton/default.png")

local input={}

function input:initInput(pos,image,startState)
  self.r_pos=pos or v2d(0,0)
  self.image=image or defaultImg
  self.w,self.h=self.image:getDimensions()
  self.w=self.w/2
  self.dim=v2d(self.w,self.h)
  self.quadOff = love.graphics.newQuad(0,0,self.w,self.h,self.image:getDimensions())
  self.quadOn  = love.graphics.newQuad(self.w,0,self.w,self.h,self.image:getDimensions())
  self.toggle=startState or false
end

function input:update(dt)
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
  return mouse>=self.r_pos+self.owner.v_pos and mouse<=self.r_pos+self.owner.v_pos+self.dim
end

return input