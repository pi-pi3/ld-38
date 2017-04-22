
--[[ block.lua
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

local block = {}
local mt = {__index = block}

function block.new(block_type)
    block_type = block_type or 1

    local self = {}
    setmetatable(self, mt)

    if block_type == 1 then
        self.model = iqm.load('assets/models/block.iqm')
        self.model.textures = {
            Materialblock = love.graphics.newImage('assets/textures/block.tga',
                                                   {mipmaps = true})
        }
    end

    return self
end

function block:draw(x, y, z)
    local pos
    if x and not y and not z then
        pos = x
    else
        pos = cpml.vec3(x or 0, y or 0, z or 0)
    end

    gfx.push()

    gfx.transform(pos)
    gfx.draw(self.model)

    gfx.pop()
end

return block
