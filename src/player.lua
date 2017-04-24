
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
local cpml = require('cpml')
local fireball = require('fireball')
local entity = require('entity')
local rect = require('rect')

local player = {}
setmetatable(player, {__index = entity})
local mt = {__index = player}

local acc = 150
local decc = 600
local rotation_speed = 5 -- keep in sync with game.lua/camera_speed
local attack_delay = 1

function player.new(x, y, z)
    local self = entity.new(x, y, z, 'roman.iqm', 
                            {'djinni_body.tga', 'djinni_belt.tga', 
                             'djinni_eye.tga', 'djinni_tail.tga'},
                            'walking', rect.new(0, 0, 1, 1))
    setmetatable(self, mt)

    self.t = 'player'

    self.health = 42 -- The answer to life, the universe and everything.
    self.health_max = 42
    self.strength = 8
    self.power = 20
    self.agility = 5
    self.defense = 5
    self.max_vel = 6
    self.range2 = 60

    self.attack_timer = attack_delay
    self.attacking = false
    self.shooting = 0

    return self
end

function player:update(dt)
    self.timer = self.timer + dt
    self.attack_timer = self.attack_timer + dt

    if self.shooting > 0 then
        self.shooting = self.shooting - dt
    end

    if self.attacking then
        if self.dest then
            self.dest = cpml.vec2(self.attacking.position.x, self.attacking.position.y)
        end

        if self.attack_timer > attack_delay then
            game.state.world:insert(fireball.new(self))
            self.attack_timer = 0
        end

        if not self.attacking:alive() then
            self.attacking = nil
        end
    end

    local vx, vy = self.velocity.x, self.velocity.y 
    -- Goto dest
    if self.dest then
        local dir = (self.dest - cpml.vec2(self.position.x, self.position.y))

        local min_dist = 1
        if self.attacking then min_dist = self.range2 end

        if dir:len2() < min_dist then
            self.dest = nil
            vx, vy = 0, 0
        else
            dir = dir:normalize()
            vx = util.clamp(vx + dir.x*acc*dt, -self.max_vel, self.max_vel)
            vy = util.clamp(vy + dir.y*acc*dt, -self.max_vel, self.max_vel)
        end
    end

    self.velocity.x, self.velocity.y = vx, vy

    -- Camera position
    game.state.camera.pos.x, game.state.camera.pos.y = 
            game.state.camera.pos.x + self.velocity.x*dt,
            game.state.camera.pos.y + self.velocity.y*dt

    entity.update(self, dt)
end

function player:mousepressed(mx, my, button)
    if button == 2 then
        if self.attack_timer > attack_delay then
            game.state.world:insert(fireball.new(self))
            self.attack_timer = 0
        end
    end
end

function player:moveto(x, y)
    local pos
    if x and not y then
        pos = x
    else
        pos = cpml.vec2(x, y)
    end

    self.dest = pos
    if self.shooting == 0 then
        self:lookat(pos)
    end
end

function player:die()
    game.state.world.flag_stop = true
end

return player
