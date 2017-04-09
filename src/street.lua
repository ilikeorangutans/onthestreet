local Street = {}
function Street:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.width = 2000
  o.height = 400

  o.interactables = {}
  table.insert(o.interactables, {
    title = "Trashcan",
    x = 10,
    y = 20,
    w = 10,
    h = 40,
  })
  table.insert(o.interactables, {
    title = "Trashcan",
    x = 1000,
    y = 200,
    w = 10,
    h = 40,
  })
  table.insert(o.interactables, {
    title = "Trashcan",
    x = 800,
    y = 200,
    w = 10,
    h = 40,
  })

  for i, item in ipairs(o.interactables) do
    print(" Item " .. i .. ": " .. item.title .. " at " .. item.x .. "/" .. item.y)
  end

  return o
end

function Street:moveTo(pos)
  local x = pos.x
  local y = pos.y
  if x < 0 then x = 0 end
  if x > self.width then x = self.width end
  if y < 0 then y = 0 end
  if y > self.height then y = self.height end
  return {x=x,y=y}
end


return Street
