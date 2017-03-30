local StreetView = {}

function StreetView:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.x = o.x or 0
  o.y = o.y or 0

  o.bounds = {
    x = 0,
    y = 0,
    w = o.w,
    h = o.h
  }

  return o
end

function StreetView:draw()
  local bounds = self.bounds

  local visible = {
    x=self.x,
    y=self.y,
    w=self.w,
    h=self.h,
    show = function(self, item)
      return true
    end
  }

  for i, item in ipairs(self.street.interactables) do
    if visible:show(item) then
      --print("Showing item " .. i .. ": " .. item.title)

      love.graphics.setColor(128, 128, 128)
      local coords = self:toScreen(item)
      love.graphics.rectangle('fill', coords.x, coords.y, item.w, item.h)
    end
  end
end

function StreetView:toScreen(coord)
  local x = coord.x - self.x
  local y = coord.y - self.y

  return {x=x, y=y}
end

function StreetView:toWorld(coord)
  local x = coord.x + self.x
  local y = coord.y + self.y
  return {x=x, y=y}
end

return StreetView
