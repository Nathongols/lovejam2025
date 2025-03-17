local main_menu = {}

local physics_test_system = {
  name = "physics", --dunno if this should be auto-generated
  schedule = "Update",
  query = { "orb", "pos", "vel" },
  cache = {},
  func = function(query, world, dt)
    if query == nil then return end
    local gravity = 9.81
    for id, entity in pairs(query) do
      entity.vel.y = entity.vel.y + gravity * dt

      entity.pos.x = entity.pos.x + entity.vel.x * dt
      entity.pos.y = entity.pos.y + entity.vel.y * dt
    end
  end
}

local function collision_event(obj1, obj2)

end

local collision_test_system = {
  name = "collision",
  schedule = "update",
  query = { "pos", "scale", "vel", "collider" },
  cache = {},
  func = function(query, world, dt)
    -- Loop through all pairs of entities in the query
    for i = 1, #query do
      local entityA = query[i]
      for j = i + 1, #query do
        local entityB = query[j]
        -- Check if one entity is a ball and the other is a bumper.
        if (entityA.collider.tag == "orb" and entityB.collider.tag == "bumper") or
            (entityA.collider.tag == "bumper" and entityB.collider.tag == "orb") then
          -- calc the distance between the centers.
          local dx = entityA.pos.x - entityB.pos.x
          local dy = entityA.pos.y - entityB.pos.y
          local distance = math.sqrt(dx * dx + dy * dy)

          -- calc radius
          local radiusA = entityA.scale.x * 0.5
          local radiusB = entityB.scale.x * 0.5

          if distance < (radiusA + radiusB) then
            local ball = entityA.collider.tag == "ball" and entityA or entityB
            local bumper = entityB.collider.tag == "bumper" and entityA or entityB


            local nx = dx / distance
            local ny = dy / distance

            local relativeVelocity = ball.vel.x * nx + ball.vel.y * ny

            if relativeVelocity > 0 then
              -- Reflect the ball's velocity around the normal vector
              local dotProduct = ball.vel.x * nx + ball.vel.y * ny
              ball.vel.x = ball.vel.x - 2 * dotProduct * nx
              ball.vel.y = ball.vel.y - 2 * dotProduct * ny

              -- Optional: Apply a restitution factor to simulate energy loss (bounce effect)
              local restitution = 0.7 -- Adjust this value between 0 (no bounce) and 1 (perfect bounce)
              ball.vel.x = ball.vel.x * restitution
              ball.vel.y = ball.vel.y * restitution

              -- Optional: Adjust ball position to prevent sticking (simple separation)
              local overlap = (radiusA + radiusB) - distance
              ball.pos.x = ball.pos.x + nx * overlap
              ball.pos.y = ball.pos.y + ny * overlap
            end
          end
        end
      end
    end
  end
}

local hello_world = {
  name = "hello", --dunno if this should be auto-generated
  schedule = "Startup",
  query = {},
  cache = {},
  func = function(query, world, dt)
    print("hello")
  end
}

local print_mouse_pos = {
  name = "print mouse pos", --dunno if this should be auto-generated
  schedule = "Update",
  query = {},
  cache = {},
  func = function(query, world, dt)
    -- print(love.graphics.getCanvas())
    print(love.mouse.getPosition())
  end
}

local shoot_ball = {
  name = "spawn ball", --dunno if this should be auto-generated
  schedule = "mouse1",
  query = {},
  cache = {},
  func = function(query, world, dt)
    local mouseX, mouseY = love.mouse.getPosition()
    local worldMouseX, worldMouseY = world:screen_to_world(mouseX, mouseY)

    local startX, startY = 0, -2

    local dx = worldMouseX - startX
    local dy = worldMouseY - startY

    local distance = math.sqrt(dx * dx + dy * dy)
    if distance == 0 then distance = 1 end -- Prevent division by zero
    local unitX = dx / distance
    local unitY = dy / distance

    local speed = 5
    local velX = unitX * speed
    local velY = unitY * speed

    world:add_entity({
      orb = {},
      pos = { x = startX, y = startY },
      vel = { x = velX, y = velY },
      scale = { x = 0.2, y = 0.2 },
      drawable = { sprite = love.graphics.newImage("assets/ball.png") },
      collider = { tag = "orb" },
    })
  end
}

local draw_trajectory = {
  name = "draw trajectory",
  schedule = "draw",
  query = {},
  cache = {},
  func = function(query, world, dt)
    local mouseX, mouseY = love.mouse.getPosition()

    local worldMouseX, worldMouseY = world:screen_to_world(mouseX, mouseY)

    local startX, startY = 0, -2

    local dx = worldMouseX - startX
    local dy = worldMouseY - startY

    local distance = math.sqrt(dx * dx + dy * dy)
    if distance == 0 then distance = 1 end -- Prevent division by zero
    local unitX = dx / distance
    local unitY = dy / distance

    local speed = 5
    local velocityX = unitX * speed
    local velocityY = unitY * speed


    -- Calculate predicted trajectory points over a given time period
    local gravity = 9.81
    local points = {}
    local timeStep = 0.1 -- time interval between points
    local maxTime = 2    -- how far into the future to predict (in seconds)
    for t = 0, maxTime, timeStep do
      local x = startX + velocityX * t
      local y = startY + velocityY * t + 0.5 * gravity * t * t
      table.insert(points, { x = x, y = y })
    end

    local scale = 0.01
    love.graphics.setLineWidth(scale)
    love.graphics.setLineStyle("smooth")
    -- Draw the trajectory as a series of connected line segments
    love.graphics.setColor(1, 0, 0, 1) -- red color for the trajectory
    for i = 1, #points - 1 do
      local p1 = points[i]
      local p2 = points[i + 1]
      love.graphics.line(p1.x, p1.y, p2.x, p2.y)
    end

    -- Optionally, reset the drawing color
    love.graphics.setColor(1, 1, 1, 1)
  end
}

local function setup_grid(world)
  for i = 1, 5 do
    for j = 1, 5 do
      if math.fmod(j, 2) == 1 then
        world:add_entity({
          bumper = {},
          pos = { x = i - 3, y = j * 0.5 },
          scale = { x = 0.2, y = 0.2 },
          vel = { x = 0, y = 0 },
          drawable = { sprite = love.graphics.newImage("assets/bumper.png") },
          collider = { tag = "bumper" },
        })
      else
        world:add_entity({
          bumper = {},
          pos = { x = i - 3.5, y = j * 0.5 },
          scale = { x = 0.4, y = 0.4 },
          vel = { x = 0, y = 0 },
          drawable = { sprite = love.graphics.newImage("assets/bumper.png") },
          collider = { tag = "bumper" },
        })
      end
    end
  end
end

--main_menu handles some crucial component initialization since it's loaded first
function main_menu.load(world)
  world:register_component("pos", { x = 0, y = 0 })
  world:register_component("vel", { x = 0, y = 0 })
  world:register_component("scale", { x = 0, y = 0 })
  world:register_component("drawable", { sprite = love.graphics.newImage("assets/jinjo.png") })
  world:register_component("collider", { tag = "value" })
  world:register_component("orb", {})
  world:register_component("bumper", {})

  -- world:register_system(print_mouse_pos)
  world:register_system(physics_test_system)
  world:register_system(collision_test_system)
  world:register_system(draw_trajectory)
  world:register_system(shoot_ball)

  setup_grid(world)

  local menu_canvas = love.graphics.newCanvas()

  print("scene loaded: main_menu")
end

return main_menu
