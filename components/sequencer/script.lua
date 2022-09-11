local newport = require "classes.ports"
local inputs = require "classes.inputs"
local v2d = require "vector"

local image   = love.graphics.newImage("components/sequencer/sprite.png")
local toggle  = love.graphics.newImage("components/sequencer/toggle.png")
local br_up   = love.graphics.newImage("components/sequencer/bracketup.png")
local br_down = love.graphics.newImage("components/sequencer/bracketdown.png")
local ticker  = love.graphics.newImage("components/sequencer/tickindicator.png")

local function initComponent(self)
  --these are the defaults, but it doesn't matter for this case.
  self.w = 2
  self.h = 1

  self.inputs={}

  self.inputs.sequencerData=inputs.sequencerBoard.create(self,v2d(18,8))

  self.value=0

  self.tick=0
  self.running=false

  for l=0,16 do
    local input=inputs.simpleButton.create(self,v2d(14,8+l*5),br_up)
    self.inputs[#self.inputs+1]=input

    local input=inputs.simpleButton.create(self,v2d(14,10+l*5),br_down)
    self.inputs[#self.inputs+1]=input
    
  end

  self.cond=newport(self,4,38,true,"boolean")
  self.start=newport(self,4,66,true,"boolean")
  self.stop=newport(self,4,90,true,"boolean")
  self.outputs={
    newport(self,60, 6,false,"boolean"), --a
    newport(self,60,15,false,"boolean"), --b
    newport(self,60,24,false,"boolean"), --c
    newport(self,60,33,false,"boolean"), --d
  }
  self.out_index=newport(self,57,86)
  
  function self:draw(pos)
    love.graphics.draw(image,pos.x,pos.y)
    for _,input in pairs(self.inputs) do
      input:draw(input.r_pos+pos)
    end
    if self.running then
      love.graphics.draw(ticker,pos.x+9,pos.y+8+self.tick*5)
    end
  end
  
  function self:tickStarted()
    
    if self.running then
      self.tick = self.tick + 1
      for l=1,4 do
        print(({"a","b","c","d"})[l],self.inputs.sequencerData.toggleData[l-1][self.tick])
      end
      print(self.stopNextTick)
      if self.tick>16 or self.stopNextTick then self.tick, self.running = 0, false end
    else
      if self.startNextTick then
        self.tick, self.running = 0, true
      end
    end
    self.stopNextTick=false
  end

  function self:genOutputs()
    self.stopNextTick = self.stop.lastValue  and     self.running
    self.startNextTick= self.start.lastValue and not self.running

    if self.running then
      for l=1,4 do
        self.outputs[l]:send(self.inputs.sequencerData.toggleData[l-1][self.tick])
      end
      self.out_index:send(self.tick)
    else
      for l=1,4 do self.outputs[l]:send(false) end
      self.out_index:send(-999)
    end
  end
end

return initComponent