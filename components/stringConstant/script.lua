local newport = require "classes.ports"
local seg = require "graphics.7seg"
local inputs = require "classes.inputs"
local v2d = require "vector"

local image = love.graphics.newImage("components/stringConstant/sprite.png")
local chars=" abcdefghijklmnopqrstuvwxyz_,:#-0123456789"
local font = love.graphics.newImageFont("graphics/monofont.png",chars)

local function initComponent(self)
  self.w=3
  self.inputs={
    text=inputs.textBox.create(self,v2d(12,6),v2d(68,80),{
      default="hi\nthis is a text\nbox",
      charSize=v2d(5,7),
      maxRows=12,
      maxCols=12,
      mask=chars,
      lineCallback=function(line,lineI)
        print(line.text,lineI)
      end
    })
  }
  print(self.inputs.text.cursorCol)
  
  self.output=newport(self,90,82,false,"stringRibbon")
  
  function self:draw(pos)
    local text=self.inputs.text
    love.graphics.draw(image,pos.x,pos.y)
    love.graphics.print(tostring(self.output.lastSent),pos.x,pos.y-32)
    local col = 1
    local row = 1
    local _,err = pcall(function()
      row=text.cursorRow-1
      col=math.min(text.cursorCol,#text.lines[text.cursorRow].text+1)-1
    end)
    --print(text.cursorCol,text.cursorRow)
    --print(err)
    
    love.graphics.setColor(0,0,0)
    if t%1>.5 then
      love.graphics.rectangle("fill",pos.x+text.r_pos.x+col*5-1,pos.y+text.r_pos.y+row*9,1,7)
    end
    love.graphics.setColor(1,1,1)
    local drawtext=love.graphics.newText(font,"")
    --drawtext:clear()
    for i,line in ipairs(text.lines) do
      drawtext:add(line.text,text.r_pos.x,text.r_pos.y+(i-1)*9)
    end
    love.graphics.setColor(0,0,0)
    love.graphics.draw(drawtext,pos.x,pos.y)
    love.graphics.setColor(1,1,1)
  end

  function self:genOutputs()
    local st=""
    for l,line in ipairs(self.inputs.text.lines) do
      st=st..line.text..(l~=#self.inputs.text.lines and "\n" or "")
    end

    if #st > 1000 then
      self.output:send("")
    else
      self.output:send(st)
    end
  end
  
  function self:tickEnd()
  end

end

return initComponent