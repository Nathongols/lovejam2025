--World stores all game components and entities
--then we define systems that run on those components and entities
--world provides a query api that let's us access components from entities

local world = {
  running = false, --run update loop?
  cur_id = 0,
  dirty = false,   --if world has been modified, then we need to reset queries
  entities = {},   --list of all active entities in the game world
  components = {}, --list of possible components that can be added to entities
  resources = {},  --global variables
  Startup = {},    --holds all Startup systems
  Update = {},     --holds all Update systems
  Draw = {},
  Mouse1 = {},     --holds all systems that run on mouse1 click
  Mouse2 = {}      --holds all systems that run on mouse2 click
}

--generates an id when inserting a new entity
--Naive implementation for now
local function generate_id(_world)
  _world.cur_id = _world.cur_id + 1
  return _world.cur_id
end

function world:add_resource(name, resource)
  if resource == nil then
    print("add_resource ERROR: empty arguments")
    return false
  end
  self.resources[name] = resource
  return true
end

--args is a list of components to add to the object
--components are lookedup from it's registered components list
function world:add_entity(components)
  if next(components) == nil then
    print("add_entity ERROR: empty arguments")
    return false
  end
  local id = generate_id(self)
  if id == nil then
    print("add_entity ERROR: Could not generate id")
    return false
  end

  local temp_components = {}

  for name, attribute in pairs(components) do
    if self.components[name] ~= nil then
      if type(attribute) == "table" then
        if Utils.has_same_keys(attribute, self.components[name]) then
          temp_components[name] = attribute
        else
          print("add_entity ERROR: Inserted component does not match world's registered component")
          return false
        end
      end
    else
      print("add_entity ERROR: Could not find component " .. name .. ", did you register it?")
      return false
    end
  end

  self.entities[id] = temp_components
  self.dirty = true --flag for system requery
  return true
end

function world:remove_entity(id)
  self.entities[id] = nil
  self.dirty = true
  return true
end

--returns an entity/entities based on the inputed components
--naive implementation
--TODO: In the future there is numerous benefits to attempting multi-threading
--data isolation and cache is needed for that in the future
function world:query(query)
  if type(query) == "number" then
    return self.entities[query] or {}
  elseif type(query) == "table" then
    local result = {}
    for id, components in pairs(self.entities) do
      local match = true
      local filtered = {}
      -- Check for each requested component
      for _, compName in pairs(query) do
        if components[compName] then
          filtered[compName] = components[compName]
        else
          match = false
          break
        end
      end
      if match then
        result[id] = filtered
      end
    end
    return result
  end
  return {}
end

--registers a table as a component
--returns true if successful, false if not
function world:register_component(component_name, component_array)
  --For object tags
  if component_array == nil then
    self.components[component_name] = component_name
    print("register_component REGISTERED: " .. component_name)
    return true
  else
    for _, attribute in pairs(component_array) do
      if type(attribute) == "function" then
        print("ERROR: register_component " .. component_name .. " cannot include a function")
        return false
      end
      if type(attribute) == "table" then
        print("ERROR: in register_component, " .. component_name .. " cannot include a table")
        return false
      end
    end

    self.components[component_name] = component_array
    print("register_component REGISTERED: " .. component_name)
    return true
  end
end

--adds the system to the desired schedule
function world:register_system(system)
  if string.lower(system.schedule) == "startup" then
    self.Startup[system.name] = { query = system.query, func = system.func }
    print("register_system REGISTERED: startup, " .. system.name)
  elseif string.lower(system.schedule) == "update" then
    self.Update[system.name] = { query = system.query, func = system.func }
    print("register_system REGISTERED:  update, " .. system.name)
  elseif string.lower(system.schedule) == "draw" then
    self.Draw[system.name] = { query = system.query, func = system.func }
    print("register_system REGISTERED:  draw, " .. system.name)
  elseif string.lower(system.schedule) == "mouse1" then
    self.Mouse1[system.name] = { query = system.query, func = system.func }
    print("register_system REGISTERED:  mouse1, " .. system.name)
  elseif string.lower(system.schedule) == "mouse2" then
    self.Mouse1[system.name] = { query = system.query, func = system.func }
    print("register_system REGISTERED:  mouse2, " .. system.name)
  end
  return true
end

--Runs all startup functions
function world:start()
  for _, system in pairs(self.Startup) do
    system.func(world:query(system.query))
  end
end

function world:update(dt)
  if self.dirty then
    -- print("update ENTTIY ADDED: REQUERY")
    for _, f in pairs(self.Update) do
      f.cache = world:query(f.query)
      f.func(f.cache, self, dt)
    end
    self.dirty = false
  else
    for _, f in pairs(self.Update) do
      f.func(f.cache, self, dt)
    end
  end
  collectgarbage()
end

--drawing occurs on the main thread
--drawables currently require transform and scale
function world:draw()
  local query = { "pos", "scale", "drawable" }
  local scale_factor = 0.001 --fiddle later
  for _, f in pairs(self.Draw) do
    f.func(f.cache, self, dt)
  end
  local result = self:query(query) or {}
  for _, entity in pairs(result) do
    if entity.drawable.sprite == "rect" then
      love.graphics.setColor(0, 0, 0)
      love.graphics.rectangle(
        'fill',
        entity.pos.x - entity.scale.x *0.5,
        entity.pos.y - entity.scale.y * 0.5,
        entity.scale.x,
        entity.scale.y 
      )
      love.graphics.setColor(1, 1, 1)
    else
      local sprite = entity.drawable.sprite
      local offsetX = sprite:getWidth() / 2
      local offsetY = sprite:getHeight() / 2
      love.graphics.draw(
        sprite,
        entity.pos.x,
        entity.pos.y,
        0,
        entity.scale.x * scale_factor,
        entity.scale.y * scale_factor,
        offsetX, offsetY
      )
    end
  end
end

function world:mouse1_clicked()
  for _, f in pairs(self.Mouse1) do
    f.func(f.cache, self, dt)
  end
end

function world:mouse2_clicked()
  for _, f in pairs(self.Mouse2) do
    f.func(f.cache, self, dt)
  end
end

function world:screen_to_world(x, y)
  local screenW, screenH = love.graphics.getDimensions()

  local worldMouseX = x - screenW / 2
  local worldMouseY = y - screenH / 2

  worldMouseX = worldMouseX * 0.01
  worldMouseY = worldMouseY * 0.01

  return worldMouseX, worldMouseY
end

return world
