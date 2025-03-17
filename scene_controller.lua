--Library to load and clear menu screens/canvases and world entities

--initialize the game world
local scene_controller = {
  cur_scene = {},
  world = require('world')
}

function scene_controller:load_scene(scene)
  -- world:clear()
  scene.load(self.world)
  self.cur_scene = scene
  self.world:start()
end

function scene_controller:update_scene(dt)
  if self.cur_scene == nil then
    print("no current scene, did you load the scene?")
    return false
  end
  self.world:update(dt)
end

function scene_controller:draw_scene()
  local width, height = love.graphics.getDimensions()
  love.graphics.push()
  love.graphics.translate(width / 2, height / 2)
  love.graphics.scale(100, 100)
  self.world:draw()
  love.graphics.pop()
end

function scene_controller:mouse1_clicked()
  if self.world then
    self.world:mouse1_clicked()
  end
end

return scene_controller
