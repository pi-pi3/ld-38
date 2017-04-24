
--[[ intro.lua
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

local intro = {}

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
    game.state.world.entities.boss = ifrit.new(5, 0, 2)
    game.state.world.entities.boss.rotation = -math.pi*0.5
end

local function remove_ifrit()
    game.state.world.entities.boss = nil
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
        text('Sigh...', 'djinni')
        return true
    elseif i == 2 then
        text('I\'m bored.', 'djinni')
        sound('bored.ogg')
        return true
    elseif i == 3 then
        screenshake()
        return true
    elseif i == 4 then
        sound('laugh.ogg')
        return true
    elseif i == 5 then
        add_ifrit()
        return true
    elseif i == 6 then
        text('Now you\'re mine!', 'ifrit')
        return true
    elseif i == 7 then
        text('Come reach me!', 'ifrit')
        return true
    elseif i == 8 then
        remove_ifrit()
        return true
    elseif i == 9 then
        text('...', 'djinni')
        return true
    elseif i == 10 then
        text('I have to find him, using my mouse.', 'djinni')
        return true
    elseif i == 11 then
        text('I can move with my left mouse button ' .. 
             'and cast magic with my right mouse button', 'djinni')
        return true
    elseif i == 12 then
        text('If I press an enemy with my left mouse button, ' .. 
             'I will attack him.', 'djinni')
        return true
    elseif i == 13 then
        text('I know two spells that I can use against my enemies. ' .. 
             'The Mighty Fireball and the Powerful Ice wave.', 'djinni')
        return true
    elseif i == 14 then
        text('The fireball deals high damage and can push enemies far.', 'djinni')
        return true
    elseif i == 15 then
        text('The ice wave deals lower damage, but can attack many enemies ' ..
             'simoultaneously and it slows them down.', 'djinni')
        return true
    elseif i == 16 then
        sound('come_catch_me.ogg')
    end

    return false
end

return init
