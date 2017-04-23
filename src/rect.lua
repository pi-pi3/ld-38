
--[[ rect.lua
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

-- Thanks a lot, Egor!

local rect = {}
local mt = {__index = rect}

function rect.new(x, y, w, h)
    local self = {}
    setmetatable(self, mt)

    self.x = x or 0
    self.y = y or 0
    self.w = w or 0
    self.h = h or 0

    return self
end

function rect:move(v)
    self.x = self.x + v.x
    self.y = self.y + v.y
end

function rect:moveto(p)
    self.x = p.x
    self.y = p.y
end

function rect:intersects(r)
    if r == nil then
        return false
    end

    -- return true if any point of self is inside r
    return (self.x >= r.x and self.x <= r.x + r.w                       -- p1
        and self.y >= r.y and self.y <= r.y + r.h)
        or (self.x + self.w >= r.x and self.x + self.w <= r.x + r.w     -- p2
        and self.y >= r.y and self.y <= r.y + r.h)
        or (self.x + self.w >= r.x and self.x + self.w <= r.x + r.w     -- p3
        and self.y + self.h >= r.y and self.y + self.h <= r.y + r.h)    
        or (self.x >= r.x and self.x <= r.x + r.w                       -- p4
        and self.y + self.h >= r.y and self.y + self.h <= r.y + r.h)
end

return rect
