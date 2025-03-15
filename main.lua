Utils = require('utils')
Inspect = require('inspect')
local world = require('world')

local physics_test_system = {
  name = "physics", --dunno if this should be auto-generated
  schedule = "Update",
  query = {"pos", "vel"},
  cache = {},
  func = function(query, dt)
    if query == nil then return end
    for id, entity in ipairs(query) do
      entity.pos.x = entity.pos.x + entity.vel.x * dt
      entity.pos.y = entity.pos.y + entity.vel.y * dt
    end
  end
}



function love.load()
  world:register_component("transform", { x = 0, y = 0 })
  world:register_component("pos", { x = 0, y = 0 })
  world:register_component("vel", { x = 0, y = 0 })

  for i = 1, 10 do 
    world:add_entity(
      { transform = { x = 3, y = 1 }, 
        pos = { x = 100, y = 100 },
        vel = { x = 3, y = 1 }
      })
  end

  world:register_system(physics_test_system)

  world:start()
end

function love.update(dt)
  world:update(dt)
end

function love.draw()
  world:draw()
  love.graphics.print("current FPS: "..tostring(love.timer.getFPS()), 10, 10)
end
