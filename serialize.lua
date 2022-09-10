local function serialize_value(__s,__t,v)
  print(v,__s[v])
  if type(v) == "table" then
    if __s[v] then return "__s["..__s[v].."]",__s[v] end
    if getmetatable(v) then
      print("metatable")
      
      table.insert(__s,'"[placeholder'..(#__s+1)..']"')
      local index=#__s
      __s[v]=index

      local text="setmetatable({"
      for k,value in pairs(v) do
        if type(v)=="table" then
          local table_index=serialize_value(__s,__t,value)
          table.insert(__t,{k=serialize_value(__s,__t,k),i=index,ti=table_index})
          text=text..("["..serialize_value(__s,__t,k).."]".."= '[placeholder"..table_index.."]',") --trailing , are fine in lua.
        end
      end
      text=text.."},"..serialize_value(__s,__t,getmetatable(v))..")"

      __s[index]=text

      return "__s["..__s[v].."]",index
    else

      table.insert(__s,'"[placeholder'..(#__s+1)..']"')
      local index=#__s
      __s[v]=index

      local text="{"
      for k,value in pairs(v) do
        if type(value)=="table" then
          local table_index=serialize_value(__s,__t,value)
          table.insert(__t,{k=serialize_value(__s,__t,k),i=index,ti=table_index})
        else
          text=text..("["..serialize_value(__s,__t,k).."]".."="..serialize_value(__s,__t,value)).."," --trailing , are fine in lua.
        end
      end
      text=text.."}"

      __s[index]=text

      return "__s["..__s[v].."]",index
    end
  elseif type(v)=="number" then
    return tostring(v)
  elseif type(v)=="boolean" then
    return v and "true" or "false"
  elseif type(v)=="string" then
    return string.format("%q",v)
  elseif type(v)=="function" then
    return "load("..string.format("%q",string.dump(v))..")"
  else
    return "\"unfinished ("..type(v)..")\""
  end
end

local function serialize(v)
  print(v)
  local __s={}
  local __t={}
  local text=serialize_value(__s,__t,v)

  local link_text=table.concat(__t)

  text="__s={"..table.concat(__s,",").."}\nreturn "..text
  print(text)
  return text
end

return serialize