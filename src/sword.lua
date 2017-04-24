
--[[ sword.lua
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
local iqm = require('iqm')
local fireball = require('fireball')
local anim9 = require('anim9')

local sword = {}
setmetatable(sword, {__index = fireball})
local mt = {__index = sword}

local time = 16/30

function sword.new(owner, mult, model, textures)
    model = model or 'sword.iqm'
    textures = textures or {'sword.tga'}

    local self = fireball.new(owner, mult, model, textures)
    setmetatable(self, mt)

    self.t = 'spell.sword'
    self.life = time

    self.rotation = owner.rotation

    self.max_vel = 0.0
    self.velocity = cpml.vec2(0, 0)

    self.hits = 256
    self.dmg_falloff = 0.8

    self.model.anims = iqm.load_anims('assets/models/' .. model)
    assert(self.model.anims)

    self.model.anim = anim9(self.model.anims)
    assert(self.model.anim)

    self.anim = self.model.anim:add_track('slashing')
    self.anim.playing = true

    self.model.anim:update(0)

    return self
end

function sword:update(dt)
    fireball.update(self, dt)
    self.position = self.owner.position
end

function sword:collision(e)
    local d = e.position - self.owner.position
    d = cpml.vec2(d.x, d.y)

    if d:len2() < self.radius2 then
        local v = self.owner:dir()
        local theta = math.pi-cpml.vec2.dot(d, v)

        return math.abs(theta-self.rotation) < math.pi*0.0625
    end
end

return sword
