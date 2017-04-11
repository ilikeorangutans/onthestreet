local Point = {}

function Point:new(x, y)
  local o = {}
  setmetatable(o, self)
  self.__index = self

  o.x = x
  o.y = y

  return o
end

function Point:update(obj)
  self.x = obj.x
  self.y = obj.y
end

function Point:distance(point)
  local dx = self.x - point.x
  local dy = self.y - point.y
  return math.sqrt((dx * dx) + (dy * dy))
end

function Point:__tostring()
  return string.format("%d/%d", self.x, self.y)
end

return Point
