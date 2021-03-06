
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

function entity.new(x, y, z, model, textures, anim, bbox)
    local self = {}
    setmetatable(self, mt)

    self.t = 'entity'

    self.velocity = cpml.vec3(0, 0, 0)
    self.position = cpml.vec3(x or 0, y or 0, z or 0)
    self.rotation = 0 -- z only
    self.scale = cpml.vec3(1, 1, 1)
    self.bbox = bbox
    self.gravity = true

    self.health = 5
    self.health_max = 5
    self.strength = 1
    self.power = 1
    self.agility = 1
    self.defense = 1

    self.effects = {}

    self.max_vel = 1
    self.timer = 0
    self.attack_timer = 0
    self.attacking = false
    self.weight = 2000.0
    self.stagger = 0

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

            self.model.anim:update(0)
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
    if not self:alive() then
        self:die()
    end

    if self.anim then
        self.model.anim:update(dt)
    end

    if self.health <= 0 then
        self:die()
    end

    self.timer = self.timer + dt
    self.attack_timer = self.attack_timer + dt
    if self.life then 
        self.life = self.life - dt
        if self.life < 0 then
            self.dying = false
            self:die()
        end
    end

    for k, eff in pairs(self.effects) do
        eff.life = eff.life - dt
        if eff.life <= 0 then
            self:remove_effect(eff, k)
        end
    end

    -- Update velocity
    if self.force then
        self.velocity.x = self.velocity.x + self.force.x*dt
        self.velocity.y = self.velocity.y + self.force.y*dt

        local fx = self.force.x
        local fy = self.force.y

        self.force.x = self.force.x + self.anti_force.x*self:stat('weight')*dt
        self.force.y = self.force.y + self.anti_force.y*self:stat('weight')*dt

        if util.sign(self.force.x) ~= util.sign(fx)
            or util.sign(self.force.y) ~= util.sign(fy) then
            self.force = nil
        end
    end

    -- Update position
    self.position.x, self.position.y = 
            self.position.x + self.velocity.x*dt,
            self.position.y + self.velocity.y*dt

    -- Gravity
    if self.gravity then
        if not self:on_ground() then
            self.falling = true
            self.velocity.z = self.velocity.z + game.state.world.gravity*dt
            self.position.z = self.position.z + self.velocity.z*dt

            if self.position.z < -80 then
                self:die()
            end
        end
    end
end

function entity:moveto(x, y)
    local pos
    if x and not y then
        pos = x
    else
        pos = cpml.vec2(x, y)
    end

    self.dest = pos
    self:lookat(pos)
end

function entity:lookat(x, y)
    local pos
    if x and not y then
        pos = x
    else
        pos = cpml.vec2(x, y)
    end

    local d = pos - cpml.vec2(self.position.x, self.position.y)
    local rot = select(2, d:to_polar())-math.pi*1.5
    self.rotation = rot
end

function entity:attack(enemy)
    self.attacking = enemy
end

function entity:dir()
    return cpml.vec2(math.sin(self.rotation), -math.cos(self.rotation))
end

function entity:pushback(v)
    self.velocity = cpml.vec3(0, 0, 0)
    self.force = v

    local t = 1000/self:stat('weight')
    self.anti_force = -self.force/(1000*t)
end

function entity:alive()
    return self:stat('health') > 0
end

function entity:die(t)
    if self.sound_death then
        self.sound_death:play()
    end

    if t then
        self.life = t
    elseif self.dying and not self.life then
        self.life = self.dying
    else
        self.health = -1
        game.state.world:remove(self)
    end
end

function entity:on_ground()
    local world = game.state.world

    local function p_on_ground(px, py, ox, oy)
        local world = world.world
        return world[py+oy] and world[py+oy][px+ox] and world[py+oy][px+ox] > 0
    end

    if self.falling then
        return false
    end

    local px, py = math.floor((self.position.x-world.offset.x)*0.5),
                   math.floor((self.position.y-world.offset.y)*0.5)

    local on_ground = p_on_ground(px, py, 0, 0)
                   or p_on_ground(px, py, self.bbox.w, 0)
                   or p_on_ground(px, py, 0, self.bbox.h)
                   or p_on_ground(px, py, self.bbox.w, self.bbox.h)

    return on_ground
end

function entity:stat(stat)
    local val = self[stat]
    
    for _, eff in pairs(self.effects) do
        if eff.t == 'effect.passive'
            and eff.stat_mod[stat] then
            val = val * eff.stat_mod[stat]
        end
    end

    return val
end

function entity:add_effect(eff)
    table.insert(self.effects, eff)
end

function entity:remove_effect(eff, key)
    if key then
        if type(key) == 'number' then
            table.remove(self.effects, key)
        else
            self.effects[key] = nil
        end
    else
        for k, eff1 in pairs(self.effects) do
            if eff == eff1 then
                if type(k) == 'number' then
                    table.remove(self.effects, k)
                else
                    self.effects[k] = nil
                end
            end
        end
    end
end

function entity:damage(owner, dmg)
    self.health = self.health - dmg
    if self.on_damage then
        self:on_damage(owner, dmg)
    end
end

return entity
