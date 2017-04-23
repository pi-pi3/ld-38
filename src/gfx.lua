
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

gfx.proj = cpml.mat4()

gfx.shader = {}
gfx.sent = {model = false, proj = false}

function gfx.set_shader(shader)
    if shader == gfx.shader then
        return
    end

    love.graphics.setShader(shader)
    gfx.shader = shader
    gfx.sent = {model = false, proj = false}
end

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
    local m = gfx.matrix()
    cpml.mat4.identity(m)
    gfx.shader:send('u_model', m:to_vec4s())
    gfx.sent.model = true
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

    gfx.shader:send('u_model', m:to_vec4s())
    gfx.sent.model = true
end

function gfx.camera(pos, rot, scale, origin, proj)
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

    gfx.shader:send('u_model', m:to_vec4s())
    gfx.sent.model = true

    if proj then
        gfx.shader:send('u_proj', proj:to_vec4s())
        gfx.sent.proj = true
        gfx.proj = proj
    end
end

function gfx.draw(model)
    if model.anim then
        gfx.shader:send('u_pose', unpack(model.anim.current_pose))
    end

    if not gfx.sent.model then
        gfx.shader:send('u_model', gfx.matrix():to_vec4s())
        gfx.sent.model = true
    end

    if not gfx.sent.proj then
        gfx.shader:send('u_proj', gfx.proj:to_vec4s())
        gfx.sent.proj = true
    end

    for _, buffer in ipairs(model) do
        local texture = model.textures[buffer.material]
        model.mesh:setTexture(texture)
        model.mesh:setDrawRange(buffer.first, buffer.last)
        love.graphics.draw(model.mesh)
    end
end

function gfx.unproject(mx, my, fov, near, far, view)
    local w, h = love.graphics.getDimensions()
    local aspect = w/h
    local tan_fov = math.tan(fov*0.5)

    local s = {x = tan_fov*(2*mx/w-1)*aspect,
               y = 1-2*my/h}

    local p1 = {s.x*near, s.y*near, near, 1.0}
    local p2 = {s.x*far, s.y*far, far, 1.0}

    local inv = cpml.mat4()
    cpml.mat4.invert(inv, view)

    cpml.mat4.mul_vec4(p1, inv, p1)
    cpml.mat4.mul_vec4(p2, inv, p2)

    p1 = cpml.vec3(p1)
    p2 = cpml.vec3(p2)

    local d = p2-p1

    -- 2.0 = ground level
    local w = (2.0-p1.z)/(d.z)

    return p1+d*w
end

return gfx
