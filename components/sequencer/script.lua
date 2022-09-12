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


  self.openBrackets={}
  self.closeBrackets={}

  local function recalc_matches()
    for l=0,16 do
      self.openBrackets[l].matching=nil
      if self.openBrackets[l].toggle then
        local level = 0
        for i=l,16 do
          if self.openBrackets[i].toggle then
            level = level + 1
          end
          if self.closeBrackets[i].toggle then
            level = level - 1
            if level == 0 then 
              self.openBrackets[l].matching=i
              break
            end
          end
        end
      end
      self.closeBrackets[l].matching=nil
      if self.closeBrackets[l].toggle then
        local level = 0
        for i=l,0,-1 do
          if self.closeBrackets[i].toggle then
            level = level + 1
          end
          if self.openBrackets[i].toggle then
            level = level - 1
            if level == 0 then 
              self.closeBrackets[l].matching=i
              break
            end
          end
        end
      end
    end
  end

  for l=0,16 do
    local input=inputs.simpleButton.create(self,v2d(14,8+l*5),br_up,{callback=recalc_matches})
    self.inputs[#self.inputs+1]=input
    self.openBrackets[l]=input
    
    local input=inputs.simpleButton.create(self,v2d(14,10+l*5),br_down,{callback=recalc_matches})
    self.inputs[#self.inputs+1]=input
    self.closeBrackets[l]=input
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
    if self.stopNextTick then
      love.graphics.rectangle("fill",pos.x+1,pos.y+1,6,3)
    end
    if self.startNextTick then
      love.graphics.rectangle("fill",pos.x+1,pos.y+5,6,3)
    end
  end
  
  function self:tickStarted()
    
    if self.running then
      local justjumped=false
      if self.closeBrackets[self.tick].matching and not self.cond.typeData.isLow(self.cond.lastValue) then
        justjumped=true
        self.tick = self.closeBrackets[self.tick].matching
      else
        self.tick = self.tick + 1
      end
      
      while self.tick<=16 and not justjumped and self.openBrackets[self.tick].matching and self.cond.typeData.isLow(self.cond.lastValue) do
        self.tick = self.openBrackets[self.tick].matching+1
      end
      if self.tick>16 or self.stopNextTick then self.tick, self.running = 0, self.startNextTick end
    else
      if self.startNextTick then
        self.tick, self.running = 0, true
      end
    end
    self.stopNextTick=false
    self.startNextTick=false
  end

  function self:genOutputs()
    self.stopNextTick = self.stop.lastValue == true
    self.startNextTick= self.start.lastValue == true

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