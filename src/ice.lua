
--[[ ice.lua
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
local fireball = require('fireball')
local effect = require('effect')

local ice = {}
setmetatable(ice, {__index = fireball})
local mt = {__index = ice}

local time = 0.75

local sound_ice = love.audio.newSource('assets/sounds/ice.ogg')
sound_ice:setLooping(false)

function ice.new(owner, mult, n, i)
    n = n or 5
    mult = mult or 1

    if n > 1 then
        local t = {}

        for i = 1, n do
            t[i] = ice.new(owner, mult, 1, i)
        end

        sound_ice:play()

        return t, n
    elseif n == 1 then
        local self = fireball.new(owner, mult*0.15, 'ice.iqm', {'ice.tga'}, true)
        setmetatable(self, mt)

        self.t = 'spell.ice'
        self.life = time

        local rot = math.pi*0.133*(i+0.5) - math.pi*0.5
        self.rotation = owner.rotation + rot

        self.max_vel = 40.0
        self.velocity = cpml.vec2(math.sin(self.rotation)*self:stat('max_vel'),
                                 -math.cos(self.rotation)*self:stat('max_vel'))

        if self.pushback_power then
            self.pushback_power = self.pushback_power*0.15
        end

        self.hits = 4
        self.dmg_falloff = 0.5
        self.effect = effect.passive({max_vel = 0.5}, 2)

        return self
    else
        error('ice.lua: ice.new(): n must be positive')
    end
end

function ice:hit(e)
    fireball.hit(self, e)

    if self.hits == 4 and self.pushback_power then
        e:pushback(self.velocity:normalize()*self.pushback_power)
    end
end

return ice
