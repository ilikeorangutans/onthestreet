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
  search = {
    title = 'search',
    modifiers = {
      energy = -0.05,
    },
    begin = function(activity)
      print("You begin searching")
      activity.time = 0
    end,
    engage = function(activity, character, dt)
      activity.time = activity.time + dt

      if activity.time > 5 then
        if math.random() > 0.5 then
          local item = {}
          if math.random() > 0.5 then
            item = {
              title = "half eaten sandwich",
              edible = true,
              nutrition = 15 + math.random(60)
            }
            print("You found some food: " .. item.title)
          else
            item = {
              title = "old newspaper",
              edible = false
            }
            print("You found: " .. item.title)
          end
          -- TODO need an object to search, should product food items of different qualities
          character.inventory:add(item)
        else
          print("You find nothing...")
        end
        return true
      end

      return false
    end,
  },
  eat = {
    title = 'eat',
    modifiers = {
    },
    begin = function(activity, object)
      print("You eat the " .. object.title)
      activity.item = object
      activity.time = 0
    end,
    engage = function(activity, character, dt)
      activity.time = activity.time + dt
      if activity.time > 5 then
        character.stats['nutrition']:add(activity.item.nutrition)
        return true
      end
      return false
    end,
  }
}

return activities
