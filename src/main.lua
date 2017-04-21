
--[[ main.lua Entry point in this game.
    Copyright (c) 2017 Szymon "pi_pi3" Walter, Szymon Bednarek

    This software is provided 'as-is', without any express or implied
    warranty. In no event will the authors be held liable for any damages
    arising from the use of this software.

    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:

    1. The origin of this software must not be misrepresented you must not
    claim that you wrote the original software. If you use this software
    in a product, an acknowledgment in the product documentation would be
    appreciated but is not required.

    2. Altered source versions must be plainly marked as such, and must not be
    misrepresented as being the original software.

    3. This notice may not be removed or altered from any source
    distribution.
]]

local util = require('util')
local gui = require('gui')
declare = util.declare -- global alias for declare, should work in every file

function love.load()
    math.randomseed(os.time()) -- don't forget your randomseed!
    love.keyboard.setKeyRepeat(true)

    -- this is called in love.load, because some external libraries might
    -- require global variables
    util.init_G()

    -- beyond this point in program execution every global variable has to be
    -- declared like this:
    declare('game', {})

    -- initial game state is the menu, but you can change it into a splash
    -- screen for example
    game.state = require('menu')
    game.state.load()
end


function love.update(dt)
    if not game.state.pause
        and game.state.update then
        game.state.update(dt)
    end

    gui.updateall(game.state.elements)
end

function love.draw()
    love.graphics.clear(0, 0, 0)

    if game.state.draw then
        game.state.draw(dt)
    end

    gui.drawall(game.state.elements)
end


-- functions beyond this point normally don't have to be editted
function love.mousepressed(mx, my, button)
    if not game.state.pause
        and game.state.mousepressed then
        game.state.mousepressed(mx, my, button)
    end

    if button == 1 then
        gui.mousepressed(game.state.elements, mx, my)
    end
end

function love.mousereleased(mx, my, button)
    if not game.state.pause
        and game.state.mousereleased then
        game.state.mousereleased(mx, my, button)
    end

    if button == 1 then
        gui.mousereleased(game.state.elements, mx, my)
    end
end

function love.mousemoved(mx, my, dx, dy)
    if not game.state.pause
        and game.state.mousemoved then
        game.state.mousemoved(mx, my, dx, dy)
    end

    gui.mousemoved(game.state.elements, mx, my, dx, dy)
end

function love.wheelmoved(dx, dy)
    if not game.state.pause
        and game.state.wheelmoved then
        game.state.wheelmoved(dx, dy)
    end

    gui.wheelmoved(game.state.elements, dx, dy)
end

function love.textinput(c)
    if not game.state.pause
        and game.state.textinput then
        game.state.textinput(mx, my, dx, dy)
    end

    gui.textinput(game.state.elements, c)
end

function love.keypressed(key, scancode, isrepeat)
    if not game.state.pause
        and game.state.keypressed then
        game.state.keypressed(key, scancode, isrepeat)
    end

    gui.keypressed(game.state.elements, key, scancode, isrepeat)
end

function love.quit()
    if game.state.quit then
        game.state.quit()
    end
end

