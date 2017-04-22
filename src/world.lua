
--[[ world.lua
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
local player = require('player')
local block = require('block')

local world = {}
local mt = {__index = world}

function world.gen(w, h)
    local self = {}
    setmetatable(self, mt)

    self.entities = {}
    self.entities.player = player.new()

    self.blocks = {}
    self.blocks[1] = block.new(1)

    self.world = {} -- rename this
    self.width = w
    self.height = h

    for i = 1, self.height do
        self.world[i] = {}
        for j = 1, self.width do
            self.world[i][j] = 1
        end
    end

    return self
end

function world:draw()
    for i = 1, self.height do
        local y = i*2-9
        for j = 1, self.width do
            local x = j*2-9
            local t = self.world[i][j]

            self.blocks[t]:draw(x, y)
        end
    end

    for _, e in pairs(self.entities) do
        if e.draw then
            e:draw()
        end
    end
end

return world
