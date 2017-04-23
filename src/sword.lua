
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

local sword = {}
local mt = {__index = sword}

local time = 0.75

function sword.new(owner, mult)
    local self = {}
    setmetatable(self, mt)

    self.t = 'sword'
    self.health = 1
    self.rotation = 0

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

    if not sword.model then
        sword.model = iqm.load('assets/models/sword.iqm')
        sword.model.textures = {}

        sword.model.textures.sword =
            love.graphics.newImage('assets/textures/sword.tga', {mipmaps = true})
        sword.model.textures.sword:setFilter('nearest', 'linear')
    end

    return self
end

function sword:draw()
    gfx.set_shader(shader_static)

    gfx.push()

    gfx.transform(self.owner.position+cpml.vec3(0, 0, 1.5),
                  cpml.vec3(0, 0, self.owner.rotation+self.rotation),
                  self.owner.scale)
    gfx.draw(sword.model)

    gfx.pop()
end

function sword:update(dt)
    if self.timer > time then
        self.health = 0
    end

    self.timer = self.timer + dt
    self.rotation = math.sin(self.timer*(math.pi/time)*0.5)

    if self.timer > math.pi*0.5 then
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

function sword:collision(e)
    local d = e.position - self.owner.position
    d = cpml.vec2(d.x, d.y)

    if d:len2() < self.radius2 then
        local v = self.owner:dir()
        local theta = math.pi-cpml.vec2.dot(d, v)

        return math.abs(theta-self.rotation) < math.pi*0.0625
    end
end

function sword:hit(e)
    e.health = e.health - (self.dmg - e.defense)
    if self.pushback then
        local d = e.position - self.owner.position
        e:pushback(d:normalize()*self.pushback)
    end
end

function sword:alive()
    return self.health > 0
end

return sword
