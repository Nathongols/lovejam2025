local main_menu = {}

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

local hello_world = {
  name = "hello", --dunno if this should be auto-generated
  schedule = "Startup",
  query = {},
  cache = {},
  func = function(query, dt)
    print("hello")
  end
}

local print_mouse_pos = {
  name = "print mouse pos", --dunno if this should be auto-generated
  schedule = "Update",
  query = {},
  cache = {},
  func = function(query, dt)
    -- print(love.graphics.getCanvas())
    print(love.mouse.getPosition())
  end
}

--main_menu handles some crucial component initialization since it's loaded first
function main_menu.load(world)
  world:register_component("pos", { x = 0, y = 0 })
  world:register_component("vel", { x = 0, y = 0 })
  world:register_component("scale", { x = 0, y = 0 })
  world:register_component("drawable", {sprite = love.graphics.newImage("assets/jinjo.png")})

  -- world:register_system(print_mouse_pos)
  world:register_system(physics_test_system)

  world:add_entity({
    pos = {x = 0, y = 0},
    vel = {x = 10, y = 0},
    scale = {x = 0.1, y = 0.1},
    drawable = {sprite = love.graphics.newImage("assets/jinjo.png")
  }})

  local menu_canvas = love.graphics.newCanvas()

  print("scene loaded: main_menu")
end

return main_menu
