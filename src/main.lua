local ui = require('love2dboxes')
local Time = require('time')
local Stat = require('stat')

local activities = {
  idle = {
    title = 'idle',
    modifiers = {
      -- boredom?
    },
    begin = function(activity)
      print("You're loitering idly")
    end,
    engage = function(activity, character, dt)
      return false
    end,
  },
  scavenge_for_food = {
    title = 'scavenging for food',
    modifiers = {
      energy = -0.05,
    },
    begin = function(activity)
      print("You begin searching for food")
      activity.time = 0
    end,
    engage = function(activity, character, dt)
      activity.time = activity.time + dt

      if activity.time > 5 then
        if math.random() > 0.5 then
          local item = {
            title = "half eaten sandwich",
            edible = true
          }
          print("You found some food: " .. item.title)
          -- TODO need an object to search, should product food items of different qualities
          character.inventory:add(item)
        else
          print("You find nothing edible...")
        end
        return true
      end

      return false
    end,
  },
}
local Character = {}

function Character:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.inventory = {
    add = function(inventory, item)
      print("You now have " .. item.title)
      table.insert(inventory, item)
    end
  }

  o.stats = {}
  local energy = Stat:new({title = "Energy"})
  o.stats['energy'] = energy
  local nutrition = Stat:new({title = "Nutrition"})
  o.stats['nutrition'] = nutrition

  o.transitions = {
    dead = function(character)
      local nutrition = character.stats['nutrition']
      if nutrition.value <= 0 then
        return true
      end
    end
  }

  o.states = {
    dead = {
      timestep = 0,
      title = 'dead',
      begin = function(character)
        print("You die")
      end,
      update = function(dt)
      end,
      modifiers = {
      },
      transitions = {
      }
    },
    awake = {
      timestep = 0.1,
      title = 'awake',
      update = function(dt)
      end,
      begin = function(character)
        print("You wake up")
      end,
      modifiers = {
        energy = -0.13,
        --nutrition = -0.013,
        nutrition = -0.13,
      },
      transitions = {
        asleep = function(character)
          local energy = character.stats['energy']
          if energy.value < 20 then
            return true
          end
        end
      }
    },
    asleep = {
      timestep = 2,
      title = 'asleep',
      update = function(dt)
      end,
      begin = function(character)
        character:startActivity('idle')
        print("You fall asleep")
      end,
      modifiers = {
        energy = 0.14,
        nutrition = -0.010,
      },
      transitions = {
        awake = function(character)
          local energy = character.stats['energy']
          if energy.value >= 100 then
            return true
          end
        end
      }
    },
  }

  o:switchState('awake')
  o:startActivity('idle')

  return o
end

function Character:startActivity(name, object)
  local activity = activities[name]
  if not activity then
    print("Don't know how to do " .. name)
    return
  end

  activity:begin(object)
  self.currentActivity = activity
end

function Character:activity()
  return self.currentActivity
end

function Character:switchState(state)
  self.current_state = self.states[state]
  self.current_state.begin(self)
end

function Character:sleep()
  self:switchState('asleep')
end

function Character:wake()
  self:switchState('awake')
end

function Character:die()
  self:switchState('dead')
end

function Character:state()
  return self.current_state
end

function Character:update(dt)
  local state = self:state()
  for name, modifier in pairs(state.modifiers) do
    local stat = self.stats[name]
    stat:update(dt, modifier)
  end

  local activity = self:activity()
  for name, modifier in pairs(activity.modifiers) do
    local stat = self.stats[name]
    stat:update(dt, modifier)
  end

  if activity:engage(self, dt) then
    self:startActivity('idle')
  end

  for name, trigger in pairs(self.transitions) do
    if trigger(self) then
      self:switchState(name)
      return
    end
  end

  for name, trigger in pairs(state.transitions) do
    if trigger(self) then
      self:switchState(name)
      return
    end
  end
end

local character = Character:new()
local time = Time:new()
local timeModifier = 1

local lastTimestamp = 0
function love.load()
  math.randomseed(os.time())
  lastTimestamp = time:timestamp()
end

function love.draw()
end

function love.keyreleased(key, scancode)
  if key == 's' then
    character:sleep()
  end
  if key == 'd' then
    character:die()
  end
  if key == 'f' then
    character:startActivity('scavenge_for_food') -- TODO add second parameter to add an object related to the activity?
  end
  if key == 'e' then
    local _, item = next(character.inventory)
    print(item)
    if not item then
      print("Got nothing to eat")
    end
    if not item.edible then
      print("It's not edible")
    else
      character:startActivity('eat', item)
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

