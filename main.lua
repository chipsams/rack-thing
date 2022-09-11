globaldata={}

require "extend_math"

local coolRect = require "graphics.coolRect"
local serialize = require "serialize"
local cable = require "classes.cables"
local newcomponent = require "classes.components"
local v2d = require "vector"
local new_ll = require "linkedList"
local boolArr = require "classes.2dBoolArray"

local components={}
for _,file in pairs(love.filesystem.getDirectoryItems("components")) do
  local path="components/"..file.."/script"
  print(path)
  local fn=require(path)
  components[file]=function(obj,...)
    obj.name=file
    return fn(obj,...)
  end
end

local bg_image = love.graphics.newImage("assets/bg.png")
bg_image:setWrap("repeat", "repeat")
local bg_quad

local scene={cam=v2d(0,0),screenSize=v2d(100,100),components=new_ll(),occupied=boolArr()}

for l=0,4 do
  newcomponent(scene,0,l,components.constant)
  newcomponent(scene,1,l,components.split)
  newcomponent(scene,2,l,components.lcdScreen)
  newcomponent(scene,3,l,components.calculator)
  newcomponent(scene,4,l,components.storage)
  newcomponent(scene,5,l,components.tinyPortTest)
  newcomponent(scene,6,l,components.sequencer)
  newcomponent(scene,8,l,components.boolBoard)
  newcomponent(scene,9,l,components.boolDisplay)
  --newcomponent(scene,10,l,components.bias)
  --newcomponent(scene,11,l,components.random)
end
--newcomponent(scene,7,1,components.ram)

newcomponent(scene,16,0,components.TIS100,"add 1\nmov acc right\njro 2\nsub 999")
newcomponent(scene,16,1,components.TIS100,"mov left acc\nadd acc\nmov acc down")
newcomponent(scene,16,2,components.TIS100,"")
newcomponent(scene,16,3,components.TIS100,"")
newcomponent(scene,16,4,components.TIS100,"")

--newcomponent(scene,5,l,components.inputs)

local linkingPort

local draggingPart
local draggingPartOffset

local touchingComponent
local focusedComponent




local mainCanvas
scene.scale = 3

function love.resize(w,h)
  mainCanvas=love.graphics.newCanvas(w/scene.scale,h/scene.scale)
  scene.screenSize=v2d(w/scene.scale,h/scene.scale)
  bg_quad = love.graphics.newQuad(0, 0, scene.screenSize.x+bg_image:getWidth(), scene.screenSize.y+bg_image:getHeight(), bg_image:getDimensions())
end

function love.load()
  love.window.setMode(900,600,{resizable=true})
  love.graphics.setDefaultFilter("nearest")
  love.graphics.setLineStyle("rough")
  love.resize(love.graphics.getDimensions())
end

local debugtext=""
  local function debug(...)
    local elems={...}
    for i,elem in pairs(elems) do
      elems[i]=tostring(elem)
    end
    debugtext=debugtext..table.concat(elems,"\t").."\n"
  end

t = 0
function love.update(dt)
  t = t + dt
  if love.keyboard.isDown("tab") and love.keyboard.isDown("lshift","rshift") then
    tick(scene,10000)
  end

  local mouse=v2d(love.mouse.getPosition())*(1/scene.scale)+scene.cam

  debugtext=""
  if not (focusedComponent and focusedComponent.screenLock) then
    if love.keyboard.isDown("left") then scene.cam:sub(v2d(4,0)) end
    if love.keyboard.isDown("right") then scene.cam:add(v2d(4,0)) end
    if love.keyboard.isDown("up") then scene.cam:sub(v2d(0,4)) end
    if love.keyboard.isDown("down") then scene.cam:add(v2d(0,4)) end

  end

  if draggingPart then
    local boardScale=v2d(1/33,1/98)
    draggingPart:visualsUpdate(dt)
    draggingPart:inputsUpdate(dt)
    draggingPart.v_pos=(mouse-draggingPartOffset):round()
    draggingPart.newPos=(mouse-draggingPartOffset):mul(boardScale):round()
  end

  if touchingComponent then
    touchingComponent:touching(mouse)
  end

  for part in scene.components:iterate() do
    part:inputsUpdate(dt)
    part:visualsUpdate(dt)
  end
end

