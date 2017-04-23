
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
local entity = require('entity')

local fireball = {}
setmetatable(fireball, {__index = entity})
local mt = {__index = fireball}

local time = 8.0

function fireball.new(owner, mult)
    local self = entity.new(owner.position.x, owner.position.y, owner.position.z+1,
                            'fireball.iqm', {'fireball.tga'}, nil)
    setmetatable(self, mt)

    self.t = 'fireball'
    self.health = 1

    local rot = owner.rotation
    self.rotation = rot

    self.max_vel = 10.0
    self.velocity = cpml.vec2(math.sin(rot)*self.max_vel, -math.cos(rot)*self.max_vel)

    -- Big things hit hard, right?
    local scale = owner.scale.x * owner.scale.y * owner.scale.z
    local scale2 = owner.scale.x * owner.scale.y
    self.radius2 = scale2*scale2*4

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

    self.pushback_power = math.random() > (owner.power/100*scale)

    if self.pushback_power then
        self.pushback_power = owner.power*scale*1000
    end

    return self
end

function fireball:update(dt)
    if self.timer > time then
        game.state.world:remove(self)
        return
    end

    local world = game.state.world

    for _, e in pairs(world.entities) do
        if e ~= self.owner and e ~= self then
            if self:collision(e) then
                self:hit(e)
                game.state.world:remove(self)
                return
            end
        end
    end

    entity.update(self, dt)
end

function fireball:collision(e)
    local d = e.position - self.position
    d = cpml.vec2(d.x, d.y)

    return d:len2() < self.radius2
end

function fireball:hit(e)
    e.health = e.health - (self.dmg - e.defense)
    if self.pushback_power then
        local d = e.position - self.owner.position
        e:pushback(d:normalize()*self.pushback_power)
    end
end

return fireball
