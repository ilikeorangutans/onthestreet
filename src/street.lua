local Street = {}
function Street:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.width = 1000
  o.height = 100

  o.interactables = {}
  table.insert(o.interactables, {
    title = "Trashcan",
    x = 10,
    y = 20,
    w = 10,
    h = 40,
  })

  return o
end


return Street
