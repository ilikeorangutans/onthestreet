local Point = require('point')
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

  for i, block in ipairs(self.street.blocks) do
    local left = self:toScreen({x=block.left, y=block.height})
    local right = self:toScreen({x=block.right, y=block.height})

    love.graphics.setColor(80, 80, 80)
    love.graphics.rectangle('fill', left.x, 0, right.x - left.x, left.y)
  end

  for i, item in ipairs(self.street.interactables) do
    if visible:show(item) then
      local coords = self:toScreen(item)

      if item.highlight then
        love.graphics.setColor(255, 128, 0, 255)
        love.graphics.rectangle('fill', coords.x - 2, coords.y - 2, item.w + 4, item.h + 4)

        love.graphics.setColor(255, 0, 0, 255)
        love.graphics.print(item.title, coords.x, coords.y - 20)
      end

      love.graphics.setColor(128, 128, 128, 255)
      love.graphics.rectangle('fill', coords.x, coords.y, item.w, item.h)
    end
  end
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
