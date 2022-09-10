local function coolRect(dx,dy,w,h,mag)
  mag=mag or 4

  local r,g,b=love.graphics.getColor()
  local thickness=love.graphics.getLineWidth()
  local function ro(l) return math.sin(l*math.pi*2+t)*mag end
  local subdiv=0.0625
  for ol=0,1,0.5 do
    love.graphics.setLineWidth(1+ol*2)
    local verts={}
    love.graphics.setColor(0,ol/2,ol/4+0.75)
    local o=2^(-ol)
    local tf=1+ol/10
    for l=0,1-subdiv,subdiv do
      table.insert(verts,dx+w*l+ro(l+0+o+tf*t))
      table.insert(verts,dy+ro(l+0+o+tf*t))
    end
    for l=0,1-subdiv,subdiv do
      table.insert(verts,dx+w+ro(l+1+o+tf*t))
      table.insert(verts,dy+h*l+ro(l+1+o+tf*t))
    end
    for l=0,1-subdiv,subdiv do
      table.insert(verts,dx+w*(1-l)+ro(l+2+o+tf*t))
      table.insert(verts,dy+h+ro(l+2+o+tf*t))
    end
    for l=0,1-subdiv,subdiv do
      table.insert(verts,dx+ro(l+3+o+tf*t))
      table.insert(verts,dy+h*(1-l)+ro(l+3+o+tf*t))
    end
    table.insert(verts,verts[1])
    table.insert(verts,verts[2])
    love.graphics.line(verts)
  end
  love.graphics.setColor(r,g,b)
  love.graphics.setLineWidth(thickness)
end

return coolRect