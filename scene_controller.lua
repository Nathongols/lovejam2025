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
  self.world:draw()
end

return scene_controller
