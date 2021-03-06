
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
local intro = require('intro')
local outro = require('outro')

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
    declare('shader_static')
    declare('shader_anim')

    game.shader_static = love.graphics.newShader('assets/shaders/static.glsl')
    shader_static = game.shader_static

    game.shader_anim = love.graphics.newShader('assets/shaders/anim.glsl')
    shader_anim = game.shader_anim

    gfx.set_shader(game.shader_static)

    local width, height = love.graphics.getDimensions()

    local w, h = 12, 12
    game.world = world.gen(w, h)
    game.camera = {pos = cpml.vec3(0, 8, 12),
                   rot = cpml.vec3(theta, 0, 0),
                   proj = gfx.projection(fov, width/height, near, far)}

    game.skybox = iqm.load('assets/models/skybox.iqm')
    local skybox = love.graphics.newImage('assets/textures/skybox.tga',
                                          {mipmaps = true})
    skybox:setFilter('nearest', 'nearest')
    game.skybox.textures = {
        Materialskybox = skybox
    }

    game.intro = 2
    game.speech = {text = nil, pos = nil}
    game.screenshake = false

    intro(1)
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
    if game.black then
        return
    end

    l3d.set_depth_write(true)
    l3d.set_depth_test('less')
    love.graphics.setBlendMode('replace')
    gfx.set_shader(shader_static)

    gfx.identity()

    l3d.set_depth_write(false)

    gfx.push()
    gfx.camera(cpml.vec3(0, 0, 4), game.camera.rot, nil)

    gfx.draw(game.skybox)
    gfx.pop()
    l3d.set_depth_write(true)

    if game.screenshake then
        local scale = 0.3
        local off = cpml.vec3((math.random()-0.5)*scale,
                              (math.random()-0.5)*scale,
                              (math.random()-0.5)*scale)

        gfx.camera(game.camera.pos + off,
                   game.camera.rot, nil,
                   game.world.entities.player.position,
                   game.camera.proj)
    else
        gfx.camera(game.camera.pos, game.camera.rot, nil,
                   game.world.entities.player.position,
                   game.camera.proj)
    end

    game.world:draw()
    
    if game.intro or game.outro then
        l3d.set_depth_write(false)
        gfx.set_shader(nil)

        love.graphics.origin()
        love.graphics.setBlendMode('alpha')

        if game.speech.text then
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf(game.speech.text,
                                 game.speech.pos.x, game.speech.pos.y,
                                 256, 'center')
        end

        l3d.set_depth_write(true)
        gfx.set_shader(shader_static)

        love.graphics.setBlendMode('replace')
    end
end

function game.keypresssed(key, scancode, isrepeat)
    if game.intro then
        if intro(game.intro) then
            game.intro = game.intro + 1
        else
            game.intro = false
            game.world:add_enemy(1)
        end
    end

    if game.outro then
        if outro(game.outro) then
            game.outro = game.outro + 1
        else
            game.load()
        end
    end
end

function game.mousepressed(mx, my, button)
    if game.intro then
        if intro(game.intro) then
            game.intro = game.intro + 1
        else
            game.intro = false
            game.world:add_enemy(1)
        end

        return
    end

    if game.outro then
        if outro(game.outro) then
            game.outro = game.outro + 1
        else
            game.load()
        end
    end

    local player = game.world.entities.player
    local p = gfx.unproject(mx, my, math.rad(fov), near, far,
                            gfx.matrix())

    if button == 1 then
        player:moveto(cpml.vec2(p.x, p.y))

        local near, d = game.world:nearest(p)
        if near.t == 'enemy' and d < 2.5 then
            game.world.entities.player:attack(near)
        elseif d > 2.5 then
            game.world.entities.player:attack(nil)
        end
    elseif button == 2 then
        player.shooting = 0.5
        player:lookat(cpml.vec2(p.x, p.y))
    end

    game.world:mousepressed(mx, my, button)
end

function game.mousemoved(mx, my, dx, dy)
    if love.mouse.isDown(1) and game.world.entities.player.dest then
        local p = gfx.unproject(mx, my, math.rad(fov), near, far,
                                gfx.matrix())

        local player = game.world.entities.player
        player:moveto(cpml.vec2(p.x, p.y))
    end
end

function game.resize(w, h)
    game.camera.proj = gfx.projection(fov, w/h, near, far)
end

return game
