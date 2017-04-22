
--[[ player.lua
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
local iqm = require('iqm')
local cpml = require('cpml')

local player = {}
local mt = {__index = player}

local acc = 15
local decc = 60
local max_vel = 250
local rotation_speed = 5 -- keep in sync with game.lua/camera_speed

function player.new(x, y, z)
    local self = {}
    setmetatable(self, mt)

    self.velocity = cpml.vec2(0, 0)
    self.position = cpml.vec3(x or 0, y or 0, z or 1)
    self.rotation = 0 -- z only
    self.scale = cpml.vec3(0.5, 0.5, 0.5)
    self.model = iqm.load('assets/models/roman.iqm')
    self.model.textures = {}

    return self
end

function player:draw()
    gfx.push()

    gfx.transform(self.position, cpml.vec3(0, 0, self.rotation), self.scale)
    gfx.draw(self.model)

    gfx.pop()
end

function player:update(dt)
    -- Update velocity
    local vx, vy = self.velocity.x, self.velocity.y

    if love.keyboard.isDown('w') then
        vy = util.clamp(vy - acc*dt, -max_vel, max_vel)
    elseif love.keyboard.isDown('s') then
        vy = util.clamp(vy + acc*dt, -max_vel, max_vel)
    else
        vy = util.clamp(vy - decc*dt*util.sign(vy), 0, max_vel*util.sign(vy))
    end

    if love.keyboard.isDown('a') then
        vx = util.clamp(vx - acc*dt, -max_vel, max_vel)
    elseif love.keyboard.isDown('d') then
        vx = util.clamp(vx + acc*dt, -max_vel, max_vel)
    else
        vx = util.clamp(vx - decc*dt*util.sign(vx), 0, max_vel*util.sign(vx))
    end

    self.velocity.x, self.velocity.y = vx, vy

    local c, s = math.cos(self.rotation), -math.sin(self.rotation)
    local vx = self.velocity.x*dt
    local vy = self.velocity.y*dt

    -- Update position
    self.position.x, self.position.y = 
            self.position.x + vx*c + vy*s,
            self.position.y + vy*c + vx*s

    -- Camera position
    game.state.camera.pos.x, game.state.camera.pos.y = 
            game.state.camera.pos.x + vx*c + vy*s,
            game.state.camera.pos.y + vy*c + vx*s

    -- A cheaty way to get mouse aiming
    local w, h = love.graphics.getDimensions()
    local mx, my = love.mouse.getPosition()
    local p = cpml.vec3(mx-w/2, my-h/2+16, 0.0)
    p = p:normalize()
    if p.y <= 0 then
        self.rotation = math.asin(p.x)
    else
        self.rotation = -math.asin(p.x)+math.pi
    end
    self.rotation = self.rotation + game.state.camera.rot.z
end

return player
