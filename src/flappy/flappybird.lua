local FlappyGame = {}

function FlappyGame:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.speed = o.speed or 1
  o.gravity = o.gravity or 12
  o.maxVelocity = o.maxVelocity or 300
  o.jumpAmount = o.jumpAmount or 250
  o.miny = o.miny or 0
  o.maxy = o.maxy or 400
  o.playerx = o.playerx or 100
  o.playery = o.playery or (o.maxy - o.miny) / 2
  o.playersize = o.playersize or 16

  o.minGapWidth = o.minGapWidth or o.maxy * 0.2
  o.maxGapWidth = o.maxGapWidth or o.maxy * 0.8
  o.minObstacleWidth = o.minObstacleWidth or 20
  o.maxObstacleWidth = o.maxObstacleWidth or 50
  o.minTimeBetweenObstacles = o.minTimeBetweenObstacles or 2

  o.onGameOver = o.onGameOver or function(passed)
    print("Game over! Score: " .. passed)
  end

  o.obstacles = {}

  o:restart()

  return o
end

function FlappyGame:update(dt)
  if self.running then
    self:updatePlayer(dt)
    self:updateObstacles(dt)
  end
end

function FlappyGame:updateObstacles(dt)

  self:moveObstacles(dt)

  if self.obstacleCountdown > self.minTimeBetweenObstacles then
    self.obstacleCountdown = 0
    local obstacle = self:newObstacle()
    table.insert(self.obstacles, obstacle)
  end
  self.obstacleCountdown = self.obstacleCountdown + (dt * self.speed)
end

function FlappyGame:moveObstacles(dt)
  local remove = {}
  for i, obstacle in ipairs(self.obstacles) do
    obstacle.x = obstacle.x - (dt * 100 * self.speed)
    if obstacle.x + obstacle.w < self.playerx and not obstacle.passed then
      obstacle.passed = true
      self.passed = self.passed + 1
    end

    if self:checkCollision(obstacle) then
      self:endGame()
    end

    if obstacle.x < -obstacle.w then
      table.insert(remove, i)
    end
  end

  for _, index in ipairs(remove) do
    table.remove(self.obstacles, index)
  end
end

function FlappyGame:checkCollision(obstacle)
  local overObstacle = obstacle.x <= self.playerx + self.playersize and self.playerx - self.playersize <= obstacle.x + obstacle.w
  return overObstacle and (self.playery - self.playersize < obstacle.top or self.playery + self.playersize > obstacle.top + obstacle.gap )
end

function FlappyGame:newObstacle()
  local w, h = love.window.getMode()
  local minimumHeight = h * 0.1

  local width = math.max(self.minObstacleWidth, math.random(self.maxObstacleWidth))
  local top = math.max(minimumHeight, math.random(h * 0.5))
  local gap = math.max(math.random(self.maxGapWidth), self.minGapWidth)
  local obstacle = {
    x = w,
    w = width,
    top = top,
    gap = gap,
    bottom = h - top - gap,
    passed = false
  }

  return obstacle
end

function FlappyGame:updatePlayer(dt)
  local deltay = dt * self.velocity
  self.playery = self.playery + deltay

  if self.playery < self.miny or self.playery > self.maxy then
    self:endGame()
  end

  self.velocity = self.velocity + self.gravity
  if self.velocity > self.maxVelocity then self.velocity = self.maxVelocity end
end

function FlappyGame:restart()
  self.running = false
  self.over = false
  self.playery = (self.maxy - self.miny) / 2
  self.velocity = 0
  self.passed = 0
  self.obstacles = {}
  self.obstacleCountdown = self.minTimeBetweenObstacles
end

function FlappyGame:jump()
  if not self.running then self.running = true end
  self.velocity = self.velocity - self.jumpAmount
end

function FlappyGame:endGame()
  self.running = false
  self.over = true
  self.onGameOver(self.passed)
end

return FlappyGame
