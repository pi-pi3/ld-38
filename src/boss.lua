
--[[ boss.lua
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
local entity = require('entity')
local rect = require('rect')

local boss = {}
setmetatable(boss, {__index = entity})
local mt = {__index = boss}

local attack_delay = 0.666

function boss.new(x, y, z)
    local self = entity.new(x, y, z, 'ifrit.iqm', {'ifrit.tga'},
                            'idle', rect.new(0, 0, 1, 1))
    setmetatable(self, mt)

    self.t = 'boss'

    self.scale = cpml.vec3(2, 2, 2)

    self.health = 6666 -- The answer to life, the universe and everything.
    self.health_max = 6666
    self.strength = 666
    self.power = 666
    self.agility = 666
    self.defense = 666
    self.max_vel = 666

    return self
end

return boss
