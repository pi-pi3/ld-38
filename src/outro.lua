
--[[ outro.lua
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
local ifrit = require('boss')

local outro = {}

local function text(text, owner)
    local pos = {}
    local camera = game.state.camera

    if owner == 'djinni' then
        --pos = util.copy(game.state.world.entities.player.position, false)
        --pos.z = pos.z + 2
        --pos = camera.proj * camera.view * pos
        pos.x = love.graphics.getWidth() / 2 - 128
        pos.y = love.graphics.getHeight() / 2 - 256
    elseif owner == 'ifrit' then
        --pos = util.copy(game.state.world.entities.boss.position, false)
        --pos.z = pos.z + 4
        --pos = camera.proj * camera.view * pos
        pos.x = love.graphics.getWidth() / 2 + 64
        pos.y = love.graphics.getHeight() / 2 - 256
    end

    game.state.speech.text = text
    game.state.speech.pos = pos
end

local function screenshake()
    game.state.screenshake = true
end

 local function sound(file)
    local source = love.audio.newSource('assets/sounds/' .. file, 'static')
    source:setLooping(false)
    source:play()
end

local function add_ifrit()
    local player = game.state.world.entities.player
    local pos = util.copy(player.position)
    local dir = player:dir()
    pos.x = pos.x + dir.x*4
    pos.y = pos.y + dir.y*4

    game.state.world.entities.boss = ifrit.new(pos.x, pos.y, pos.z)
    game.state.world.entities.boss.rotation = player.rotation+math.pi
end

local function remove_ifrit()
    game.state.world.entities.boss = nil
end

local function black()
    game.black = true
end

local function init(i)
    -- Sigh...
    -- I'm bored
    -- ... (screenshake)
    -- * muahahaha *
    -- * poof *
    -- (evil djinni)
    -- Now, you're mine!
    -- Come reach me!
    -- * poof *

    game.state.speech.text = nil
    game.state.screenshake = false

    if i == 1 then
        return true
    elseif i == 2 then
        screenshake()
        return true
    elseif i == 3 then
        add_ifrit()
        screenshake()
        return true
    elseif i == 4 then
        text('I\'ll get you!', 'djinni')
        return true
    elseif i == 5 then
        text('You know...', 'ifrit')
        return true
    elseif i == 6 then
        text('You and I are very alike, you know?', 'ifrit')
        sound('alike.ogg')
        return true
    elseif i == 7 then
        text('Noooo! This can\'t be true!', 'djinni')
        sound('nonono.ogg')
        return true
    elseif i == 8 then
        text('But then I thought to myself.', 'djinni')
        return true
    elseif i == 9 then
        black()
        sound('outro.ogg')
        return true
    end

    return false
end

return init
