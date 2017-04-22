
--[[ utils.lua A minimalistic util library useful for games.
    Copyright (c) 2017 Szymon "pi_pi3" Walter

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

local table = require('table')

local util = {}

-- declare a global variable
-- declare('x', 1)
function util.declare(name, val)
    rawset(_G, name, val or false)
end

-- this function makes implicit global declarations cause a runtime error
-- for safety reasons
-- and typos
-- it makes life easier
function util.init_G()
    setmetatable(_G, {
        __newindex = function (_, n)
            error("Write to undeclared variable " .. n, 2)
        end,
        __index = function (_, n)
            error("Read from undeclared variable " .. n, 2)
        end,
    })
end

-- usage:
-- x may or may not be nil
--  x = util.default(x, {some_default1, some_default2})
-- if x is not nil, this function returns x
-- if x is nil, it iterates over the table `def` until it finds a non-nil value
function util.default(var, def)
    if var ~= nil then
        return var
    else
        for k, v in pairs(def) do
            if v ~= nil then
                return v
            end
        end
    end
end

-- naive method, uses string concatenation
-- t = table
-- b = begin, i.e. {
-- e = end, i.e. }
-- sep = seperator, i.e. ,
-- recurse = (bool) should the function recurse?
function util.ttostr(t, b, e, sep, recurse)
    if not t then
        return nil
    end

    b = b or '{'
    e = e or '}'
    sep = sep or ', '
    recurse = (recurse ~= nil) and recurse or true

    local str = b
    for k, v in pairs(t) do
        if str ~= b then
            str = str .. sep
        end

        if type(k) == 'string' then
            str = str .. k .. ' = '
        end

        if type(v) == 'table' and recurse then
            str = str .. util.ttostr(v, b, e, sep)
        elseif type(v) == 'string' then
            str = str .. '"' .. v .. '"'
        else
            str = str .. tostring(v)
        end
    end

    str = str .. e

    return str
end

function util.cmp_table(t1, t2, recurse)
    for k, e1 in pairs(t1) do
        local e2 = t2[k]
        if recurse
            and type(e1) == 'table'
            and type(e2) == 'table' then
            if not util.cmp_table(e1, e2) then
                return false
            end
        else
            if e1 ~= e2 then
                return false
            end
        end
    end
    return true
end

-- deep (recursive) or shallow (non-recursive) copy
function util.copy(orig, recurse)
    local orig_type = type(orig)
    local copy

    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            local key = recurse and util.copy(orig_key) or orig_key
            local val = recurse and util.copy(orig_value) or orig_value
            copy[key] = val
        end
        setmetatable(copy, util.copy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end

    return copy
end

function util.sign(a)
    if a == 0 then return 0
    elseif a > 0 then return 1
    elseif a < 0 then return -1 end
end

-- clamp x into the range min-max
-- min and max may be nil for unbounded range on either side
function util.clamp(x, min, max)
    if min > max then
        min, max = max, min
    end

    if min == nil then
        if max == nil then
            return x
        else
            return math.min(x, max)
        end
    end

    if max == nil then
        return math.max(x, min)
    end

    return math.min(max, math.max(x, min))
end

-- turns the string.gmatch iterator into a table
function util.match(text, pattern)
    local out = {}
    for v in string.gmatch(text, pattern) do
        table.insert(out, v)
    end
    return out
end

-- returns true if a is between min and max (inclusive)
-- min and max may be nil for unbounded range on either side
function util.between(a, min, max)
    if max == nil and min == nil then
        return true
    elseif max == nil then
        return (a >= min)
    elseif min == nil then
        return (a <= max)
    end
    return (a >= min) and (a <= max)
end

-- returns true if a string ends with `sub`
function util.endswith(str, sub)
    return string.sub(str, #str-#sub+1, #str) == sub
end

function util.startswith(str, sub)
    return string.sub(str, 1, #sub) == sub
end

-- concatenates two tables with integer keys
function util.concat(a, b)
    local t = {}
    for i, v in ipairs(a) do
        t[i] = v
    end

    local len = #t

    for i, v in ipairs(b) do
        t[len+i] = v
    end

    return t
end

-- concatenates two tables with arbitrary keys
-- if both tables contain a key, the second table overrides the first
function util.join(a, b)
    local t = {}
    for k, v in ipairs(a) do
        t[k] = v
    end
    for k, v in ipairs(b) do
        t[k] = v
    end

    return t
end

-- maps fn to every element of t
-- fn should have the following signature:
--  function(key, value) <dostuff> end
function util.map(t, fn)
    local new = {}
    for k, v in pairs(t) do
        new[k] = fn(k, v)
    end
    return new
end

-- folds t from left
-- acc is not given a default value
-- fn should have the following signature:
--  function(key, value) <dostuff> end
function util.fold(t, fn, acc)
    for k, v in pairs(t) do
        acc = fn(acc, k, v)
    end

    return acc
end

-- filters the table t with a function fn
-- any value that passes the test is returned in a new function
-- fn should have the following signature:
--  function(key, value) <dostuff> end
function util.filter(t, fn)
    local new = {}
    for k, v in pairs(t) do
        if fn(k, v) then
            new[k] = v
        end
    end
    return new
end

-- maps fn to every key of t
-- fn should have the following signature:
--  function(key, value) <dostuff> end
function util.map_key(t, fn)
    local new = {}
    for k, v in pairs(t) do
        new[fn(k, v)] = v
    end
    return new
end

function util.vec2_len(a)
    return math.sqrt(a.x*a.x+a.y*a.y)
end

function util.vec3_len(a)
    return math.sqrt(a.x*a.x+a.y*a.y+a.z*a.z)
end

function util.vec2_dot(a, b)
    return a.x*b.x + a.y*b.y
end

function util.vec3_dot(a, b)
    return a.x*b.x + a.y*b.y + a.z*b.z
end

-- project an arbitrary 2d point `a` 
--   onto an axis `i` 
--   in relation to point `p`
function util.proj2(a, p, i)
    local v = {x = a.x-p.x, a.y-p.y}
    local r = util.vec2_len(v) * util.vec2_dot(v, i)
    return {x = p.x + r*i.x, p.y + r*i.y}
end

-- project an arbitrary 3d point `a` 
--   onto a plane x = r*`i` + s*`j`
--   in relation to point `p`
function util.proj3(a, p, i, j)
    local v = {x = a.x-p.x, y = a.y-p.y, z = a.z-p.z}
    local v_len = util.vec3_len(v)
    local r = v_len * util.vec3_dot(v, i)
    local s = v_len * util.vec3_dot(v, j)
    return {x = p.x + r*i.x + s*j.x,
            y = p.y + r*i.y + s*j.y,
            z = p.z + r*i.z + s*j.z}
end

return util
