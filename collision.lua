local function bumper_collision_event(world, ball, bumper)
  local state = world.resources["game_state"]
  if state == "p1_fire" then
    world.resources["p1_score"] = world.resources["p1_score"] + 10
  elseif state == "p2_fire" then
    world.resources["p2_score"] = world.resources["p2_score"] + 10
  end
end

local collision_system = {
  name = "collision",
  schedule = "update",
  query = { "pos", "scale", "vel", "collider" },
  cache = {},
  func = function(query, world, dt)
    -- Loop through all pairs of entities in the query
    if query == nil then return end
    for id, _ in pairs(query) do
      local entityA = query[id]
      for id_2, _ in pairs(query) do
        local entityB = query[id_2]
        -- if entityB == nil then return end
        --sphere collision
        if (entityA.collider.tag == "orb" and entityB.collider.tag == "bumper") or
            (entityA.collider.tag == "bumper" and entityB.collider.tag == "orb") then
          -- calc the distance between the centers.
          local ball = entityA.collider.tag == "ball" and entityA or entityB
          local bumper = entityB.collider.tag == "bumper" and entityA or entityB

          local dx = entityA.pos.x - entityB.pos.x
          local dy = entityA.pos.y - entityB.pos.y
          local distance = math.sqrt(dx * dx + dy * dy)

          -- calc radius
          local radiusA = entityA.scale.x * 0.5
          local radiusB = entityB.scale.x * 0.5

          if distance < (radiusA + radiusB) then
            if not ball.collider.is_colliding then
              ball.collider.is_colliding = true
              bumper_collision_event(world, ball, bumper)
            end

            local nx = dx / distance
            local ny = dy / distance

            local relativeVelocity = ball.vel.x * nx + ball.vel.y * ny

            if relativeVelocity > 0 then
              -- Reflect the ball's velocity around the normal vector
              local dotProduct = ball.vel.x * nx + ball.vel.y * ny
              ball.vel.x = ball.vel.x - 2 * dotProduct * nx
              ball.vel.y = ball.vel.y - 2 * dotProduct * ny

              --Bouciness
              local restitution = 0.85
              ball.vel.x = ball.vel.x * restitution
              ball.vel.y = ball.vel.y * restitution

              --Push object out of bumper
              local overlap = (radiusA + radiusB) - distance
              ball.pos.x = ball.pos.x + nx * overlap
              ball.pos.y = ball.pos.y + ny * overlap

              --Force minimum bounce amount
              local speed = math.sqrt(ball.vel.x ^ 2 + ball.vel.y ^ 2)
              local minSpeed = 1

              if speed < minSpeed then
                if speed > 0 then
                  ball.vel.x = (ball.vel.x / speed) * minSpeed
                  ball.vel.y = (ball.vel.y / speed) * minSpeed
                else
                  -- If speed is zero, push the ball in the collision normal direction
                  ball.vel.x = nx * minSpeed
                  ball.vel.y = ny * minSpeed
                end
              end

              --Slight random trajectory
              local max_angle = math.rad(5)
              local ran_offset = (math.random() - 0.5) * 2 * max_angle

              local cur_angle = math.acos(ball.vel.x / speed)
              if ball.vel.y < 0 then
                cur_angle = -cur_angle
              end

              local new_angle = cur_angle + ran_offset

              ball.vel.x = speed * math.cos(new_angle)
              ball.vel.y = speed * math.sin(new_angle)
            end
          else
            ball.collider.is_colliding = false
          end
        end
        if (entityA.collider.tag == "orb" and entityB.collider.tag == "wall") or
            (entityA.collider.tag == "wall" and entityB.collider.tag == "orb") then
          local orb, wall
          if entityA.collider.tag == "orb" then
            orb = entityA
            wall = entityB
          else
            orb = entityB
            wall = entityA
          end

          local cx, cy = orb.pos.x, orb.pos.y
          local radius = orb.scale.x * 0.5

          local rx, ry = wall.pos.x, wall.pos.y
          local half_width = wall.scale.x * 0.5
          local half_height = wall.scale.y * 0.5

          local closest_x = math.max(rx - half_width, math.min(cx, rx + half_width))
          local closest_y = math.max(ry - half_height, math.min(cy, ry + half_height))

          local dx = cx - closest_x
          local dy = cy - closest_y
          local distance = math.sqrt(dx * dx + dy * dy)

          if distance < radius then
            local nx, ny
            if distance == 0 then
              --orb hits corner edge case
              nx, ny = 0, -1
            else
              nx = dx / distance
              ny = dy / distance
            end
            local depth = radius - distance

            orb.pos.x = orb.pos.x + nx * depth
            orb.pos.y = orb.pos.y + ny * depth

            local relative_velocity = orb.vel.x * nx + orb.vel.y * ny
            if relative_velocity < 0 then
              --reflect
              orb.vel.x = orb.vel.x - 2 * relative_velocity * nx
              orb.vel.y = orb.vel.y - 2 * relative_velocity * ny

              -- restitusion
              local restitution = 0.85
              orb.vel.x = orb.vel.x * restitution
              orb.vel.y = orb.vel.y * restitution
            end
          end
        end
      end
    end
  end
}

return collision_system
