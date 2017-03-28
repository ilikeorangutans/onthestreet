local Stat = {}

function Stat:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  assert(o.title)
  o.min = o.min or 0
  o.max = o.max or 100
  o.value = o.value or 100

  return o
end

function Stat:update(dt, modifier)
  self:add(dt * modifier)
end

function Stat:add(amount)
  self.value = self.value + amount
  if self.value > self.max then self.value = self.max end
  if self.value < self.min then self.value = self.min end
end

return Stat
