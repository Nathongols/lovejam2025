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
  Scene:draw_scene()
  love.graphics.print("current FPS: "..tostring(love.timer.getFPS()), 10, 10)
end
