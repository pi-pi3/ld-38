
--[[ entity.lua
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

local entity = {}
local mt = {__index = entity}

-- TODO: some of these might have to be per-entity, not per-type
local acc = 150
local decc = 600
local max_vel = 6
local attack_delay = 2

function entity.new(x, y, z, model, textures, anim)
    local self = {}
    setmetatable(self, mt)

    self.t = 'entity'

    self.velocity = cpml.vec2(0, 0)
    self.position = cpml.vec3(x or 0, y or 0, z or 0)
    self.rotation = 0 -- z only
    self.scale = cpml.vec3(1, 1, 1)

    self.health = 5
    self.health_max = 5
    self.strength = 1
    self.power = 1
    self.agility = 1
    self.defense = 1

    self.timer = 0
    self.attack_timer = attack_delay
    self.attacking = false

    self.anim = false

    if model then
        self.model = iqm.load('assets/models/' .. model)
        assert(self.model)

        if textures then
            self.model.textures = {}
            for _, t in pairs(textures) do
                self.model.textures[t] =
                    love.graphics.newImage('assets/textures/' .. t, {mipmaps = true})
                assert(self.model.textures[t])

                self.model.textures[t]:setFilter('nearest', 'nearest')
            end
        end

        if anim then
            self.model.anims = iqm.load_anims('assets/models/' .. model)
            assert(self.model.anims)

            self.model.anim = anim9(self.model.anims)
            assert(self.model.anim)

            self.anim = self.model.anim:add_track(anim)
            self.anim.playing = true
        end
    end

    return self
end

function entity:draw()
    if not self.model then
        return
    end

    if self.anim then
        gfx.set_shader(shader_anim)
    else
        gfx.set_shader(shader_static)
    end

    gfx.push()

    gfx.transform(self.position,
                  cpml.vec3(0, 0, self.rotation),
                  self.scale)
    gfx.draw(self.model)

    gfx.pop()
end

function entity:update(dt)
    if self.health <= 0 then
        game.state.world:remove(self)
    end

    if self.anim then
        self.model.anim:update(dt)
    end

    self.timer = self.timer + dt
    self.attack_timer = self.attack_timer + dt

    -- Update velocity
    if self.force then
        self.velocity.x = self.velocity.x + self.force.x*dt
        self.velocity.y = self.velocity.y + self.force.y*dt
    end

    -- Update position
    self.position.x, self.position.y = 
            self.position.x + self.velocity.x*dt,
            self.position.y + self.velocity.y*dt
end

function entity:moveto(x, y)
    local pos
    if x and not y then
        pos = x
    else
        pos = cpml.vec2(x, y)
    end

    self.dest = pos
end

function entity:attack(enemy)
    self.attacking = enemy
end

function entity:dir()
    return cpml.vec2(math.sin(self.rotation), -math.cos(self.rotation))
end

function entity:pushback(v)
    self.velocity = cpml.vec2(0, 0)
    self.force = v
end

return entity
