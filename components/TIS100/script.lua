local newport = require "classes.ports"
local inputs = require "classes.inputs"
local v2d = require "vector"

local image = love.graphics.newImage("components/TIS100/sprite.png")

local chars=" abcdefghijklmnopqrstuvwxyz_,:#-0123456789"
local tisfont = love.graphics.newImageFont("graphics/monofont.png",chars)

local function tisCo(self)
  local function get(src)
    self.TIS.state="read"
    local success,value
    if src=="acc" then
      value=self.TIS.acc
    elseif tonumber(src) then
      value=tonumber(src)
    elseif src=="nil" then
      value=0
    else
      if not self.TIS.ports[src] then
        print(src)
      end
      self.TIS.ports[src].reading=true
      success=false
      while not success do
        success,value=self:get(self.TIS.ports[src].port)
        --print("waiting for src",src)
        if success then break end
        coroutine.yield()
      end
    end
    self.TIS.state="actv"
    return value
  end
  local function set(dst,value)
    self.TIS.state="wrte"
    if dst=="acc" then
      self.TIS.acc=value
    elseif dst=="nil" then
    else
      self.TIS.ports[dst].writing=true
      local success=false
      while not success do
        success=self:send(self.TIS.ports[dst].port,value)
        if success then break end
        --print("waiting for dst",dst)
        coroutine.yield()
      end
    end
    self.TIS.state="actv"
  end

  return function()
    local steps=self.inputs.code.lines
    while true do
      --print("co")
  
      local startL=self.TIS.line
      local function getToks(line)return steps[line] and steps[line].tokens or {} end
      local instr=getToks(self.TIS.line)
      while #instr==0 do
        self.TIS.line=self.TIS.line%20+1
        if self.TIS.line==startL then instr={"nop"} self.TIS.line=1 self.TIS.noCode=true break end
        instr=getToks(self.TIS.line)
      end
      --print(self.TIS.line,instr[1],instr[2],instr[3])
      local op=instr[1]
      if op=="nop" then
        coroutine.yield()
        self.TIS.line=self.TIS.line+1
      elseif op=="mov" then
        set(instr[3],get(instr[2]))
        coroutine.yield()
        self.TIS.line=self.TIS.line+1

      elseif op=="jro" then
        local value=get(instr[2])
        local line=self.TIS.line+value
        local toksAt=getToks(line)
        if value<0 then
          while #toksAt==0 do
            line=line+1
            toksAt=getToks(line)
          end
        elseif value>0 then
          while #toksAt==0 do
            line=line-1
            toksAt=getToks(line)
          end
        end
        coroutine.yield()
        self.TIS.line=line
      elseif op=="jgz" then
        if self.TIS.acc>0 then
          coroutine.yield()
          if self.TIS.labels[instr[2]] then
            self.TIS.line=self.TIS.labels[instr[2]]
          end
        else
          coroutine.yield()
          self.TIS.line=self.TIS.line+1
        end
      elseif op=="jez" then
        if self.TIS.acc==0 then
          coroutine.yield()
          if self.TIS.labels[instr[2]] then
            self.TIS.line=self.TIS.labels[instr[2]]
          end
        else
          coroutine.yield()
          self.TIS.line=self.TIS.line+1
        end
      elseif op=="jlz" then
        if self.TIS.acc<0 then
          coroutine.yield()
          if self.TIS.labels[instr[2]] then
            self.TIS.line=self.TIS.labels[instr[2]]
          end
        else
          coroutine.yield()
          self.TIS.line=self.TIS.line+1
        end
      elseif op=="jmp" then
        coroutine.yield()
        if self.TIS.labels[instr[2]] then
          self.TIS.line=self.TIS.labels[instr[2]]
        end

      elseif op=="add" then
        self.TIS.acc=math.mid(-999,self.TIS.acc+get(instr[2]),999)
        coroutine.yield()
        self.TIS.line=self.TIS.line+1
      elseif op=="sub" then
        self.TIS.acc=math.mid(-999,self.TIS.acc-get(instr[2]),999)
        coroutine.yield()
        self.TIS.line=self.TIS.line+1

      elseif op=="sav" then
        self.TIS.bak=self.TIS.acc
        coroutine.yield()
        self.TIS.line=self.TIS.line+1
      elseif op=="swp" then
        self.TIS.acc,self.TIS.bak=self.TIS.bak,self.TIS.acc
        coroutine.yield()
        self.TIS.line=self.TIS.line+1
      else
        coroutine.yield()
        self.TIS.line=self.TIS.line+1
      end
    end
  end
end

