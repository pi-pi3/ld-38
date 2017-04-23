
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
local iqm = require('iqm')
local cpml = require('cpml')
local anim9 = require('anim9')
local sword = require('sword')
local entity = require('entity')

local enemy = {}
setmetatable(enemy, {__index = entity})
local mt = {__index = enemy}

local max_vel = 2.5
local attack_delay = 2

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
    local self = entity.new(x, y, z, 'skeleton.iqm', nil, 'walking')
    setmetatable(self, mt)

    self.t = 'enemy'

    self.health = 12
    self.health_max = 12
    self.strength = 2
    self.power = 2
    self.agility = 3
    self.defense = 1

    self.state = 'idle'
    self.searching = {timer = 0,
                      rot = 0,
                      dst = {}}

    self.animation = 'none'
    self:stand()

    return self
end

function enemy:update(dt)
    local player = game.state.world.entities.player

    if self.state == 'idle' then 
        self:idle(dt, player)
    elseif self.state == 'searching' then 
        self:search(dt, player)
    elseif self.state == 'attacking' then 
        self:attack(dt, player)
    elseif self.state == 'fleeing' then 
        self:flee(dt, player)
    end

    entity.update(self, dt)
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
    self.animation = 'running'
end

function enemy:stand()
    self:walk()
    self.walking.playing = false
end

function enemy:idle(dt, player)
    local distance = cpml.vec3.dist2(player.position, self.position)

    if distance < 64.0 then
        self.state = 'searching' -- XXX Did I hear something?
        self.searching.timer = 0
        self.searching.rot = 0
        self.searching.dst = player.position
    end

    self.velocity = cpml.vec2(0, 0)
    self:stand()
end

function enemy:search(dt, player)
    local d = player.position - self.position
    local distance = cpml.vec3.len2(d)

    if distance > 64.0 then
        self.state = 'idle' -- XXX Must've been the wind.
        self.velocity = cpml.vec2(0, 0)
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
        local rot = select(2, v:to_polar())-math.pi*3/2

        rot = rot + self.searching.rot

        self.velocity = cpml.vec2(math.sin(rot), -math.cos(rot))
    end

    if self.health < self.health_max*0.25 then
        self.state = 'fleeing'
    end

    local d = self.velocity:normalize()
    self.rotation = select(2, d:to_polar())-math.pi*1/2
    self:walk()
end

function enemy:attack(dt, player)
    local d = player.position - self.position
    local distance = cpml.vec3.len2(d)
    d = d:normalize()

    if distance > 64.0 then
        self.state = 'idle' -- XXX He's too far, let's forget he exists.
        self.velocity = cpml.vec2(0, 0)
        self.attacking = false
    elseif distance > 6.25 then
        self.velocity = d*2 -- XXX GET HIM!

        self.rotation = select(2, cpml.vec2(d.x, d.y):to_polar())-math.pi*1/2
        self.attacking = player
        self:run()
    else
        if not self.sword and self.attack_timer > 3 then
            self.sword = sword.new(self)
            self.attack_timer = 0
        end

        self.velocity = cpml.vec2(0, 0)
        self.rotation = select(2, cpml.vec2(d.x, d.y):to_polar())-math.pi*1/2
        self:stand()
    end

    if self.health < self.health_max*0.25 then
        self.state = 'fleeing'
        self.attacking = false
    end
end

function enemy:flee(dt, player)
    local d = player.position - self.position
    local distance = cpml.vec3.len2(d)

    if distance > 64.0 then
        self.state = 'idle' -- XXX He's too far, let's forget he exists
        self.velocity = cpml.vec2(0, 0)
    else
        self.velocity = -d:normalize()*2 -- XXX RUN AWAY!

        self.rotation = select(2, cpml.vec2(d.x, d.y):to_polar())-math.pi*3/2
    end

    self:run()
end

return enemy

