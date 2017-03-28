local ui = require('love2dboxes')
local Time = require('time')
local Stat = require('stat')
local Character = require('character')

local character = Character:new()
local time = Time:new()
local timeModifier = 1

local lastTimestamp = 0
function love.load()
  math.randomseed(os.time())
  lastTimestamp = time:timestamp()
  love.keyboard.setKeyRepeat(true)
  local w, h = love.window.getMode()
end

function love.resize(w, h)
end

function love.draw()
  local w, h = love.window.getMode()
  local x = (w / 2) - 30
  local y = h - 200
  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle('fill', x, y, 60, 100)
end

function love.keypressed(key, scancode, isrepeat)
  if key == 'a' then
  end
  if key == 's' then
  end
  if key == 'd' then
  end
  if key == 'w' then
  end
end

function love.keyreleased(key, scancode)
  if key == 'escape' then
    love.event.quit()
  end
  if key == 'y' then
    character:sleep()
  end
  if key == 'q' then
    character:startActivity('search') -- TODO add second parameter to add an object related to the activity?
  end
  if key == 'e' then
    local index = nil
    for i, x in ipairs(character.inventory) do
      if x.edible then
        index = i
        break
      end
    end
    local item = nil
    if index then
      item = table.remove(character.inventory, index)
    end
    if not item then
      print("Got nothing to eat")
    else
      if not item.edible then
        print("It's not edible")
        character.inventory:add(item)
      else
        character:startActivity('eat', item)
      end
    end
  end
  if key == '=' then
    timeModifier = timeModifier + 0.5
  end
  if key == '-' then
    timeModifier = timeModifier - 0.5
  end
  if key == '0' then
    timeModifier = 1
  end
end

local countdown = 0
local gameGoing = true

function love.update(dt)
  if gameGoing then
    local state = character:state()
    local timeStep = state.timestep * timeModifier

    time:advance(timeStep)
    local timestamp = time:timestamp()
    local simulatedTime = timestamp - lastTimestamp
    lastTimestamp = timestamp

    character:update(simulatedTime)

    if state.title == 'dead' then
      gameGoing = false
    end

    if countdown >= 1 then
      print("--< [x" .. timeModifier .. "] " .. time:date() .. " " .. time:time() .. " " .. state.title .. ": " .. character:activity().title .. ", energy: " .. character.stats['energy'].value .. ", nutrition: " .. character.stats['nutrition'].value .. " >--------------")
      countdown = 0
    end
    countdown = countdown + dt
  end

end