function love.draw()
  love.graphics.setCanvas(mainCanvas)
  
  love.graphics.clear()
  love.graphics.draw(bg_image,bg_quad,-(scene.cam.x%bg_image:getWidth()),-(scene.cam.y%bg_image:getHeight()))

  if draggingPart then
    local drawPos=draggingPart.newPos*v2d(33,98)-scene.cam
    local dimensions=draggingPart.dimensions
    local dx,dy=drawPos.x+0.5,drawPos.y+0.5
    local w,h=dimensions.x,dimensions.y
    love.graphics.setColor(0,math.sin(t*8+.4)/4+.25,math.sin(t*8)/2+.5)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line",dx,dy,w,h)
    love.graphics.setColor(1,1,1)
    love.graphics.setLineWidth(1)

  end
  local cam=scene.cam
  for part in scene.components:iterate() do
    if part:onScreen() then
      part:draw((part.v_pos-cam):round())
    end
  end
  for part in scene.components:iterate() do
    if part:onScreen() then
      for _,port in pairs(part.ports) do
        port:draw()
      end
    end
  end
  for part in scene.components:iterate() do
    for _,port in pairs(part.ports) do
      if port.input and port.link then port.link:draw() end
    end
  end
  
  if draggingPart then
    draggingPart:draw(draggingPart.v_pos-cam)
    for _,port in pairs(draggingPart.ports) do
      port:draw()
    end
    for _,port in pairs(draggingPart.ports) do
      if port.link then port.link:draw() end
    end
  end
  

  if linkingPort then
    local a=linkingPort:getScreenPos():round()
    cable.draw(a,v2d(love.mouse.getPosition())*(1/scene.scale),{1,1,1},linkingPort.typeData)
  end

  local count=0
  for part in scene.components:iterate() do
    count = count + 1
    --debug(count..":",tostring(part))
  end

  debug(draggingPart)
  debug(linkingPort)

  debug(scene.scale)
  debug(scene.cam.x,scene.cam.y)
  debug(love.mouse:getPosition())

  
  love.graphics.setCanvas()
  love.graphics.draw(mainCanvas,0,0,0,scene.scale,scene.scale)
  
  love.graphics.print(debugtext,1,1)
end

function love.mousepressed(x,y)
  if focusedComponent then focusedComponent.focused=false end
  focusedComponent=nil
  local mouse=v2d(x,y)*(1/scene.scale)+scene.cam
  for part in scene.components:iterate() do
    if part:pointTouching(mouse) then
      local component=part:getHoveredComponent(mouse)
      local port,dist=part:nearestPort(mouse)
      if component then
        component:touchStart(mouse)
        touchingComponent=component
        focusedComponent=component
        component.focused=true
      elseif dist < port.typeData.dist then
        if port.link then
          if port.input then
            linkingPort = port.link.from
          else
            linkingPort = port.link.to
          end
          port.link:destroy()
        else
          linkingPort = port
        end
        print(linkingPort)
      else
        if not draggingPart then
          scene.components:remove(part)
          part:unsetOccupied()
          draggingPartOffset=mouse-part.v_pos
          part.v_pos:add(v2d(love.math.random(-20,20),love.math.random(-20,20)))
          draggingPart=part
        end
      end
    end
  end
end

function love.mousereleased(x,y)
  local mouse=v2d(x,y)*(1/scene.scale)+scene.cam
  
  if focusedComponent then focusedComponent.focused=false end

  if draggingPart then
    if not draggingPart:getOccupied(draggingPart.newPos) then
      draggingPart.pos=draggingPart.newPos
    end
    scene.components:addEnd(draggingPart)
    draggingPart:setOccupied()
    draggingPart=nil
  end
  if touchingComponent then
    touchingComponent:touchEnd(mouse)
    touchingComponent = nil
  end
  if linkingPort then
    print("linkingport")
    for part in scene.components:iterate() do
      if part:pointTouching(mouse) then
        local port,dist=part:nearestPort(mouse)
        if dist < port.typeData.dist then
          --print("trying to drop",dist)
          local success,err=cable.create(port,linkingPort)
          if not success then
            print("link failed",err)
          end
          linkingPort=nil
        end
      end
    end
  end
  linkingPort=nil
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
  if focusedComponent then
    focusedComponent:keyPressed(key)
  end
  if key == "tab" then
    tick(scene,10000)
  end
end

function love.textinput(char)
  
  if focusedComponent then
    focusedComponent:textInput(char)
  end
end

function tick(scene,max)
  scene.nextPending={}
  for part in scene.components:iterate() do
    for _,port in pairs(part.ports) do
      port.sending=nil
    end
    part:tickStarted()
    part:genOutputs()
    for _,port in pairs(part.ports) do
      if port.input and not port.link then
        part:recieveInput(port,port.typeData.lowValue)
      end
    end
  end
  local quota=max or 1000
  local i = 0
  while #scene.nextPending > 0 do
    i = i + 1
    --print("cycle",i,#scene.nextPending)
    local pending=scene.nextPending
    scene.nextPending={}
    local prev=quota
    for _,pendingPort in ipairs(pending) do
      if pendingPort.link then
        --print(pendingPort,pendingPort.sending,pendingPort.owner.name)
        local target=pendingPort.link.to
        local value=pendingPort.sending
        pendingPort.lastSent=value
        --print(value)
        target.lastValue=value
        target.owner:recieveInput(target,value)
        target.owner:genOutputs()
        quota=quota-1
        if quota<=0 then goto excededQuota end
      end
      pendingPort.sending=nil
    end
    --print("used:",prev-quota)
  end
  ::excededQuota::
  --print("remaining:"..quota.."/"..max)

  for part in scene.components:iterate() do
    part:tickEnd()
  end
end

function love.wheelmoved(dx,dy)
  if dy~=0 then
    local scalePos=v2d(love.mouse.getPosition())/scene.scale
    
    
    
    
    local prevscale = scene.scale
    
    scene.scale=scene.scale+dy
    scene.scale=math.max(scene.scale,1)
    scene.scale=math.min(scene.scale,6)
    
    scene.cam:add(scalePos):sub(scalePos*(prevscale/scene.scale)):round()

    love.resize(love.graphics.getDimensions())
  end
end