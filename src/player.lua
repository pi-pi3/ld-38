
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

local player = {}
local mt = {__index = player}

local acc = 150
local decc = 600
local max_vel = 6
local rotation_speed = 5 -- keep in sync with game.lua/camera_speed
local attack_delay = 0

function player.new(x, y, z)
    local self = {}
    setmetatable(self, mt)

    self.t = 'player'

    self.velocity = cpml.vec2(0, 0)
    self.position = cpml.vec3(x or 0, y or 0, z or 1)
    self.rotation = 0 -- z only
    self.scale = cpml.vec3(1, 1, 1)

    self.health = 42 -- The answer to life, the universe and everything.
    self.strength = 5
    self.power = 5
    self.agility = 5
    self.defense = 5

    self.timer = 0
    self.float = 0
    self.attack_timer = attack_delay

    self.attacking = false

    self.model = iqm.load('assets/models/roman.iqm')
    self.model.textures = {}
    self.model.anims = iqm.load_anims('assets/models/roman.iqm')
    self.model.anim = anim9(self.model.anims)

    self.walking = self.model.anim:add_track('walking')
    self.walking.playing = true

    self.model.textures['djinni_body.tga'] =
        love.graphics.newImage('assets/textures/djinni_body.tga', {mipmaps = true})
    self.model.textures['djinni_body.tga']:setFilter('nearest', 'nearest')

    self.model.textures['djinni_belt.tga'] =
        love.graphics.newImage('assets/textures/djinni_belt.tga', {mipmaps = true})
    self.model.textures['djinni_body.tga']:setFilter('nearest', 'nearest')

    self.model.textures['djinni_eye.tga'] =
        love.graphics.newImage('assets/textures/djinni_eye.tga', {mipmaps = true})
    self.model.textures['djinni_body.tga']:setFilter('nearest', 'nearest')

    self.model.textures['djinni_tail.tga'] =
        love.graphics.newImage('assets/textures/djinni_tail.tga', {mipmaps = true})
    self.model.textures['djinni_body.tga']:setFilter('nearest', 'nearest')

    return self
end

function player:draw()
    gfx.set_shader(shader_anim)

    gfx.push()

    gfx.transform(self.position+cpml.vec3(0, 0, self.float),
                  cpml.vec3(0, 0, self.rotation),
                  self.scale)
    gfx.draw(self.model)

    gfx.pop()
end

function player:update(dt)
    self.model.anim:update(dt)

    self.timer = self.timer + dt
    self.attack_timer = self.attack_timer + dt
    self.float = 0.5+math.sin(self.timer)*0.5

    -- Update velocity
    local vx, vy = self.velocity.x, self.velocity.y

    if self.attacking and self.dest then
        self.dest = cpml.vec2(self.attacking.position.x, self.attacking.position.y)
    end

    if self.attacking and self.attack_timer > attack_delay then
        game.state.world:insert(fireball.new(self))
        self.attack_timer = 0
    end

    if self.dest then
        local dir = (self.dest - cpml.vec2(self.position.x, self.position.y))

        local min_dist = 1
        if self.attacking then min_dist = 6.25 end

        if dir:len2() < min_dist then
            self.dest = nil
        end

        self.rotation = select(2, dir:to_polar())-math.pi*3/2
        vx = 0
        vy = util.clamp(vy - acc*dt, -max_vel, max_vel)
    else 
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
    end

    self.velocity.x, self.velocity.y = vx, vy

    local c, s = math.cos(self.rotation), math.sin(self.rotation)
    local vx = self.velocity.x*dt
    local vy = self.velocity.y*dt

    -- Update position
    self.position.x, self.position.y = 
            self.position.x + vx*c - vy*s,
            self.position.y + vy*c + vx*s

    -- Camera position
    game.state.camera.pos.x, game.state.camera.pos.y = 
            game.state.camera.pos.x + vx*c - vy*s,
            game.state.camera.pos.y + vy*c + vx*s

    -- A cheaty way to get mouse aiming
    local w, h = love.graphics.getDimensions()
    local mx, my = love.mouse.getPosition()
    local p = cpml.vec2(mx-w/2, my-h/2+16)
    p = p:normalize()
    self.rotation = select(2, p:to_polar())-math.pi*3/2
    self.rotation = self.rotation + game.state.camera.rot.z
end

function player:moveto(x, y)
    local pos
    if x and not y then
        pos = x
    else
        pos = cpml.vec2(x, y)
    end

    self.dest = pos
end

function player:attack(enemy)
    self.attacking = enemy
end


function player:mousepressed(mx, my, button)
    if button == 2 then
        if self.attack_timer > attack_delay then
            game.state.world:insert(fireball.new(self))
            self.attack_timer = 0
        end
    end
end

function player:keypressed(key)
    self.dest = nil
    self.attacking = false
end

function player:dir()
    return cpml.vec2(math.sin(self.rotation), -math.cos(self.rotation))
end

function player:pushback(v)
    -- TODO
end

return player
