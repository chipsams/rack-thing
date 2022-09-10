
local seg=love.graphics.newImage("graphics/7seg.png")

local text="0123456789-"

local quads={}

for i=1,#text do
  local ch=text:sub(i,i)
  local quad=love.graphics.newQuad(i*7-7,0,7,12,seg:getDimensions())
  quads[ch]=quad
end

local fns={}

function fns.drawChar(ch,x,y)
  love.graphics.draw(seg,quads[tostring(ch)],x,y)  
end

local powersOf10 = {[0]=1,10,100,1000}
function fns.standardDisplay(number,x,y)
  if number < 0 then
    fns.drawChar("-",x-1,y)
  end
  number=math.abs(number)
  local startrendering=false
  for l=2,0,-1 do
    local digit=math.floor(number/powersOf10[l]%10)
    if digit>0 then startrendering=true end
    if startrendering or l==0 then
      fns.drawChar(digit,x+19-l*7,y)
    end
  end
end

return fns