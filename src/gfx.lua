
--[[ gfx.lua
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

local cpml = require('cpml')
local util = require('util')

local gfx = {}
gfx.matrix_stack = {}
gfx.matrix_stack[1] = cpml.mat4()
cpml.mat4.identity(gfx.matrix_stack[1])

function gfx.matrix()
    return gfx.matrix_stack[#gfx.matrix_stack]
end

function gfx.push()
    -- cpml.mat4.clone doesn't work for some reason
    local m = util.copy(gfx.matrix())
    table.insert(gfx.matrix_stack, m)
end

function gfx.pop()
    local m = gfx.matrix()
    table.remove(gfx.matrix_stack, #gfx.matrix_stack)
    return m
end

function gfx.identity()
    cpml.mat4.identity(gfx.matrix())
end

function gfx.projection(fov, aspect, n, f)
    local t   = math.tan(math.rad(fov) / 2)
    local out = cpml.mat4.new({1/(t*aspect), 0.0, 0.0,          0.0,
                               0.0,          1/t, 0.0,          0.0,
                               0.0,          0.0, (f+n)/(f-n), 1,
                               0.0,          0.0, -(2*f*n)/(f-n), 0.0})

    return out
end

function gfx.transform(pos, rot, scale)
    pos = pos or cpml.vec3(0, 0, 0)
    rot = rot or cpml.vec3(0, 0, 0)
    scale = scale or cpml.vec3(1, 1, 1)

    local m = gfx.matrix()

    -- only z and x
    cpml.mat4.translate(m, m, pos)
    cpml.mat4.rotate(m, m, rot.x, cpml.vec3(1, 0, 0))
    cpml.mat4.rotate(m, m, rot.z, cpml.vec3(0, 0, 1))
    cpml.mat4.scale(m, m, scale)

    shader:send('u_model', m:to_vec4s())
end

function gfx.camera(pos, rot, scale, origin)
    pos = pos or cpml.vec3(0, 0, 0)
    rot = rot or cpml.vec3(0, 0, 0)
    scale = scale or cpml.vec3(1, 1, 1)
    origin = origin or cpml.vec3(0, 0, 0)

    origin = pos - origin

    local m = gfx.matrix()

    -- only z and x
    cpml.mat4.rotate(m, m, -rot.x, cpml.vec3(1, 0, 0))
    cpml.mat4.translate(m, m, -origin)
    cpml.mat4.rotate(m, m, -rot.z, cpml.vec3(0, 0, 1))
    cpml.mat4.translate(m, m, origin)
    cpml.mat4.translate(m, m, -pos)

    shader:send('u_model', m:to_vec4s())
end

function gfx.draw(model)
    for _, buffer in ipairs(model) do
        local texture = model.textures[buffer.material]
        model.mesh:setTexture(texture)
        model.mesh:setDrawRange(buffer.first, buffer.last)
        love.graphics.draw(model.mesh)
    end
end

return gfx
