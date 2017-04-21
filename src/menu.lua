
--[[ menu.lua
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

local lgui = require('lgui')

local menu = {}

function menu.load()
    menu.elements = {}

    table.insert(menu.elements, lgui.label(
        {
            text = "Ludum Dare game",
            color = {255, 255, 255},
            x = 0, y = 32,
            align = 'center',
        }))

    table.insert(menu.elements, lgui.button(
        {
            text = "Ludum",
            bgcolor = {255, 255, 255},
            downcolor = {191, 191, 191},
            x = love.graphics.getWidth()/2-80, y = 64,
            width = 64, height = 16,
            onClick = function() print('click') end,
            onRelease = function() print('noclick') end,
        }))

    table.insert(menu.elements, lgui.button(
        {
            text = "Dare",
            bgcolor = {255, 255, 255},
            x = love.graphics.getWidth()/2+16, y = 64,
            width = 64, height = 16,
            onHover = function() print('hover') end,
            onHold = function() print('hold') end,
        }))

    table.insert(menu.elements, lgui.slider(
        {
            color = {255, 255, 255},
            x = 16, y = 80,
            width = 64, height = 8,
        }))

    table.insert(menu.elements, lgui.slider(
        {
            color = {255, 255, 255},
            x = 16, y = 100,
            width = 64, height = 8,
            min = 0, max = 255,
            round = true,
            value = 127,
        }))

    table.insert(menu.elements, lgui.checkbox(
        {
            bgcolor = {255, 255, 255},
            x = 48, y = 120,
            width = 16, height = 16,
            value = false,
        }))

    table.insert(menu.elements, lgui.checkbox(
        {
            bgcolor = {255, 255, 255},
            x = 16, y = 120,
            width = 16, height = 16,
            value = true,
        }))

    table.insert(menu.elements, lgui.container(
        {
            bgcolor = {255, 255, 255},
            x = 100, y = 80,
            width = 96, height = 128,
            maxscroll = {x0 = -32, x1 = 32,
                         y0 = -32, y1 = 32},
            elements = {
                lgui.label(
                    {
                        text = "Dare to play?\n"..
                               "Just press \n"..
                               "the button...",
                        color = {0, 0, 0},
                        x = 0, y = 0,
                    }),
                lgui.button(
                    {
                        text = "Play",
                        textcolor = {255, 255, 255},
                        bgcolor = {64, 64, 64},
                        downcolor = {191, 191, 191},
                        x = 16, y = 64,
                        width = 64, height = 40,
                        onClick = function() print('play') end,
                        onRelease = function() print('noplay') end,
                    })
            },
        }))

    table.insert(menu.elements, lgui.textfield(
        {
            bgcolor = {255, 255, 255},
            x = 32, y = 256,
            width = 100, height = 64,
            text = 'type something...',
        }))

    table.insert(menu.elements, lgui.list(
        {
            bgcolor = {255, 255, 255},
            x = 150, y = 256,
            width = 80, height = 16,
            focus_height = 80,
            elements = {
                {key = "1st", value = 1},
                {key = "2nd", value = 2},
                {key = "3rd", value = 3},
                {key = "4th", value = 4},
                {key = "5th", value = 5},
                {key = "6th", value = 6},
                {key = "7th", value = 7},
                {key = "8th", value = 8},
                {key = "9th", value = 9},
            }
        }))
end

return menu
