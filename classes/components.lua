
local v2d = require "vector"

local component_mt={}
component_mt.__index=component_mt

local function createComponent(scene,x,y,initComponent,...)
  local newComponent=setmetatable({},component_mt)
  newComponent.w=1
  newComponent.h=1
  newComponent.inputs={}
  newComponent.ports={}
  newComponent.pos=v2d(x,y)
  newComponent.v_pos=v2d(x*33,y*98)
  newComponent.scene=scene

  --update the linked list
  scene.components:add(newComponent)

  initComponent(newComponent,...)
  newComponent.dimensions=v2d(newComponent.w*33-1,newComponent.h*98-2)

  newComponent:setOccupied()

  return newComponent
end

function component_mt:delete()
  for port in pairs(self.ports) do
    if port.link then port:unlink() end
  end
  self.scene.components=nil
end

function component_mt:visualsUpdate(dt)
  self.v_pos=self.v_pos:lerp(self.pos*v2d(33,98),1/0.01*dt)
end

function component_mt:pointTouching(pos)
  return pos>=self.v_pos and pos<=self.v_pos+self.dimensions
end

function component_mt:nearestPort(point)
  local nearestPort,dist=nil,math.huge
  for _,port in pairs(self.ports) do
    local newDist=(point-port:getPos()):squaredMagnitude()
    if newDist<dist then
      nearestPort,dist=port,newDist
    end
  end
  return nearestPort,math.sqrt(dist)
end

function component_mt:getHoveredComponent(point)
  for _,input in pairs(self.inputs) do
    if input:isOverlapping(point) then return input end
  end
end
function component_mt:inputsUpdate(dt)
  for _,input in pairs(self.inputs) do
    input:update(dt)
  end
end

function component_mt:setOccupied(pos)
  pos = pos or self.pos
  for ly=pos.y,pos.y+self.h-1 do
    for lx=pos.x,pos.x+self.w-1 do
      self.scene.occupied:set(lx,ly)
    end
  end
end

function component_mt:onScreen()
  return self.v_pos+self.dimensions>=self.scene.cam and self.v_pos<=self.scene.cam+self.scene.screenSize
end

function component_mt:unsetOccupied(pos)
  pos = pos or self.pos
  for ly=pos.y,pos.y+self.h-1 do
    for lx=pos.x,pos.x+self.w-1 do
      self.scene.occupied:unset(lx,ly)
    end
  end
end

function component_mt:getOccupied(pos)
  pos = pos or self.pos
  for ly=pos.y,pos.y+self.h-1 do
    for lx=pos.x,pos.x+self.w-1 do
      if self.scene.occupied:get(lx,ly) then return true end
    end 
  end
  return false
end

--placeholders that do nothing, should be replaced by each component type.

--called at the start of each tick
function component_mt:tickStarted()

end

--called at the start of each tick, and also whenever an input is recieved
function component_mt:genOutputs()
end

--called at the end of a tick (i.e. no pending values on cables.) inputs sent will be ignored.
function component_mt:tickEnd()

end

--called whenever a value is recieved by a port.
function component_mt:recieveInput(port,value)

end

--called for each component on screen, every frame.
function component_mt:draw()

end

return createComponent