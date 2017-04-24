
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
local enemy = require('enemy')
local block = require('block')

local world = {}
local mt = {__index = world}

function world.gen(w, h)
    local self = {}
    setmetatable(self, mt)

    self.entities = {}
    self.entities.player = player.new(0, 0, 2)

    self:insert(enemy.new(8, 8, 2))

    self.blocks = {}
    self.blocks[1] = block.new(1)

    self.world = {{1, 1}, {1, 1}} -- rename this
    self.scale = {x = 2, y = 2}
    self.offset = {x = -w-1, y = -h-1}
    self.width = w
    self.height = h
    self.flag_stop = false

    self.gravity = -100

    self.world = self:genpatch(w, h, w*h*0.8, 3)

    return self
end

function world:expand(w, h, n, s)
    w = w or 8
    h = h or 8

    -- Pick a random row, then pick either edge
    local row = math.random(1, self.height)
    local side = math.random(0, 1)
    local column = side * (self.height - 1) + 1
    -- If there's space at that point, find a block
    local found = false

    for i = row, self.height do
        if found then break end
        for j = column, self.width do
            if self.world[i][j] > 0 then
                row = i
                column = j
                found = true
                break
            end
        end
    end

    local patch = world:genpatch(w, h, n, s)
    -- Anchor
    local i , j = math.random(1, h), math.random(1, w)

    -- If there's space at anchor, find a block
    local found = false
    for i1 = row, h do
        if found then break end
        for j1 = column, h do
            if patch[i1][j1] > 0 then
                i = i1
                j = j1
                found = true
                break
            end
        end
    end

    local x0, y0 = w - j - column + 1,
                   h - i - row + 1
    local x1, y1 = w - j - (self.width - column),
                   h - i - (self.height - row)

    self.world = self:rebuild(x0, y0, x1, y1)

    local off_x, off_y = 0, 0
    if x0 < 0 then
        off_x = self.width - (w - x1 + 1)
    end
    if y0 < 0 then
        off_y = self.height - (h - y1 + 1)
    end
    self:attach(patch, off_x, off_y)
end

function world:attach(patch, off_x, off_y)
    print(off_x, off_y)
    for i = 1, #patch do
        for j = 1, #patch[i] do
            local old_i = i+off_y
            local old_j = j+off_x
            if self.world[old_i] 
                and self.world[old_i][old_j]
                and self.world[old_i][old_j] == 0 then
                self.world[old_i][old_j] = patch[i][j]
            end
        end
    end
end

function world:rebuild(x0, y0, x1, y1)
    x0, y0 = math.max(x0, 0), math.max(y0, 0)
    x1, y1 = math.max(x1, 0), math.max(y1, 0)

    local w, h = self.width+x1+x0, self.height+y1+y0

    if x0 == 0 and y0 == 0 and x1 == 0 and y1 == 0 then
        return self.world
    end

    assert(w > self.width
        or h > self.height)

    self.width, self.height = w, h
    self.offset.x = self.offset.x - x0*self.scale.x
    self.offset.y = self.offset.y - y0*self.scale.y

    local new = {}

    for i = 1, h do
        new[i] = {}
        for j = 1, w do
            local old_i = i-y0
            local old_j = j-x0
            new[i][j] = self.world[old_i] and self.world[old_i][old_j] or 0
        end
    end

    return new
end

-- This function won't actually generate n blocks
function world:genpatch(w, h, n, s)
    local new = {}
    local p = n/(w*h)

    for i = 1, h do
        new[i] = {}
        for j = 1, w do
            if math.random() < p then
                new[i][j] = 1
            else
                new[i][j] = 0
            end
        end
    end

    local back
    for i = 1, s do
        -- Step cellular automaton
        back = world:step(new)
        -- Swap buffers
        back, new = new, back
    end

    return new
end

function world:step(front)
    local function neighbours(b, i, j)
        local c = 0
        c = c + ((b[i-1] and b[i-1][j-1] and b[i-1][j-1] > 0) and 1 or 0)
        c = c + ((b[i-1] and b[i-1][j]   and b[i-1][j]   > 0) and 1 or 0)
        c = c + ((b[i-1] and b[i-1][j+1] and b[i-1][j+1] > 0) and 1 or 0)

        c = c + ((b[i]   and b[i][j-1]   and b[i][j-1] > 0) and 1 or 0)
        c = c + ((b[i]   and b[i][j+1]   and b[i][j+1] > 0) and 1 or 0)

        c = c + ((b[i+1] and b[i+1][j-1] and b[i+1][j-1] > 0) and 1 or 0)
        c = c + ((b[i+1] and b[i+1][j]   and b[i+1][j]   > 0) and 1 or 0)
        c = c + ((b[i+1] and b[i+1][j+1] and b[i+1][j+1] > 0) and 1 or 0)

        return c
    end

    local function gencolor(b, i, j)
        local c = {}

        for i = i-1, i+1 do
            local n = b[i] and b[i][j]
            if n then
                c[n] = (c[n] or 0) + ((n and n > 0) and 1 or 0)
            end
        end

        local color, count = 0, 0
        for col, n in pairs(c) do
            if n > count then
                color, count = col, n
            end
        end

        return color
    end

    local back = {}

    -- Rule:
    --  every living cell with 5 or more neighbours survives
    --  every dead cell with 7 or more neighbours gets populated
    for i = 1, #front do
        back[i] = {}
        for j = 1, #front[i] do
            local n = neighbours(front, i, j)

            if front[i][j] > 0 then
                if n < 5 then
                    back[i][j] = 0
                else
                    back[i][j] = front[i][j]
                end
            elseif n >= 7 then
                back[i][j] = gencolor(front, i, j)
            else
                back[i][j] = 0
            end
        end
    end

    return back
end

function world:update(dt)
    for k, e in pairs(self.entities) do
        if e.update then
            e:update(dt)
        end
    end

    if self.flag_stop then
        game.state = require('gameover')
        game.state.load()
    end
end

function world:draw()
    for i = 1, self.height do
        local y = i*self.scale.y+self.offset.y
        for j = 1, self.width do
            local x = j*self.scale.x+self.offset.x
            local t = self.world[i][j]

            if t > 0 then
                self.blocks[t]:draw(x, y)
            end
        end
    end

    for _, e in pairs(self.entities) do
        if e.draw then
            e:draw()
        end
    end
end

function world:mousepressed(mx, my, button)
    self.entities.player:mousepressed(mx, my, button)

    if button == 3 then -- DEBUG
        self:expand(12, 12, 144*.9, 3)
    end
end

function world:nearest(pos, incl_player)
    local near

    for k, e in pairs(self.entities) do
        if (incl_player and k == player)
            or k ~= player then

            local d = (e.position-pos):len2()
            if not near or d < near.d then
                near = {e = e, d = d}
            end
        end
    end

    return near.e, math.sqrt(near.d)
end

function world:insert(e, n)
    if n then
        for i = 1, n do 
            world:insert(e[i])
        end
    else
        table.insert(self.entities, e)
    end
end

function world:remove(e, n)
    if n then
        for i = 1, n do 
            world:remove(e[i])
        end
    else
        if type(e) == 'number' then
            table.remove(self.entities, e)
            return
        end

        if type(e) == 'string' then
            table[e] = nil
            return
        end

        for k, v in pairs(self.entities) do
            if v == e then
                if type(k) == 'number' then
                    table.remove(self.entities, k)
                else
                    self.entities[k] = nil
                end
            end
        end
    end
end

return world
