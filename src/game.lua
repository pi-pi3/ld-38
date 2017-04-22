
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
local world = require('world')
local shader = require('assets/shaders/shader.glsl')

local game = {}

function game.load()
    love.graphics.setCulling(false) -- for now
    love.graphics.setDepthWrite(true)
    love.graphics.setDepthTest('less')
    love.graphics.setBlendMode('replace')

    -- this probably shouldn't be global
    declare('transform_matrix', cpml.mat4.identity())

    game.shader = love.graphics.newShader('assets/shaders/shader.glsl')

    local width, height = love.graphics.getDimensions()

    local w, h = 8, 8
    game.world = world.gen(w, h)
    game.camera = {pos = cpml.vec3(0, 0, 0),
                   rot = cpml.vec3(0, 0, 0), -- only z and x rotation is used
                   proj = cpml.mat4.from_perspective(90, width/height, 0.1, 100)}
end

function game.draw()
    love.graphics.clearDepth()

    cpml.mat4f.identity(transform_matrix)

    cpml.mat4f.translate(transform_matrix, transform_matrix, -game.camera.pos)
    -- only z and x
    cpml.mat4f.rotate(transform_matrix, transform_matrix,
                      -game.rot.z, cpml.vec3(0, 0, 1))
    cpml.mat4f.rotate(transform_matrix, transform_matrix,
                      -game.rot.x, cpml.vec3(1, 0, 0))

    game.shader:send('u_proj', game.camera.proj.to_vec4s())

    game.world:draw()
end
