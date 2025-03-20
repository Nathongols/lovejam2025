local main_menu = {}

local shoot_ball = {
  name = "spawn ball", --dunno if this should be auto-generated
  schedule = "mouse1",
  query = {},
  cache = {},
  func = function(query, world, dt)
    if world.resources["p1_ammo"] > 0 or world.resources["p2_ammo"] then
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
        collider = { tag = "orb", is_colliding = false },
      })

      if world.resources["game_state"] == "p1_fire" then
        world.resources["p1_ammo"] = world.resources["p1_ammo"] - 1
      elseif world.resources["game_state"] == "p2_fire" then
        world.resources["p2_ammo"] = world.resources["p2_ammo"] - 1
      end
    end
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
    local gravity = 18.81
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
          collider = { tag = "bumper", is_colliding = false },
        })
      else
        world:add_entity({
          bumper = {},
          pos = { x = i - 3.5, y = j * 0.5 },
          scale = { x = 0.4, y = 0.4 },
          vel = { x = 0, y = 0 },
          drawable = { sprite = love.graphics.newImage("assets/bumper.png") },
          collider = { tag = "bumper", is_colliding = false },
        })
      end
    end
  end
end

local function setup_walls(world)
  world:add_entity({
    wall = {},
    pos = { x = -4, y = 0},
    scale = { x = 0.125, y = 20},
    vel = { x = 0, y = 0 },
    drawable = { sprite = "rect"},
    collider = { tag = "wall", is_colliding = false },
  })
  world:add_entity({
    wall = {},
    pos = { x = 4, y = 0},
    scale = { x = 0.125, y = 20},
    vel = { x = 0, y = 0 },
    drawable = { sprite = "rect"},
    collider = { tag = "wall", is_colliding = false },
  })
end

--main_menu handles some crucial component initialization since it's loaded first
function main_menu.load(world)
  world:register_component("pos", { x = 0, y = 0 })
  world:register_component("vel", { x = 0, y = 0 })
  world:register_component("scale", { x = 0, y = 0 })
  world:register_component("drawable", { sprite = love.graphics.newImage("assets/jinjo.png") })
  world:register_component("collider", { tag = "value", is_colliding = false })
  world:register_component("orb", {})
  world:register_component("bumper", {})
  world:register_component("wall", {})

  -- world:register_system(print_mouse_pos)
  world:register_system(require('game_manager'))
  world:register_system(draw_trajectory)
  world:register_system(shoot_ball)

  world:add_resource("p1_score", 0)
  world:add_resource("p2_score", 0)
  world:add_resource("p1_ammo", 3)
  world:add_resource("p2_ammo", 3)
  world:add_resource("game_state", "game_start")

  setup_grid(world)
  setup_walls(world)

  local menu_canvas = love.graphics.newCanvas()

  print("scene loaded: main_menu")
end

return main_menu
