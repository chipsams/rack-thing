local vec_mt={isVec=true}
vec_mt.__index=vec_mt


--- creates a vector instance, adding all the metamethods associated with it.
---@param x number
---@param y number
---@return table
local function vector(x,y)
  return setmetatable({x=x,y=y},vec_mt)
end

--- adds a vector to the calling vector, modifying the original.
---@param vec table
---@return table
function vec_mt:add(vec)
  if type(vec)=="table" then
    if vec.isVec then
      self.x=self.x+vec.x
      self.y=self.y+vec.y
      return self
    else
      error("tried to add with a table that wasn't a vector!")
    end
  else
    error("tried to add with something that wasn't a vector! type() reports as: "..type(vec))
  end
end

--- adds the two vectors, creating a new one.
---@param a table
---@param b table
---@return table
function vec_mt.__add(a,b)
  if type(b)=="table" then
    if b.isVec then
      return vector(a.x+b.x,a.y+b.y)
    else
      error("tried to add with a table that wasn't a vector!")
    end
  else
    error("tried to add with something that wasn't a vector! type() reports as: "..type(b))
  end
end

--- subtracts a vector from the calling vector, modifying the original.
---@param vec table
---@return table
function vec_mt:sub(vec)
  if type(vec)=="table" then
    if vec.isVec then
      self.x=self.x-vec.x
      self.y=self.y-vec.y
      return self
    else
      error("tried to subtract with a table that wasn't a vector!")
    end
  else
    error("tried to subtract with something that wasn't a vector! type() reports as: "..type(vec))
  end
end

--- subtracts the two vectors, creating a new one.
---@param a table
---@param b table
---@return table
function vec_mt.__sub(a,b)
  if type(a)=="table" then
    if not a.isVec then
      error("tried to subtract with a table that wasn't a vector!")
    end
  else
    error("tried to subtract with something that wasn't a vector! type() reports as: "..type(a))
  end
  if type(b)=="table" then
    if not b.isVec then
      error("tried to subtract with a table that wasn't a vector!")
    end
  else
    error("tried to subtract with something that wasn't a vector! type() reports as: "..type(b))
  end
  return vector(a.x-b.x,a.y-b.y)
end

--- when called with a vector, multiplies each component individually. when called with a number, multiplies both components by the number. modifies the original vector.
---@param a table
---@param vecOrNum table/number
---@return table
function vec_mt:mul(vecOrNum)
  if type(vecOrNum)=="number" then
    self.x=self.x*vecOrNum
    self.y=self.y*vecOrNum
    return self
  elseif type(vecOrNum)=="table" then
    if vecOrNum.isVec then
      self.x=self.x*vecOrNum.x
      self.y=self.y*vecOrNum.y
      return self
    else
      error("tried to multiply with a table that wasn't a vector!")
    end
  else
    error("tried to multiply with something that wasn't a vector or a number! type() reports as: "..type(vecOrNum))
  end
end

--- when called with a vector, multiplies each component individually. when called with a number, multiplies both components by the number. returns a new vector.
---@param a table
---@param vecOrNum table/number
---@return table
function vec_mt.__mul(a,vecOrNum)
  if type(vecOrNum)=="number" then
    return vector(a.x*vecOrNum,a.y*vecOrNum)
  elseif type(vecOrNum)=="table" then
    if vecOrNum.isVec then
      return vector(a.x*vecOrNum.x,a.y*vecOrNum.y)
    else
      error("tried to multiply with a table that wasn't a vector!")
    end
  else
    error("tried to multiply with something that wasn't a vector or a number! type() reports as: "..type(vecOrNum))
  end
end

--- when called with a vector, multiplies each component individually. when called with a number, multiplies both components by the number. modifies the original vector.
---@param a table
---@param vecOrNum table/number
---@return table
function vec_mt:div(vecOrNum)
  if type(vecOrNum)=="number" then
    self.x=self.x/vecOrNum
    self.y=self.y/vecOrNum
    return self
  elseif type(vecOrNum)=="table" then
    if vecOrNum.isVec then
      self.x=self.x/vecOrNum.x
      self.y=self.y/vecOrNum.y
      return self
    else
      error("tried to divide by a table that wasn't a vector!")
    end
  else
    error("tried to divide by something that wasn't a vector or a number! type() reports as: "..type(vecOrNum))
  end
end

--- when called with a vector, divides each component individually. when called with a number, divides both components by the number. returns a new vector.
---@param a table
---@param vecOrNum table/number
---@return table
function vec_mt.__div(a,vecOrNum)
  if type(vecOrNum)=="number" then
    return vector(a.x/vecOrNum,a.y/vecOrNum)
  elseif type(vecOrNum)=="table" then
    if vecOrNum.isVec then
      return vector(a.x/vecOrNum.x,a.y/vecOrNum.y)
    else
      error("tried to divide by a table that wasn't a vector!")
    end
  else
    error("tried to divide by something that wasn't a vector or a number! type() reports as: "..type(vecOrNum))
  end
end

--- returns the magnitude of a vector.
---@return number
function vec_mt:magnitude()
  return math.sqrt(self.x*self.x+self.y*self.y)
end

--- returns the magnitude of a vector.
---@return number
function vec_mt:squaredMagnitude()
  return self.x*self.x+self.y*self.y
end

--- returns the direction of a vector, in radians.
---@return number
function vec_mt:direction()
  return math.atan2(self.y,self.x)
end

--- returns an exact copy of a vector.
---@return table
function vec_mt:copy()
  return vector(self.x,self.y)
end

--- normalizes a vector, making the length 1.
---@return table
function vec_mt:normalize()
  local inv_mag=1/self:magnitude()
  self.x=self.x*inv_mag
  self.y=self.y*inv_mag
  return self
end

function vec_mt:floor()
  self.x=math.floor(self.x)
  self.y=math.floor(self.y)
  return self
end
function vec_mt:round()
  self.x=math.floor(self.x+.5)
  self.y=math.floor(self.y+.5)
  return self
end

--creates a new vector, interpolated between the first two.
function vec_mt:lerp(vec,t)
  return vector((1-t)*self.x+vec.x*t,(1-t)*self.y+vec.y*t)
end

function vec_mt:__lt(vec)
  return self.x < vec.x and self.y < vec.y
end

function vec_mt:__le(vec)
  --print(self.x,"<=",vec.x,"&",self.y,"<=",vec.y)
  return self.x <= vec.x and self.y <= vec.y
end

return vector