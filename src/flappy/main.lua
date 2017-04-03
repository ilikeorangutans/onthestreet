local FlappyGame = require('flappygame')

local game = nil

function love.load()
  math.randomseed(os.time())
  local w, h = love.window.getMode()
  game = FlappyGame:new({maxy = h - 20, miny = 20, minTimeBetweenObstacles = 3, minGapWidth = 200, speed = 3, minObstacleWidth=50, maxObstacleWidth = 200})
end

function love.update(dt)
  game:update(dt)
end

function love.draw()
  for _, obstacle in ipairs(game.obstacles) do
    love.graphics.setColor(80, 255, 80)
    love.graphics.rectangle('fill', obstacle.x, 0, obstacle.w, obstacle.top)
    love.graphics.rectangle('fill', obstacle.x, obstacle.top + obstacle.gap, obstacle.w, obstacle.bottom)
  end

  love.graphics.setColor(255, 0, 0)
  love.graphics.print("Points: " .. game.passed, 3, 3)

  local w, h = love.window.getMode()

  local cx, cy = game.playerx, game.playery

  love.graphics.setColor(255, 255, 255)
  love.graphics.circle('fill', cx, cy, game.playersize)

  love.graphics.setColor(255, 0, 0)
  love.graphics.line(0, game.maxy, w, game.maxy)
  love.graphics.line(0, game.miny, w, game.miny)
end

function love.keyreleased(key, scancode)
  if key == 'r' and game.over then
    game:restart()
  end
  if key == 'space' and not game.over then
    game:jump()
  end
  if key == 'p' and not game.over then
    game.running = not game.running
  end
end
