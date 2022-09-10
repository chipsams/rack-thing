local newport = require "classes.ports"
local inputs = require "classes.inputs"
local seg = require "graphics.7seg"
local v2d = require "vector"

local image = love.graphics.newImage("components/calculator/sprite.png")
local chars = "laxyz0123456789()+-*/%"
local font = love.graphics.newImageFont("components/calculator/exprFont.png",chars)

local function initComponent(self)
  self.out_v = 0
  self.w = 1
  self.h = 1
  self.expressions={
   --######## 8 char max
    "a-50",
    "l*4+50",
    ""
  }

  self.inputs={}
  self.enable_signals={}

  for l=1,3 do
    local textbox=inputs.textInput.create(self,v2d(2,22+l*7-7),v2d(28,7),{default="",callback=function()self.recompile(l)end,mask=chars.."LAXYZ",maxChars=7})
    self.inputs[l]=textbox
    self.expressions[l]=textbox
    self.enable_signals[l]=newport(self, -3+l*6,88,true,"boolean")
  end

  self.inA=newport(self,9,55,true)
  self.inX=newport(self,23,55,true)
  self.inY=newport(self,9,69,true)
  self.inZ=newport(self,23,69,true)

  self.out=newport(self,25,89)

  self.lastCompiled={}
  self.functions={}
  self.errors={}
  
  
  function self:recieveInput(port,value)
  end
  
  function self:genOutputs()
    local prev_v=0
    local values={self.inA.lastValue,self.inX.lastValue,self.inY.lastValue,self.inZ.lastValue}
    --print(unpack(values))
    for l=1,3 do
      --print(self.expressions[l].text..",","l = "..prev_v)
      if not self.enable_signals[l].link or self.enable_signals[l].lastValue then
        prev_v=self.functions[l](prev_v,unpack(values))
      end
      prev_v=math.min(math.floor(math.abs(prev_v)),999)*(prev_v<0 and -1 or 1)
    end
    self.out_v=prev_v
    self.out:send(prev_v)
  end
  
  local function compile(expr)
  if expr=="" then expr="l" end
  local func="return function(l,a,x,y,z) return "..expr.." end"
  local err
  do
    local brackets=expr
    local count=1
    while count>0 do
      brackets,count=brackets:gsub("%b()",function(st) return ("#"):rep(#st) end)
    end
    local pos1=brackets:find("%(")
    local pos2=brackets:find("%)")
    if pos1 or pos2 then
      return false,"unmatched brackets!",pos1 or pos2
    end
  end
  local pos=expr:find("%l%d")
  if pos then return false,"digit can't be adjacent to port!",pos,pos+1 end
  local pos=expr:find("%d%l")
  if pos then return false,"digit can't be adjacent to port!",pos,pos+1 end
  local pos,posEnd=expr:find("%(+%)+")
  if pos then return false,"empty brackets!",pos,posEnd end
  local pos=expr:find("[%+%-%*/%%]%)")
  if pos then return false,"operator cannot go directly next to open side of bracket!",pos,pos+1 end
  local pos=expr:find("%([%+%-%*/%%]")
  if pos then return false,"operator cannot go directly next to open side of bracket!",pos,pos+1 end
  local pos=expr:find("[%l%d]%(")
  if pos then return false,"value cannot go directly next to closed side of bracket!",pos,pos+1 end
  local pos=expr:find("%)[%l%d]")
  if pos then return false,"value cannot go directly next to closed side of bracket!",pos,pos+1 end
  local pos=expr:find("^[%+%-%*/%%]")
  if pos then return false,"an operator cannot have nothing to its left!",pos end
  local pos=expr:find("[%+%-%*/%%]$")
  if pos then return false,"an operator cannot have nothing to its right!",pos end
  local pos=expr:find("[%+%-%*/%%][%+%-%*/%%]")
  if pos then return false,"two operators cannot be directly adjacent!",pos,pos+1 end

  local pos=expr:find("%l%l")
  if pos then
    return false,"a port cannot directly follow another!",pos,pos+1
  else
    func,err=load(func,nil,nil,{})
  end
  if not func then
    return false,err,1,#expr
  else
    err,func=pcall(func)
    return func
  end
  end

  function self.recompile(l)
    local func,err,posL,posR = compile(self.expressions[l].text)
    posR=posR or posL
    --if not func then print((" "):rep(posL-1)..("^"):rep(posR-posL+1).."\n"..err) end
    self.errors[l]=(not func) and {l=posL,r=posR} or nil
    self.functions[l]=func or function(l) return l end
  end

  function self:tickStarted()
    for l=1,3 do
      if self.lastCompiled[l]~=self.expressions[l].text then
        self.recompile(l)
      end
    end 
  end

  function self:draw(pos)
    love.graphics.draw(image,pos.x,pos.y)
    local prev=love.graphics.getFont()
    love.graphics.setFont(font)
    for l=1,3 do
      local drawY=pos.y+23+l*7-7
      love.graphics.print(self.expressions[l].text,pos.x+2,drawY)
      if self.errors[l] then
        love.graphics.line(pos.x-3+self.errors[l].l*4,drawY,pos.x+2+self.errors[l].r*4,drawY)
      end
    end
    love.graphics.setFont(prev)
    seg.standardDisplay(self.out_v,pos.x+4,pos.y+7)
  end
end

return initComponent