
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

local time = 1.0

local sound_fireball = love.audio.newSource('assets/sounds/fireball.ogg')

function fireball.new(owner, mult, model, textures, quiet)
    model = model or 'fireball.iqm'
    textures = textures or {'fireball.tga'}

    local self = entity.new(owner.position.x, owner.position.y, owner.position.z+1,
                            model, textures, nil)
    setmetatable(self, mt)

    self.t = 'spell.fireball'
    self.health = 1
    self.gravity = false
    self.life = time

    local rot = owner.rotation
    self.rotation = rot

    self.max_vel = 25.0
    self.velocity = cpml.vec2(math.sin(rot)*self:stat('max_vel'), -math.cos(rot)*self.max_vel)

    -- Big things hit hard, right?
    local scale = owner.scale.x * owner.scale.y * owner.scale.z
    local scale2 = owner.scale.x * owner.scale.y
    self.radius2 = scale2*scale2

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

    self.pushback_power = math.random() < (owner.power/100*scale)

    if self.pushback_power then
        self.pushback_power = owner.power*scale*300
    end

    self.hits = 2
    self.hit_hash = {}
    self.dmg_falloff = 0.75

    if not quiet then
        sound_fireball:play()
    end

    return self
end

function fireball:update(dt)
    local world = game.state.world

    for _, e in pairs(world.entities) do
        if e ~= self.owner and e ~= self then
            if self:collision(e) then
                self:hit(e)
                self.hits = self.hits - 1
                self.dmg = self.dmg*self.dmg_falloff
                if self.pushback_power then
                    self.pushback_power = self.pushback_power*self.dmg_falloff
                end
                return
            end
        end
    end

    entity.update(self, dt)

    if self.hits <= 0 then
        game.state.world:remove(self)
    end
end

function fireball:collision(e)
    if self.hit_hash[e] then
        return false
    end

    if util.startswith(e.t, 'spell') then
        return false
    end

    local d = e.position - self.position
    d = cpml.vec2(d.x, d.y)

    return d:len2() < self.radius2
end

function fireball:hit(e)
    e:damage(self.owner, self.dmg - e.defense)

    self.hit_hash[e] = true
    if self.effect then
        e:add_effect(self.effect)
    end

    if self.pushback_power then
        e:pushback(self.velocity:normalize()*self.pushback_power)
    end
end

return fireball
