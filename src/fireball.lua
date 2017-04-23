
--[[ fireball.lua
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

local fireball = {}
local mt = {__index = fireball}

local time = 8.0
local max_vel = 10.0 -- Gotta go fast

function fireball.new(owner, mult)
    local self = {}
    setmetatable(self, mt)

    self.t = 'fireball'
    self.health = 1

    local rot = owner.rotation
    self.position = util.copy(owner.position)
    self.velocity = cpml.vec3(math.sin(rot)*max_vel, -math.cos(rot)*max_vel, 0.0)
    self.rotation = rot

    -- Big things hit hard, right?
    local scale = owner.scale.x * owner.scale.y * owner.scale.z
    local scale2 = owner.scale.x * owner.scale.y
    self.radius2 = scale2*scale2*6.25

    self.owner = owner
    -- high power, low agility means your damage is going to vary (A LOT)
    -- low power, high agility means your damage is going to be rel. constant
    -- BUT high power also means high pushback
    --     high agility means high critical damage
    self.critical = math.random() > owner.agility/100
    self.dmg = math.random(owner.strength-owner.power*scale/owner.agility,
                           owner.strength-owner.power*scale/owner.agility)
               * (mult or 1)
               * (self.critical and 3 or 1)
               * scale
    self.dmg = math.floor(self.dmg)

    self.pushback = math.random() > (owner.power/100*scale)

    if self.pushback then
        self.pushback = owner.power*scale
    end

    self.timer = 0

    if not fireball.model then
        fireball.model = iqm.load('assets/models/fireball.iqm')
        fireball.model.textures = {}

        fireball.model.textures['fireball.tga'] =
            love.graphics.newImage('assets/textures/fireball.tga', {mipmaps = true})
        fireball.model.textures['fireball.tga']:setFilter('nearest', 'linear')
    end

    return self
end

function fireball:draw()
    gfx.set_shader(shader_static)

    gfx.push()

    gfx.transform(self.position,
                  cpml.vec3(0, 0, self.rotation),
                  self.owner.scale)
    gfx.draw(fireball.model)

    gfx.pop()
end

function fireball:update(dt)
    if self.timer > time then
        self.health = 0
    end

    self.timer = self.timer + dt
    
    local vx, vy = self.velocity.x*dt, self.velocity.y*dt
    self.position = self.position + cpml.vec3(vx, vy, 0.0)

    if self.timer > time then
        self.health = 0
    end

    local world = game.state.world

    for _, e in pairs(world.entities) do
        if e ~= self.owner then
            if self:collision(e) then
                self:hit(e)
                self.health = 0
            end
        end
    end
end

function fireball:collision(e)
    local d = e.position - self.owner.position
    d = cpml.vec2(d.x, d.y)

    return d:len2() < self.radius2
end

function fireball:hit(e)
    e.health = e.health - (self.dmg - e.defense)
    if self.pushback then
        local d = e.position - self.owner.position
        e:pushback(d:normalize()*self.pushback)
    end
end

function fireball:alive()
    return self.health > 0
end

return fireball
