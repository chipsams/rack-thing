local tables={}

local function processTable(table)
  table=table:gsub("%s","")
  local truth={}
  local symbols={"false","true","z","?"}
  for lA=1,4 do
    for lB=1,4 do
      local v=table:sub(lA*4+lB-4,lA*4+lB-4)
      if v=="0" then v=false end
      if v=="1" then v=true  end
      local k=symbols[lA]..symbols[lB]
      truth[k]=v
      while #k<10 do k=" "..k end
    end
  end
  return truth
end

local function calcTable(table)
  if not tables[table] then tables[table]=processTable(table) end
  return function(a,b) return tables[table][tostring(a)..tostring(b)] end
end

return calcTable