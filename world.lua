--World stores all game components and entities
--then we define systems that run on those components and entities
--world provides a query api that let's us access components from entities

local world = {
  running = false, --run update loop?
  cur_id = 0,
  dirty = false,   --if world has been modified, then we need to reset queries
  entities = {},   --list of all active entities in the game world
  components = {}, --list of possible components that can be added to entities
  Startup = {},    --holds all Startup systems
  Update = {}      --holds all Update systems
}

--generates an id when inserting a new entity
--Naive implementation for now
local function generate_id(_world)
  _world.cur_id = _world.cur_id + 1
  return _world.cur_id
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
      if Utils.has_same_keys(attribute, self.components[name]) then
        temp_components[name] = attribute
      else
        print("add_entity ERROR: Inserted component does not match world's registered component")
        return false
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
      for _, compName in ipairs(query) do
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

--adds the system to the desired schedule
function world:register_system(system)
  if string.lower(system.schedule) == "startup" then
    self.Startup[system.name] = { query = system.query, func = system.func }
    print("register_system REGISTERED: startup, " .. system.name)
  elseif string.lower(system.schedule) == "update" then
    self.Update[system.name] = { query = system.query, func = system.func }
    print("register_system REGISTERED:  update, ".. system.name)
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
    for _, f in pairs(self.Update) do
      f.cache = world:query(f.query)
      f.func(f.cache, dt)
    end
    self.dirty = false
  else
    for _, f in pairs(self.Update) do
      f.func(f.cache, dt)
    end
  end
  collectgarbage()
end

--drawing occurs on the main thread
--drawables currently require transform and scale
function world:draw()
  local query = {"pos", "scale", "drawable"}
  for id, entity in pairs(self:query(query)) do
    love.graphics.draw(entity.drawable.sprite, entity.pos.x, entity.pos.y, 0, entity.scale.x, entity.scale.y)
  end
end

return world
