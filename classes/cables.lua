local v2d = require "vector"

local cable_mt={}
cable_mt.__index=cable_mt


local portImg = love.graphics.newImage("assets/peg.png")
local tinyPortImg = love.graphics.newImage("assets/tinyPeg.png")

local function drawCable(from,to,color,typeData)
  from=from:copy():round()
  to=to:copy():round()

  local linepath={}

  local dist=(from-to):magnitude()+8
  
  local externalPoint=v2d(math.lerp(from.x,to.x,0.5),math.max(from.y,to.y)+math.min(dist,48))

  local subdiv
  subdiv=math.min(1/16,8/dist)
  subdiv=math.max(1/32,subdiv)

  for l=0,1-0.001,subdiv do
    local a=from:lerp(externalPoint,l)
    local b=externalPoint:lerp(to,l)
    local point=a:lerp(b,l)
    table.insert(linepath,point.x)
    table.insert(linepath,point.y)
  end
  table.insert(linepath,to.x)
  table.insert(linepath,to.y)


  love.graphics.setColor(unpack(color))
  do
    local thisPortImg = typeData.image
    local w,h=thisPortImg:getDimensions()
    love.graphics.draw(thisPortImg,from.x-w/2,from.y-h/2)
    love.graphics.draw(thisPortImg,to.x-w/2,to.y-h/2)
  end

  love.graphics.setColor(0,0,0)
  love.graphics.setLineWidth(typeData.thickness)
  for o=-1,1,2 do
    love.graphics.translate(o,0)
    love.graphics.line(linepath)
    love.graphics.translate(-o,o)
    love.graphics.line(linepath)
    love.graphics.origin()
  end
  love.graphics.setColor(unpack(color))
  love.graphics.line(linepath)
  love.graphics.setColor(1,1,1)
end

function cable_mt:draw()
  local from = self.from:getScreenPos()
  local to = self.to:getScreenPos()
  drawCable(from,to,self.to.lastValue=="z" and {0,math.sin(t*8)/2+.5,1} or self.to.typeData.isLow(self.to.lastValue) and self.color or {1,1,math.sin(t*8)/2+.5},self.from.typeData)
end

function cable_mt:destroy()
  --self.from.owner.scene
  self.from.lastValue=self.from.typeData.lowValue
  self.to.lastValue=self.to.typeData.lowValue
  self.from.link=nil
  self.to.link=nil
end

--- links two ports. creates an error if the ports were previously linked.
---@param from table
---@param to table
local function createCable(from,to)

  --this ensures that you can't make wierd links, and gives a clear error for things that shouldn't occur.
  if not from and not to then return false,"tried to link between two nil ports!" end
  if not from then return false,"tried to link from nothing!" end
  if not to then return false,"tried to link to nothing!" end

  if from == to then return false,"tried to link a port to itself!" end

  if from.link and to.link then return false,"tried between two already connected ports!" end
  if from.link then return false,"tried to link from an already connected port!" end
  if to.link then return false,"tried to link to an already connected port!" end

  from.typeData.preLink(from,to)
  to.typeData.preLink(to,from)

  if from.input and to.input then return false,"tried to link two inputs!" end
  if not from.input and not to.input then return false,"tried to link two outputs!" end

  print(from.typeData.linkingTypes[to.type],to.typeData.linkingTypes[from.type])
  if not (from.typeData.linkingTypes[to.type] and to.typeData.linkingTypes[from.type]) then return false,"tried to link mismatched port types!" end

  if from.input then from,to = to,from end 

  local newCable=setmetatable({},cable_mt)

  newCable.from=from
  newCable.to=to
  to.link=newCable
  from.link=newCable

  newCable.color={love.math.random(0,1),love.math.random(0,1),love.math.random(0,1)}

  return newCable
end

return {create=createCable,draw=drawCable}