local ll_mt={}
ll_mt.__index=ll_mt

local function new_ll()
  return setmetatable({first=nil,last=nil},ll_mt)
end

function ll_mt:iterate()
  local element=self.first
  return function()
    if not element then return nil end
    local prevElement = element
    element = element.next
    return prevElement
  end
end

function ll_mt:iterateEnd()
  local element=self.last
  return function()
    if not element then return nil end
    local prevElement = element
    element = element.prev
    return prevElement
  end
end

function ll_mt:add(element)
  if not self.last then self.last=element end
  element.next=self.first
  if self.first then self.first.prev=element end
  self.first=element
end

function ll_mt:addEnd(element)
  if not self.first then self.first=element end
  element.prev=self.last
  if self.last then self.last.next=element end
  self.last=element
end

function ll_mt:remove(element)
  if element.prev then
    element.prev.next = element.next
  end
  if element.next then
    element.next.prev = element.prev
  end

  if element==self.first then
    self.first=element.next
  end

  if element==self.last then
    self.last=element.prev
  end

  element.prev = nil
  element.next = nil
end

return new_ll