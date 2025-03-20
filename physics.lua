
local physics_system = {
  name = "physics", --dunno if this should be auto-generated
  schedule = "Update",
  query = { "orb", "pos", "vel" },
  cache = {},
  func = function(query, world, dt)
    if query == nil then return end
    local gravity = 18.81
    for id, entity in pairs(query) do
      entity.vel.y = entity.vel.y + gravity * dt

      entity.pos.x = entity.pos.x + entity.vel.x * dt
      entity.pos.y = entity.pos.y + entity.vel.y * dt


    if entity.pos.x < -40 or entity.pos.x > 40 or entity.pos.y < -40 or entity.pos.y > 40 then
      world:remove_entity(id)
    end

    end
  end
}

return physics_system
