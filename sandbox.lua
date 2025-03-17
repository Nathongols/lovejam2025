--sandbox scene for plinko testing
local sandbox = {}


local ball_physics = {
  name = "physics", --dunno if this should be auto-generated
  schedule = "Update",
  query = {"orb", "pos", "vel"},
  cache = {},
  func = function(query, world, dt)
    local GRAVITY = -0.98
    if query == nil then return end
    for id, entity in ipairs(query) do
      entity.vel.y = entity.vel.y - GRAVITY
      entity.pos.x = entity.pos.x + entity.vel.x * dt
      entity.pos.y = entity.pos.y + entity.vel.y * dt
    end
  end
}

local shoot_ball = {
  name = "physics", --dunno if this should be auto-generated
  schedule = "mouse1",
  query = {},
  cache = {},
  func = function(query, world, dt)
  end
}

function sandbox.load(world) 
  world:register_component("pos", { x = 0, y = 0 })
  world:register_component("vel", { x = 0, y = 0 })
  world:register_component("scale", { x = 0, y = 0 })
  world:register_component("drawable", {sprite = love.graphics.newImage("assets/jinjo.png")})

end
