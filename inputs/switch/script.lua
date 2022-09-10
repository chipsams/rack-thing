local v2d = require "vector"

local light = love.graphics.newImage("inputs/switch/light.png")
local lightquads={}

for l=0,6 do
  lightquads[l]=love.graphics.newQuad(l*4,0,4,4,light:getDimensions())
end

local input={}

function input:initInput(pos,startState)
  self.r_pos=pos or v2d(0,0)
  self.toggle=startState or false
  --where the slider is within the switch
  self.sliderpos=2
  --how fast the slider is moving
  self.slidervel=10

  --color of the light
  self.colour=0
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
  love.graphics.draw(light,lightquads[math.floor(self.colour+.5)],drawPos.x+math.floor(self.sliderpos+.5),drawPos.y)
end

function input:isOverlapping(mouse)
  return mouse>=self.r_pos+self.owner.v_pos-v2d(1,1) and mouse<=self.r_pos+self.owner.v_pos+v2d(9,5)
end

return input