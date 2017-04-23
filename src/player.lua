
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
local anim9 = require('anim9')
local fireball = require('fireball')
local entity = require('entity')

local player = {}
setmetatable(player, {__index = entity})
local mt = {__index = player}

local acc = 150
local decc = 600
local max_vel = 6
local rotation_speed = 5 -- keep in sync with game.lua/camera_speed
local attack_delay = 1

function player.new(x, y, z)
    local self = entity.new(x, y, z, 'roman.iqm', 
                            {'djinni_body.tga', 'djinni_belt.tga', 
                             'djinni_eye.tga', 'djinni_tail.tga'},
                            'walking')
    setmetatable(self, mt)

    self.t = 'player'

    self.health = 42 -- The answer to life, the universe and everything.
    self.health_max = 42
    self.strength = 5
    self.power = 5
    self.agility = 5
    self.defense = 5

    self.attack_timer = attack_delay

    self.attacking = false

    return self
end

function player:update(dt)
    self.timer = self.timer + dt
    self.attack_timer = self.attack_timer + dt

    if self.attacking and self.dest then
        self.dest = cpml.vec2(self.attacking.position.x, self.attacking.position.y)
    end

    if self.attacking and self.attack_timer > attack_delay then
        game.state.world:insert(fireball.new(self))
        self.attack_timer = 0
    end

    local vx, vy = self.velocity.x, self.velocity.y 
    -- Goto dest
    if self.dest then
        local dir = (self.dest - cpml.vec2(self.position.x, self.position.y))

        local min_dist = 1
        if self.attacking then min_dist = 6.25 end

        if dir:len2() < min_dist then
            self.dest = nil
            vx, vy = 0, 0
        else
            dir = dir:normalize()
            vx = util.clamp(vx + dir.x*acc*dt, -max_vel, max_vel)
            vy = util.clamp(vy + dir.y*acc*dt, -max_vel, max_vel)
        end
    end

    self.velocity.x, self.velocity.y = vx, vy

    -- Camera position
    game.state.camera.pos.x, game.state.camera.pos.y = 
            game.state.camera.pos.x + self.velocity.x*dt,
            game.state.camera.pos.y + self.velocity.y*dt

    entity.update(self, dt)

    -- TODO: remove and replace
    -- A cheaty way to get mouse aiming
    local w, h = love.graphics.getDimensions()
    local mx, my = love.mouse.getPosition()
    local p = cpml.vec2(mx-w/2, my-h/2+16)
    p = p:normalize()
    self.rotation = select(2, p:to_polar())-math.pi*3/2
    self.rotation = self.rotation + game.state.camera.rot.z
end

function player:mousepressed(mx, my, button)
    if button == 2 then
        if self.attack_timer > attack_delay then
            game.state.world:insert(fireball.new(self))
            self.attack_timer = 0
        end
    end
end

return player
