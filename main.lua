--entry point
Utils = require('utils')
Inspect = require('inspect')
Scene = require('scene_controller')
local main_menu = require('main_menu')

function love.run()    
    if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

    -- Workaround for macOS RNG issues
    if jit and jit.os == "OSX" then
        math.randomseed(os.time())
        math.random(); math.random()
    end

    if love.timer then love.timer.step() end

    local dt = 0
    local dt_smooth = 1/100

    local run_time = 0
    local fixed_dt = 1/60        -- your fixed update timestep
    local accumulator = 0
    local current_time = love.timer.getTime()

    return function()
        run_time = love.timer.getTime()

        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a or 0
                    end
                end
                love.handlers[name](a, b, c, d, e, f)
            end
        end

        -- Calculate elapsed time and accumulate it.
        local new_time = love.timer.getTime()

        local frame_dt = new_time - current_time
        current_time = new_time
        accumulator = accumulator + frame_dt

        if love.timer then dt = love.timer.step() end
        dt_smooth = math.min(0.8*dt_smooth + 0.2*dt, 0.1)

        if love.update then love.update(dt_smooth) end
        --if love.update then love.update(dt) end

        -- Optionally compute an interpolation factor:
        -- local alpha = accumulator / fixed_dt

        if love.graphics and love.graphics.isActive() then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())
            if love.draw then
                -- Optionally, you can pass 'alpha' into your draw function.
                love.draw()
            end
            love.graphics.present()
        end

        run_time = math.min(love.timer.getTime() - run_time, 0.1)
		if run_time < 1./1500 then love.timer.sleep(1./1500 - run_time) end 
    end
end


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
