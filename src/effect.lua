
--[[ effect.lua
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

local effect = {}
local mt = {__index = effect}

function effect.passive(stat_mod, life)
    local self = {}

    self.t = 'effect.passive'
    self.stat_mod = stat_mod
    self.life = life

    return self
end

function effect.active(caster, func, life)
    local self = {}

    self.t = 'effect.active'
    self.caster = caster
    self.func = func
    self.life = life

    return self
end

function effect:update(e)
    self.func(self.caster, e)
end

return effect
