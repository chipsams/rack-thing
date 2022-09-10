function math.lerp(a,b,t)
  return (1-t)*a+b*t
end

function math.mid(l,v,u)
  return math.min(math.max(l,v),u)
end