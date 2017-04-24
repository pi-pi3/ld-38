
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
local entity = require('entity')
local rect = require('rect')

local player = {}
setmetatable(player, {__index = entity})
local mt = {__index = player}

local acc = 150
local decc = 600
local rotation_speed = 5 -- keep in sync with game.lua/camera_speed
-- TODO: attack_delay per spell
local attack_delay = 1

function player.new(x, y, z)
    local self = entity.new(x, y, z, 'djinni.iqm', {'djinni.tga'},
                            'idle', rect.new(0, 0, 1, 1))
    setmetatable(self, mt)

    self.t = 'player'

    self.health = 42 -- The answer to life, the universe and everything.
    self.health_max = 42
    self.strength = 6
    self.power = 20
    self.agility = 5
    self.defense = 5
    self.max_vel = 6
    self.range2 = 60

    self.attack_timer = attack_delay
    self.attacking = false
    self.shooting = 0
    self.spell = require('fireball')

    self.rotation = math.pi

    self.sound_death = love.audio.newSource('assets/sounds/player_death.ogg')

    return self
end

function player:update(dt)
    if love.keyboard.isDown('a') then
        self.spell = require('fireball')
    end
    if love.keyboard.isDown('d') then
        self.spell = require('ice')
    end

    if self.shooting > 0 then
        self.shooting = self.shooting - dt
    end

    if self.attacking then
        if self.dest then
            self.dest = cpml.vec2(self.attacking.position.x, self.attacking.position.y)
        end

        if self.attack_timer > attack_delay
            and cpml.vec2.dist2(self.attacking.position, self.position)
                < self.range2 then
            game.state.world:insert(self.spell.new(self))
            self.attack_timer = 0
        end

        if not self.attacking:alive() then
            self.attacking = nil
        end
    end

    local vx, vy = self.velocity.x, self.velocity.y 
    -- Goto dest
    if self.dest then
        -- FIXME
        local dir = (self.dest - cpml.vec2(self.position.x, self.position.y))
        dir = cpml.vec3(dir.x, dir.y, 0)

        local min_dist = 1
        if self.attacking then min_dist = self.range2 end

        if dir:len2() < min_dist then
            vx, vy = 0, 0
            if self.walking then
                self.model.anim:remove_track(self.walking)
                self.walking = nil
            end
            if not self.idle then
                self.idle = self.model.anim:add_track('idle')
                self.idle.playing = true
            end
        else
            dir = dir:normalize()
            vx = util.clamp(vx + dir.x*acc*dt, -self:stat('max_vel'), self.max_vel)
            vy = util.clamp(vy + dir.y*acc*dt, -self:stat('max_vel'), self.max_vel)
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
            game.state.world:insert(self.spell.new(self))
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
    if self.idle then
        self.model.anim:remove_track(self.idle)
        self.idle = nil
    end
    if not self.walking then
        self.walking = self.model.anim:add_track('walking')
        self.walking.playing = true
    end

    if self.shooting <= 0 then
        self:lookat(pos)
    end
end

function player:die()
    game.state.world.flag_stop = true
end

return player
