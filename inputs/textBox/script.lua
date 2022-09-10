local v2d = require "vector"

local input={}

function input:initInput(pos,size,settings)
  settings=settings or {}
  self.r_pos=pos or v2d(0,0)
  self.size=size or v2d(10,10)
  self.lines={}
  ((settings.default or "").."\n"):gsub("([^\n]*)\n",function(st)
    table.insert(self.lines,{text=st})
  end)
  self.cursorCol=1
  self.cursorRow=1
  self.lineCallback=settings.lineCallback or function()end
  self.callback=settings.callback
  self.keyCallback=settings.keyCallback
  self.mask=settings.mask
  self.maxChars=settings.maxChars or math.huge
  self.maxRows =settings.maxRows  or math.huge
  self.screenLock = true

  for l,line in ipairs(self.lines) do
    self.lineCallback(line,l)
  end
end

function input:update(dt)
end

function input:keyPressed(key)
  if self.keyCallback then self.keyCallback(key) end
  local line=self.lines[self.cursorRow].text
  if key=="backspace" then
    if self.cursorCol>1 then
      line=line:sub(1,self.cursorCol-2)..line:sub(self.cursorCol,-1)
      self.cursorCol=self.cursorCol-1
    elseif self.cursorRow>1 and #self.lines>1 then
      local pre_half=self.lines[self.cursorRow-1].text
      line=pre_half..line
      table.remove(self.lines,self.cursorRow)
      self.cursorRow=self.cursorRow-1
      self.cursorCol=#pre_half+1
    end
    self.lines[self.cursorRow].text=line
    self.lineCallback(self.lines[self.cursorRow],self.cursorRow)
    if self.callback then self.callback() end
  elseif key=="up" then
    self.cursorRow=math.min(math.max(1,self.cursorRow-1),#self.lines)
  elseif key=="down" then
    self.cursorRow=math.min(math.max(1,self.cursorRow+1),#self.lines)
  elseif key=="left" then
    if self.cursorCol<=1 then
      if self.cursorRow>1 then
        self.cursorRow=self.cursorRow-1
        self.cursorCol=#self.lines[self.cursorRow].text+1
      end
    else
      self.cursorCol=math.mid(1,self.cursorCol-1,#line+1)
    end
  elseif key=="right" then
    if self.cursorCol>=#line+1 then
      if self.cursorRow<#self.lines then
        self.cursorRow=self.cursorRow+1
        self.cursorCol=1
      end
    else
      self.cursorCol=math.mid(1,self.cursorCol+1,#line+1)
    end
  elseif key=="return" then
    self.lines[self.cursorRow].text=line:sub(1,self.cursorCol-1)
    self.lineCallback(self.lines[self.cursorRow],self.cursorRow)
    table.insert(self.lines,self.cursorRow+1,{text=line:sub(self.cursorCol,-1)})
    self.cursorRow=self.cursorRow+1
    self.lineCallback(self.lines[self.cursorRow],self.cursorRow)
    self.cursorCol=1
  end


end

function input:textInput(char)
  local line=self.lines[self.cursorRow].text
  if #line<self.maxChars and ((not self.mask) or self.mask:find(char,1,true)) then
    self.lines[self.cursorRow].text=line:sub(1,self.cursorCol-1)..char..line:sub(self.cursorCol,-1)
    self.cursorCol=self.cursorCol+1
    self.lineCallback(self.lines[self.cursorRow],self.cursorRow)
  end
  if self.callback then self.callback() end
end

function input:draw(drawPos)
  love.graphics.setColor(1,1,1)
  --love.graphics.rectangle("line",drawPos.x,drawPos.y,self.size.x,self.size.y)
end

function input:isOverlapping(mouse)
  return mouse>=self.r_pos+self.owner.v_pos-v2d(1,1) and mouse<=self.r_pos+self.owner.v_pos+self.size
end

return input