
--[[ game.lua
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
local cpml = require('cpml')
local iqm = require('iqm')
local world = require('world')

local game = {}
local camera_speed = 5
local fov = 90
local near = 0.1
local far = 100
local theta = 2.6

function game.load()
    l3d.set_culling(false)
    l3d.set_depth_write(true)
    l3d.set_depth_test('less')
    love.graphics.setBlendMode('replace')

    -- this probably shouldn't be global
    declare('shader')

    game.shader = love.graphics.newShader('assets/shaders/shader.glsl')
    shader = game.shader
    love.graphics.setShader(game.shader)

    local width, height = love.graphics.getDimensions()

    local w, h = 8, 8
    game.world = world.gen(w, h)
    game.camera = {pos = cpml.vec3(0, 6, 10),
                   rot = cpml.vec3(theta, 0, 0),
                   proj = gfx.projection(fov, width/height, near, far)}

    game.skybox = iqm.load('assets/models/skybox.iqm')
    local skybox = love.graphics.newImage('assets/textures/skybox.tga',
                                          {mipmaps = true})
    skybox:setFilter('nearest', 'nearest')
    game.skybox.textures = {
        Materialskybox = skybox
    }
end

function game.update(dt)
    game.world:update(dt)

    if love.keyboard.isDown('q') then
        game.camera.rot.z = game.camera.rot.z - dt*camera_speed
    elseif love.keyboard.isDown('e') then
        game.camera.rot.z = game.camera.rot.z + dt*camera_speed
    end
end

function game.draw()
    gfx.identity()

    l3d.set_depth_write(false)

    gfx.push()
    gfx.camera(cpml.vec3(0, 0, 4), game.camera.rot, nil)

    gfx.draw(game.skybox)
    gfx.pop()
    l3d.set_depth_write(true)

    gfx.camera(game.camera.pos, game.camera.rot, nil,
               game.world.entities.player.position)

    game.shader:send('u_proj', game.camera.proj:to_vec4s())

    game.world:draw()
end

function game.keypressed(key, scancode, isrepeat)
    game.world:keypressed(scancode)

    if scancode == 'r' then
        game.camera.pos.z = game.camera.pos.z + 0.1
    elseif scancode == 'f' then
        game.camera.pos.z = game.camera.pos.z - 0.1
    end
end

function game.mousepressed(mx, my, button)
    local p = gfx.unproject(mx, my, math.rad(fov), near, far,
                            gfx.matrix())
    game.world.entities.player:moveto(cpml.vec2(p.x, p.y))

    local near, d = game.world:nearest(p)
    if near.t == 'enemy' and d < 2.5 then
        game.world.entities.player:attack(near)
    elseif d > 2.5 then
        game.world.entities.player:attack(nil)
    end
end

function game.mousemoved(mx, my, dx, dy)
    game.world:mousemoved(mx, my, dx, dy)

    if love.mouse.isDown(1) and game.world.entities.player.dest then
        -- TODO: rotate player
        local p = gfx.unproject(mx, my, math.rad(fov), near, far,
                                gfx.matrix())
        game.world.entities.player:moveto(cpml.vec2(p.x, p.y))
    end
end

return game
