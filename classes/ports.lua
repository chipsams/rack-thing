local v2d = require("vector")

local port_mt={}
port_mt.__index=port_mt

local types={}

types.standard={
  linkingTypes={"standard","either"},
  lowValue=0,
  image=love.graphics.newImage("assets/peg.png"),
  thickness=3,
  dist=14,
}
function types.standard.clamp(v)
  return math.min(math.max(v,-999),999)
end
function types.standard.isLow(v)
  return v<=0
end

types.either={
  clamp=types.standard.clamp,
  linkingTypes={"standard","either"},
  lowValue=0,
  image=love.graphics.newImage("assets/peg.png"),
  thickness=3,
  dist=14,
}
function types.either:preLink(linkee)
  self.input=not linkee.input
end
function types.either.isLow(v)
  return v<=0
end

types.boolean={
  linkingTypes={"boolean"},
  lowValue=false,
  image=love.graphics.newImage("assets/tinyPeg.png"),
  thickness=1,
  dist=7,
}
function types.boolean.clamp(v)
  if type(v)=="number" then return v>0 end
  return v and true or false
end
function types.boolean.isLow(v)
  return not v
end

for _,type in pairs(types) do
  for k,v in pairs(type.linkingTypes) do
    type.linkingTypes[v]=true
  end
  for k,v in pairs({
    clamp=function(v) return v end,
    preLink=function(self,linkee) end,
  }) do
    type[k]=type[k] or v
  end
end

--- creates a port tied to a specific component
---@param owner table
---@param rx number
---@param ry number
---@param input boolean
---@param type string
local function createPort(owner,rx,ry,input,type)
  local newPort=setmetatable({},port_mt)
  newPort.owner=owner
  newPort.r_pos=v2d(rx,ry)
  newPort.link=nil
  newPort.input=input and true or false
  newPort.type =type or "standard"
  if not types[newPort.type] then error("thats not a valid port type!") end

  newPort.lastSent=nil
  newPort.sending=nil
  newPort.typeData=types[newPort.type]

  newPort.lastValue=newPort.typeData.lowValue

  table.insert(owner.ports,newPort)
  return newPort
end

function port_mt:unlink()
  if not self.link then error("tried to unlink an unconnected port") end
  self.link:destroy()  
end

function port_mt:getPos()
  return self.r_pos+self.owner.v_pos
end

function port_mt:getScreenPos()
  return self.r_pos+self.owner.v_pos-self.owner.scene.cam
end

function port_mt:draw()
  --local draw_pos=self:getScreenPos():round()
  --if self.input then
  --  love.graphics.setColor(0,0.2,1)
  --else
  --  love.graphics.setColor(1,0.5,0)
  --end
  --love.graphics.circle("fill",draw_pos.x,draw_pos.y,2)
  --love.graphics.setColor(1,1,1)
end

function port_mt:getLinked()
  return self.link and (self.input and self.link.from or self.link.to)
end

function port_mt:send(v)
  if v==nil then error("passed nil into a send! "..self.owner.name) end
  v = self.typeData.clamp(v)
  self.sending=v
  if self.lastSent~=v then
    self.lastSent=v
    self.owner.scene.nextPending[self]=v
  end
  if self.link then
    print(self.owner.name,"tried to send",v)
  end
  
end

return createPort