--entry point
Utils = require('utils')
Inspect = require('inspect')
Scene = require('scene_controller')
local main_menu = require('main_menu')

function love.load()
  Scene:load_scene(main_menu)
end

function love.update(dt)
  Scene:update_scene(dt)
end

function love.draw()
  love.graphics.clear(1,1,1)
  Scene:draw_scene()
  love.graphics.setColor(0, 0, 0)
  love.graphics.print("current FPS: "..tostring(love.timer.getFPS()), 10, 10)
  love.graphics.setColor(1, 1, 1)
end

function love.mousepressed( x, y, button, istouch, presses)
  if button == 1 then
    Scene:mouse1_clicked()
  end
end
