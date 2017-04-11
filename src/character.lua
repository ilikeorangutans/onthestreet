local Stat = require('stat')
local Point = require('point')
local activities = require('activities')

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

  o.position = Point:new(40, 40)

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

function Character:startActivity(name, with)
  local activity = activities[name]
  if not activity then
    print("Don't know how to do " .. name)
    return
  end

  if not activity:canDo(with) then
    print(string.format("Can't do %s with %q", name, with.title))
    return
  end

  if with and with.minDistance then
    local distance = self.position:distance(with)
    if distance > activity.minDistance then
      print(string.format("Cannot %s, too far away!", name))
      return
    end
  end
  activity:begin(with)
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

return Character
