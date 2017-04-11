local StreetView = {}

function StreetView:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.x = o.x or 0
  o.y = o.y or 0

  o.screenx = o.screenx or 0
  o.screeny = o.screeny or 0

  o.bounds = {
    x = o.screenx,
    y = o.screeny,
    w = o.w,
    h = o.h
  }

  return o
end

function StreetView:draw()
  local bounds = self.bounds

  local screenx, screeny = self.bounds.x, self.bounds.y

  love.graphics.setColor(255, 0, 0)
  love.graphics.rectangle('line', screenx, screeny, self.bounds.w, self.bounds.h)

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
      local coords = self:toScreen(item)

      if item.highlight then
        love.graphics.setColor(255, 128, 0, 255)
        love.graphics.rectangle('fill', coords.x - 2, coords.y - 2, item.w + 4, item.h + 4)
      end

      love.graphics.setColor(128, 128, 128, 255)
      love.graphics.rectangle('fill', coords.x, coords.y, item.w, item.h)
      love.graphics.setColor(255, 0, 0, 255)
      love.graphics.print(item.title, coords.x, coords.y)
    end
  end

  love.graphics.setColor(255, 0, 0)
  local pos = self:toScreen({x=0, y=0})
  love.graphics.line(pos.x, 0, pos.x, 600)
end

function StreetView:toScreen(coord)
  local x = coord.x - self.x + self.bounds.x
  local y = coord.y - self.y + self.bounds.y

  return {x=x, y=y}
end

function StreetView:toWorld(coord)
  local x = coord.x + self.x - self.bounds.x
  local y = coord.y + self.y - self.bounds.y
  return {x=x, y=y}
end

function StreetView:center(pos)
  local halfWidth = self.bounds.w / 2
  local x = pos.x - halfWidth
  if x < 0 then x = 0 end

  local halfHeight = self.bounds.h / 2
  local y = pos.y - halfHeight
  if y < 0 then y = 0 end

  self.x = x
  self.y = y
end

return StreetView
