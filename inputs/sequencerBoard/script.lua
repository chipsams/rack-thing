local v2d = require "vector"

local toggleImg = love.graphics.newImage("inputs/sequencerBoard/toggle.png")
local quadOff = love.graphics.newQuad(0,0,7,4,toggleImg:getDimensions())
local quadOn  = love.graphics.newQuad(8,0,7,4,toggleImg:getDimensions())

local input={}

function input:initInput(pos,image,startState)
  self.r_pos=pos or v2d(0,0)
  self.toggleData={}
  for lx=0,3 do
    self.toggleData[lx]={}
    for ly=0,16 do
      self.toggleData[lx][ly]=false
    end
  end
end

function input:update(dt)
end

function input:touchStart(mouse)
  local tp=((mouse-self.r_pos-self.owner.v_pos)/v2d(8,5)):floor()
  self.setState=not self.toggleData[tp.x][tp.y]
  self.toggleData[tp.x][tp.y]=self.setState
end

function input:touchEnd(mouse)
end

function input:touching(mouse)
  local tp=((mouse-self.r_pos-self.owner.v_pos)/v2d(8,5)):floor()
  if self.toggleData[tp.x] and tp.y>=0 and tp.y<=16 then
    self.toggleData[tp.x][tp.y]=self.setState
  end
end

function input:draw(drawPos)
  for lx=0,3 do
    for ly=0,16 do
      love.graphics.draw(toggleImg,self.toggleData[lx][ly] and quadOn or quadOff,drawPos.x+lx*8,drawPos.y+ly*5)
    end
  end
end

function input:isOverlapping(mouse)
  return mouse>=self.r_pos+self.owner.v_pos and mouse<self.r_pos+self.owner.v_pos+v2d(8*4,5*17)
end

return input