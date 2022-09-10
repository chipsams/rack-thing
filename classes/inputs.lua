if globaldata.inputs then
  return globaldata.inputs
end

local defaultFunctions={}
defaultFunctions.__index=defaultFunctions

function defaultFunctions:initInput(pos,startState)end
function defaultFunctions:update(dt)end
function defaultFunctions:touchStart(mouse)end
function defaultFunctions:touchEnd(mouse)end
function defaultFunctions:touching(mouse)end
function defaultFunctions:draw(drawPos)end
function defaultFunctions:isOverlapping(mouse)end
function defaultFunctions:keyPressed(key)end
function defaultFunctions:textInput(char)end



local inputs={}
for _,file in pairs(love.filesystem.getDirectoryItems("inputs")) do
  local path="inputs/"..file.."/script.lua"
  print(path)
  local value=load(love.filesystem.read(path))()
  setmetatable(value,defaultFunctions)
  value.__index=value
  function value.create(owner,...)
    local newInput={owner=owner}
    setmetatable(newInput,value)
    newInput:initInput(...)
    return newInput
  end
  inputs[file]=value
end

globaldata.inputs=inputs

return inputs