local function initComponent(self,text)
  self.w = 3
  self.h = 1
  
  self.TIS={acc=0,bak=0,ports={},line=1,state="actv",labels={}}

  self.inputs={
    code=inputs.textBox.create(self,v2d(14,14),v2d(70,68),{
      default=text,
      charSize=v2d(5,7),
      maxRows=12,
      maxCols=12,
      mask=chars,
      lineCallback=function(line,lineI)
        self.TIS.noCode=false
        self.TIS.line=1
        self.TIS.acc=0
        self.TIS.bak=0
        self.TIS.co=coroutine.create(tisCo(self))
        for name,target_line in pairs(self.TIS.labels) do
          print(name..":",target_line)
          if target_line==lineI then
            self.TIS.labels[name]=nil
          end
        end
        local st=line.text
        local tokens={}
        local highlighted={}
        local function highlight(st,r,g,b)
          table.insert(highlighted,{r,g,b})
          table.insert(highlighted,st)
        end

        local l=1
        local function chAt(i) return st:sub(i,i) end
        while l<=#st do
          if chAt(l):match("[%s,]") then
            local mtch_s,mtch_e=st:find("[%s,]+",l)
            local token=st:sub(mtch_s,mtch_e)
            highlight(token,0.75,0.75,0.75)
            l=mtch_e+1
          elseif chAt(l):match("[%l_]") then
            local mtch_s,mtch_e=st:find("[%l%d_]+:?",l)
            local token=st:sub(mtch_s,mtch_e)

            if token:sub(-1,-1)==":" then
              if #tokens==0 then
                self.TIS.labels[token:sub(1,-2)]=lineI
                highlight(token,0,0.5,1)
              else
                highlight(token,1,0,0)
              end
            else
              if self.TIS.labels[token] then
                highlight(token,0,0.5,1)
              else
                highlight(token,1,1,1)
              end
              table.insert(tokens,token)
            end
            l=mtch_e+1
          elseif chAt(l):match("#") then
            local token=st:sub(l,#st)
            highlight(token,0.75,0.75,0.75)
            l=#st+1
          elseif chAt(l):match("[%-%d]") then
            local mtch_s,mtch_e=st:find("%-?%d*",l)
            local token=st:sub(mtch_s,mtch_e)
            table.insert(tokens,token)
            highlight(token,1,1,0)
            l=mtch_e+1
          else
            highlight(chAt(l),1,0,0)
            l=l+1
          end
        end
        line.highlighted=highlighted
        line.tokens=tokens
      end
    })
  }

  self.ports={
    newport(self,50,6,false,"either"),
    newport(self,92,48,false,"either"),
    newport(self,50,90,false,"either"),
    newport(self,6,48,false,"either")
  }

  local dirs={"up","right","down","left"}
  for l,port in ipairs(self.ports) do
    port={port=port,reading=false,writing=false,dir=dirs[l],o_dir=dirs[(l+1)%4+1]}
    self.TIS.ports[dirs[l]]=port
    self.ports[l].dir=dirs[l]
  end

  self.TIS.co=coroutine.create(tisCo(self))

  function self:send(port,value)
    local linked=port:getLinked()
    if linked then
      local l_TIS=linked.owner.TIS
      if l_TIS then
        if l_TIS.ports[linked.dir].reading then
          l_TIS.ports[linked.dir].readValue=value

          self.TIS.ports[port.dir].writing=false
          l_TIS.ports[linked.dir].reading=false
          return true
        end
      else
        if not port.input then
          port:send(value)
          return true
        end
      end
    end
  end
  function self:get(port)
    local linked=port:getLinked()
    if linked then
      local l_TIS=linked.owner.TIS
      if l_TIS then
        if self.TIS.ports[port.dir].readValue then
          local value=self.TIS.ports[port.dir].readValue
          self.TIS.ports[port.dir].readValue=nil
          return true,value
        end
      else
        if port.input then
          return true,port.lastValue
        end
      end
    end
  end
    

  function self.genOutputs()
    
  end
  
  function self:tickStarted()
    local success,err=coroutine.resume(self.TIS.co)
    if not success then print("error in TIS:",err) end
  end

  function self:draw(pos)
    local code=self.inputs.code

    love.graphics.draw(image,pos.x,pos.y)
    local text=love.graphics.newText(tisfont,"")
    --text:clear()
    text:add(tostring(self.TIS.acc),21,3)
    text:add(tostring(self.TIS.bak),78,3)
    text:add(self.TIS.state,60,87)
    love.graphics.setColor(0.5,0.5,0.5)
    if not self.TIS.noCode then
      love.graphics.rectangle("fill",pos.x+14,pos.y+14+(self.TIS.line-1)*7,70,7)
    end
    love.graphics.setColor(1,1,1)
    for i,line in ipairs(code.lines) do
      text:add(line.highlighted,14,14+(i-1)*7)
    end
    local col=math.min(code.cursorCol,#code.lines[code.cursorRow].text+1)-1
    local row=code.cursorRow-1

    local c=1/(1+(t%1)*2)
    love.graphics.setColor(1,1,1,c)
    love.graphics.rectangle("fill",pos.x+13+col*5,pos.y+14+row*7,6,7)
    love.graphics.setColor(1,1,1)
    --[[
      for i,line in pairs(self.steps) do
        text:add(table.concat(line," "),(i==self.TIS.line and (t%1>0.5 and 15 or 16) or 14),14+(i-1)*7)
      end
    --]]
    love.graphics.draw(text,pos.x,pos.y)
  end
end

return initComponent