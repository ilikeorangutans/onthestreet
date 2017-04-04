local Cell = {}
function Cell:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.neighbours = {
    top = nil,
    right = nil,
    bottom = nil,
    left = nil
  }
  o.links = {}
  o.x = 0
  o.y = 0

  return o
end

function Cell:isLinked(cell)
  if cell == self then return false end

  for _, link in ipairs(self.links) do
    if link == cell then return true end
  end
  return false
end

function Cell:link(cell, oneway)
  if not cell then return end
  if cell == self then return end

  table.insert(self.links, cell)
  assert(self:isLinked(cell))

  if not oneway then
    cell:link(self, true)
    assert(cell:isLinked(self))
  end
end

local Maze = {}

function Maze:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.width = o.width or 10
  o.height = o.height or 10
  o.grid = o.grid or {}
  o.maxIndex = (o.width * o.height) - 1

  for i = 0, o.maxIndex, 1 do
    o.grid[i] = Cell:new()
  end

  o:setNeighbours()

  return o
end

function Maze:generateRandomly(n)
  n = n or (self.width * self.height)
  local names = {'top', 'right', 'bottom', 'left'}
  for i = 0, n do
    local x = math.random(self.width - 1)
    local y = math.random(self.height - 1)
    local cell = self:getAt(x, y)
    if not cell then
      print("no cell at", x, y)
      break
    end

    local dir = names[math.random(4)]

    cell:link(cell.neighbours[dir])
  end
end

function Maze:generateBinaryTree()
  math.randomseed(os.time())
  local directions = {'top', 'right'}
  for y = self.height - 1, 0, -1 do
    for x = 0, self.width - 1 do
      local dir = 'top'
      if x < self.width - 1 then
        dir = directions[math.random(2)]
      end
      if y == 0 then
        dir = 'right'
      end
      if x == self.width - 1 and y == 0 then break end

      local cell = self:getAt(x, y)
      local dest = cell.neighbours[dir]
      cell:link(dest)
    end
  end
end

function Maze:generateSidewinder()
  math.randomseed(os.time())
  local run = {}

  for y = self.height - 1, 0, -1 do
    for x = 0, self.width - 1 do
      local cell = self:getAt(x, y)
      table.insert(run, cell)
      local goUp = math.random(2) > 1 or x == self.width - 1

      local n = cell.neighbours.right

      if goUp and y > 0 then
        cell = run[math.random(#(run))]
        n = cell.neighbours.top
        run = {}
      end

      cell:link(n)
    end
  end

end

function Maze:setNeighbours()
  for i = 0, self.maxIndex, 1 do
    local cell = self.grid[i]

    local x, y = self:toCoords(i)
    cell.x = x
    cell.y = y
    if y > 0 then
      cell.neighbours.top = self:getAt(x, y - 1)
    end
    if y < self.height - 1 then
      cell.neighbours.bottom = self:getAt(x, y + 1)
    end
    if x > 0 then
      cell.neighbours.left = self:getAt(x - 1, y)
    end
    if x < self.width - 1 then
      cell.neighbours.right = self:getAt(x + 1, y)
    end
  end
end

function Maze:getAt(x, y)
  return self.grid[self:toIndex(x, y)]
end

function Maze:toIndex(x, y)
  return (y * self.width) + x
end

function Maze:toCoords(i)
  local x = i % self.width
  local y = (i - x) / self.width
  return x, y
end

function Maze:passable(from, to)
  return false
end

Position = {
  x = 0,
  y = 0,
  maze = nil,
  moveBy = function(self, dx, dy)
    if dx == 0 and dy == 0 then return end

    local cell = self.maze:getAt(self.x, self.y)
    local dest = self.maze:getAt(self.x + dx, self.y + dy)
    if not dest then return end

    local canMove = cell:isLinked(dest)
    if not canMove then return end

    position.x = dest.x
    position.y = dest.y
  end,
}

function love.load()
  math.randomseed(os.time())
  maze = Maze:new({width=30, height=20})
  --maze:generateBinaryTree()
  maze:generateSidewinder()
  position = Position
  position.maze = maze
  love.keyboard.setKeyRepeat(true)
end

function love.update(dt)
end

function love.keypressed(key, scancode)
  if key == 'escape' then
    love.event.quit()
  end

  if key == 'a' then
    position:moveBy(-1, 0)
  end
  if key == 's' then
    position:moveBy(0, 1)
  end
  if key == 'd' then
    position:moveBy(1, 0)
  end
  if key == 'w' then
    position:moveBy(0, -1)
  end
end

function love.draw()
  local startx = 100
  local starty = 100
  local size = 20

  if canvas then
    love.graphics.setColor(255, 255, 255)
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(canvas, startx, starty)
  else
    local w, h = (maze.width * size), maze.height * size
    canvas = love.graphics.newCanvas(w, h)
    love.graphics.setCanvas(canvas)

    love.graphics.setColor(255, 255, 255, 255)
    for i = 0, (maze.width * maze.height) - 1 do
      local x, y = maze:toCoords(i)
      local cell = maze:getAt(x, y)

      local top = cell.neighbours.top
      if top and cell:isLinked(top) then
      else
        love.graphics.line(x * size, y * size, (x * size) + size, (y * size))
      end

      if cell.neighbours.right and cell:isLinked(cell.neighbours.right) then
      else
        love.graphics.line((x * size) + size, y * size, (x * size) + size, (y * size) + size)
      end

    end

    love.graphics.line(0, maze.height * size, maze.width * size, maze.height * size)
    love.graphics.line(0, 0, 0, maze.height * size)

    love.graphics.setCanvas()
  end

  love.graphics.setColor(255, 0, 0)
  love.graphics.circle('fill', startx + (position.x * size) + (size / 2), starty + (position.y * size) + (size / 2), 9)
end
