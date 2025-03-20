local physics = require('physics')
local collision = require('collision')

local game_manager = {
  name = "game manager",
  schedule = "update",
  query = {},
  cache = {},
  func = function(query, world, dt)
    local state = world.resources["game_state"]
    if state == "game_start" then
      world.resources["game_state"] = "p1_fire"
      world:register_system(physics)
      world:register_system(collision)
    elseif state == "p1_fire" then
      --exit condition
      if world.resources["p1_ammo"] == 0 then
        world.resources["p2_ammo"] = 3
        world.resources["game_state"] = "p2_fire"
      end
    elseif state == "p2_fire" then
      --exit condition
      if world.resources["p2_ammo"] == 0 then
        world.resources["p1_ammo"] = 3
        -- world.Update["physics"] = nil
        world.Update["collision"] = nil
        world.Mouse1["spawn ball"] = nil
        world.Draw["draw trajectory"] = nil
        world.resources["game_state"] = "p1_place"
      end
    elseif state == "p1_place" then

    elseif state == "p2_place" then
    end
  end
}

return game_manager
