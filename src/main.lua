local Point = require('point')
local Time = require('time')
local Stat = require('stat')
local Character = require('character')
local Street = require('street')
local StreetView = require('street_view')

local character = Character:new()
local time = Time:new()
local timeModifier = 1

local street = nil
local streetView = nil
local highlighted = nil

local lastTimestamp = 0

mousepos = {x=0,y=0}

function love.load()
  math.randomseed(os.time())
  lastTimestamp = time:timestamp()
  love.keyboard.setKeyRepeat(true)
  local w, h = love.window.getMode()

  street = Street:new()
  streetView = StreetView:new({street=street, w=w - 20, h=h - 120, screenx=10, screeny=20})
  streetView:center({x=0, y=0})
end

function love.resize(w, h)
end

function love.draw()
  streetView:draw()

  local w, h = love.window.getMode()
  local x = (w / 2) - 30
  local y = h - 200
  love.graphics.setColor(255, 255, 255)
  local screenCoords = streetView:toScreen(character.position)
  love.graphics.rectangle('fill', screenCoords.x, screenCoords.y, 60, 100)

  local pos = character.position
  love.graphics.print(string.format("Position: %d/%d", pos.x, pos.y ), 10, h - 60)
  local coords = streetView:toWorld(mousepos)
  love.graphics.print(("Mouse: %d/%d, game world: %d/%d"):format(mousepos.x, mousepos.y, coords.x, coords.y), 10, h - 40)
  love.graphics.print(("World: %d/%d"):format(streetView.x, streetView.y), 10, h - 20)

  local state = character:state()
  local status = "[" .. timeModifier .. "] " .. time:date() .. " " .. time:time() .. " " .. state.title .. ": " .. character:activity().title .. ", energy: " .. character.stats['energy'].value .. ", nutrition: " .. character.stats['nutrition'].value
  status = string.format("[%d] %s %s %s: %s, energy: %6.2f, nutrition: %6.2f", timeModifier, time:date(), time:time(), state.title, character:activity().title, character.stats['energy'].value, character.stats['nutrition'].value)
  love.graphics.print(status, 10, 3)
end

function love.keypressed(key, scancode, isrepeat)
end

function move(dx, dy)
  character.position.x = character.position.x + dx
  character.position.y = character.position.y + dy
  local newPos = street:moveTo(character.position)

  character.position:update(newPos)
  streetView:center(character.position)

  local coords = streetView:toWorld({x=mousepos.x, y=mousepos.y})
  checkHover(coords.x, coords.y)
end

function love.keyreleased(key, scancode)
  if key == 'escape' then
    love.event.quit()
  end
  if key == 'y' then
    character:sleep()
  end
  if key == 'q' then
    if highlighted then
      character:startActivity('search', highlighted)
    else
      print("Nothing to search")
    end
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

function love.mousemoved(x, y)
  local coords = streetView:toWorld({x=x, y=y})
  checkHover(coords.x, coords.y)
  mousepos.x = x
  mousepos.y = y
end

function checkHover(x, y)
  local hover = nil
  for _, item in ipairs(street.interactables) do
    --print("Checking highlight: " .. item.x .. "/" .. item.y .. " mouse " .. coords.x .. "/" .. coords.y)
    if item.x < x and x <= item.x + item.w + 1 and item.y < y and y <= item.y + item.h + 1 then
      item.highlight = true
      hover = item
    else
      item.highlight = false
    end
  end

  highlighted = hover
end

function love.mousereleased(x, y, button, istouch)
  local coords = streetView:toWorld({x=x, y=y})

  for _, item in ipairs(street.interactables) do
    if item.x < coords.x and coords.x < item.x + item.w and item.y < coords.y and coords.y < item.y + item.h then

      if button == 1 then
        print("BLARGH")
      end
    end
  end
end

function love.update(dt)

  local amount = 5
  if love.keyboard.isDown('a') then
    move(-amount, 0)
  end
  if love.keyboard.isDown('s') then
    move(0, amount)
  end
  if love.keyboard.isDown('d') then
    move(amount, 0)
  end
  if love.keyboard.isDown('w') then
    move(0, -amount)
  end

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

    if countdown >= 2 then
      print("--< [x" .. timeModifier .. "] " .. time:date() .. " " .. time:time() .. " " .. state.title .. ": " .. character:activity().title .. ", energy: " .. character.stats['energy'].value .. ", nutrition: " .. character.stats['nutrition'].value .. " >--------------")
      countdown = 0
    end
    countdown = countdown + dt
  end
end


