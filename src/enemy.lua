
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

local enemy = {}
local mt = {__index = enemy}

local acc = 15
local decc = 60
local max_vel = 100

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
    local self = {}
    setmetatable(self, mt)

    self.velocity = cpml.vec2(0, 0)
    self.position = cpml.vec3(x or 0, y or 0, z or 1)
    self.rotation = 0 -- z only

    self.health = 1000.0

    self.state = 'idle'
    self.search = {timer = 0,
                   rot = 0,
                   dst = {}}

    self.scale = cpml.vec3(1, 1, 1)
    self.model = iqm.load('assets/models/enemy.iqm')
    self.model.textures = {}

    return self
end

function enemy:draw()
    gfx.push()

    gfx.transform(self.position,
                  cpml.vec3(0, 0, self.rotation),
                  self.scale)
    gfx.draw(self.model)

    gfx.pop()
end

function enemy:update(dt)
    local player = game.state.entities.player

    if self.state == 'idle' then 
        self:idle(dt, player)
    elseif self.state == 'searching' then 
        self:search(dt, player)
    elseif self.state == 'attacking' then 
        self:attack(dt, player)
    elseif self.state == 'fleeing' then 
        self:flee(dt, player)
    end

    self.rotation = math.asin(self.velocity.x)
    if self.velocity.x > 0 then
        self.rotation = -self.rotation+math.pi
    end

    local vx = self.velocity.x*dt
    local vy = self.velocity.y*dt

    -- Update position
    self.position.x, self.position.y = 
            self.position.x + vx,
            self.position.y + vy
end

function enemy:idle(dt, player)
    local distance = cpml.vec3.dist2(player.position, self.position)

    if distance < 64.0 then
        self.state = 'searching' -- XXX Did I hear something?
        self.search.timer = 0
        self.search.rot = 0
        self.search.dst = player.position
    end

    self.velocity = cpml.vec2(0, 0)
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
        self.search.rot = math.sin(self.search.timer)
        self.search.timer = self.search.timer + dt

        if self.timer > 1.5 then -- Lookup player's position once every 1.5 seconds
            self.search.timer = self.search.timer
            self.search.dst = player.position
        end

        local v = d:normalize() -- XXX I think there's something there...
        local rot
        if v.y <= 0 then
            rot = math.asin(v.x)
        else
            rot = -math.asin(v.x)+math.pi
        end

        rot = rot + self.search.rot

        self.velocity = cpml.vec2(-math.sin(rot), -math.cos(rot))
    end
end

function enemy:attack(dt, player)
    local d = player.position - self.position
    local distance = cpml.vec3.len2(d)

    if distance > 64.0 then
        self.state = 'idle' -- XXX He's too far, let's forget he exists.
        self.velocity = cpml.vec2(0, 0)
    elseif distance > 6.25 then
        self.velocity = d:normalize()*2 -- XXX GET HIM!
    else
        -- attack
        self.velocity = cpml.vec2(0, 0)
    end

    if self.health < 100.0 then
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
    end
end

return enemy

