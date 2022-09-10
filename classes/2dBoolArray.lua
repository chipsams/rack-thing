
local mt={}
mt.__index=mt

function mt:set(x,y)
  self[y] = self[y] or {}
  self[y][x] = true
end

function mt:unset(x,y)
  self[y] = self[y] or {}
  self[y][x] = false
end

function mt:get(x,y)
  self[y] = self[y] or {}
  return self[y][x]
end

local function create()
  local arr=setmetatable({},mt)
  return arr
end

return create