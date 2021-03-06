
--[[ enemy.lua
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
local sword = require('sword')
local entity = require('entity')
local rect = require('rect')

local enemy = {}
setmetatable(enemy, {__index = entity})
local mt = {__index = enemy}

local attack_delay = 1

--[[ AI (simplified)
         found
          /escaped (proximity > 8)
 search <-----> attack     
                           
    ^             |-low    
    |-proximity   |  health
    |  < 8.0      v        
    v      |               
           |    flee       
   idle <---------|        
]]

function enemy.new(x, y, z)
    local self = entity.new(x, y, z, 'skeleton.iqm', {'skeleton.tga', 'lamp.tga'},
                            'standing', rect.new(0, 0, 1, 1))
    setmetatable(self, mt)

    self.t = 'enemy'

    self.health = 12
    self.health_max = 12
    self.strength = 6
    self.power = 10
    self.agility = 7
    self.defense = 2
    self.max_vel = 2.5

    self.dying = 30
    self.follow = false
    self.state = 'idle'
    self.searching = {timer = 0,
                      rot = 0,
                      dst = {}}

    self.animation = 'none'
    self:stand()

    self.sound_death = love.audio.newSource('assets/sounds/skeleton_death.ogg')

    return self
end

function enemy:update(dt)
    local player = game.state.world.entities.player

    if not self.falling then
        if self.state == 'idle' then 
            self:idle(dt, player)
        elseif self.state == 'searching' then 
            self:search(dt, player)
        elseif self.state == 'attacking' then 
            self:attack(dt, player)
        elseif self.state == 'fleeing' then 
            self:flee(dt, player)
        end
    end

    if self.sword then
        self.sword:update(dt)
        if not self.sword:alive() then
            self.sword = nil
        end
    end

    entity.update(self, dt)
end

function enemy:draw()
    if self.sword then
        self.sword:draw()
    end

    entity.draw(self)
end

function enemy:walk()
    if self.animation ~= 'walking' then
        self.walking = self.model.anim:add_track('walking')
        self.walking.playing = true
    end

    if self.animation == 'running' then
        self.model.anim:remove_track(self.running)
        self.running.playing = false
    end

    if self.animation == 'standing' then
        self.model.anim:remove_track(self.standing)
        self.standing.playing = false
    end
    self.animation = 'walking'
end

function enemy:run()
    if self.animation ~= 'running' then
        self.running = self.model.anim:add_track('running')
        self.running.playing = true
    end

    if self.animation == 'walking' then
        self.model.anim:remove_track(self.walking)
        self.walking.playing = false
    end

    if self.animation == 'standing' then
        self.model.anim:remove_track(self.standing)
        self.standing.playing = false
    end
    self.animation = 'running'
end

function enemy:stand()
    if self.animation ~= 'standing' then
        self.standing = self.model.anim:add_track('standing')
        self.standing.playing = true
    end

    if self.animation == 'running' then
        self.model.anim:remove_track(self.running)
        self.running.playing = false
    end

    if self.animation == 'walking' then
        self.model.anim:remove_track(self.walking)
        self.walking.playing = false
    end
    self.animation = 'standing'
end

-- Sword animation
function enemy:slash()
    self.slashing = self.model.anim:add_track('attacking', 1.0)
    self.slashing.playing = true
end

function enemy:idle(dt, player)
    local distance = cpml.vec3.dist2(player.position, self.position)

    if distance < 64.0 then
        self.state = 'searching' -- XXX Did I hear something?
        self.searching.timer = 0
        self.searching.rot = 0
        self.searching.dst = player.position
    end

    self.velocity = cpml.vec3(0, 0)
    self:stand()
end

function enemy:search(dt, player)
    local d = player.position - self.position
    local distance = cpml.vec3.len2(d)

    if distance > 64.0 and not self.follow then
        self.state = 'idle' -- XXX Must've been the wind.
        self.velocity = cpml.vec3(0, 0)
    elseif distance < 16.0 then
        self.state = 'attacking'
    else -- Walk into players general direction
        self.searching.rot = math.sin(self.searching.timer)
        self.searching.timer = self.searching.timer + dt

        -- Lookup player's position once every 1.5 seconds
        if self.searching.timer > 1.5 then
            self.searching.timer = self.searching.timer
            self.searching.dst = player.position
        end

        local v = cpml.vec2(d.x, d.y) -- XXX I think there's something there...
        local rot = select(2, v:to_polar())-math.pi*1.5

        rot = rot + self.searching.rot

        self.velocity = cpml.vec3(math.sin(rot), -math.cos(rot))*self:stat('max_vel')

        self.rotation = rot
        self:walk()
    end

    if self:stat('health') < self.health_max*0.25 then
        self.state = 'fleeing'
    end
end

function enemy:attack(dt, player)
    local d = player.position - self.position
    local distance = cpml.vec3.len2(d)
    d = d:normalize()

    if distance > 64.0 and not self.follow then
        self.state = 'idle' -- XXX He's too far, let's forget he exists.
        self.velocity = cpml.vec3(0, 0)
        self.attacking = false
    elseif distance > 6.25 then
        self.velocity = d*self:stat('max_vel')*2 -- XXX GET HIM!

        self.rotation = select(2, cpml.vec2(d.x, d.y):to_polar())+math.pi*0.5
        self.attacking = player
        self:run()
    else
        if self.attack_timer > attack_delay then
            self.sword = sword.new(self)
            self.attack_timer = 0
            self:slash()
        else
            self:stand()
        end

        self.velocity = cpml.vec3(0, 0)
        self.rotation = select(2, cpml.vec2(d.x, d.y):to_polar())+math.pi*0.5
    end

    if self:stat('health') < self.health_max*0.25 then
        self.state = 'fleeing'
        self.attacking = false
    end
end

function enemy:flee(dt, player)
    local d = player.position - self.position
    local distance = cpml.vec3.len2(d)

    if distance > 64.0 and not self.follow then
        self.state = 'idle' -- XXX He's too far, let's forget he exists
        self.velocity = cpml.vec3(0, 0)
    else
        self.velocity = -d:normalize()*self:stat('max_vel')*2 -- XXX RUN AWAY!

        self.rotation = select(2, cpml.vec2(d.x, d.y):to_polar())+math.pi*1.5
    end

    self:run()
end

function enemy:on_damage(owner, dmg)
    if dmg < self:stat('health_max') * 0.5 then
        self.state = 'attacking'
        self.attacking = owner
        self.follow = true
    else
        self.stagger = 2
    end
end

return enemy

