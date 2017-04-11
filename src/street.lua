local Street = {}
function Street:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.width = 5000
  o.height = 400

  o.blocks = {}
  o.interactables = {}

  o:randomize()

  for i, item in ipairs(o.interactables) do
    print(" Item " .. i .. ": " .. item.title .. " at " .. item.x .. "/" .. item.y)
  end

  return o
end

function createHydrant(x)
  return {
    title = "Fire Hydrant",
    x = x,
    y = 230,
    w = 20,
    h = 40,
  }
end

function createTrashCan(x)
  return {
    title = "Trashcan",
    x = x,
    y = 200,
    w = 80,
    h = 40,
    searchable = true,
  }
end

function Street:randomize()
  local minBlockWidth = 600
  local streetWidth = 400
  local numIntersections = 1 + math.random(5)

  local x = streetWidth / 2

  for i=0, numIntersections do
    local left = x
    local blockWidth = math.max(minBlockWidth, math.random(minBlockWidth + (self.width / 4)))
    local right = left + blockWidth
    if right > self.width then right = self.width end
    print("Generating block " .. i .. " at " .. left .. " to " .. right)

    table.insert(self.blocks, {
      left = left,
      right = right,
      height = 300,
    })

    -- Add trashcans on either end
    table.insert(self.interactables, createTrashCan(left + 100))
    table.insert(self.interactables, createTrashCan(right - 100))

    -- Add a few fire hydrants
    local numHydrants = minBlockWidth / 400
    for i=1, numHydrants do
      local x = left + 140 + math.max(i * 400)
      table.insert(self.interactables, createHydrant(x))
    end


    if right >= self.width then break end

    x = right + streetWidth
  end

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
