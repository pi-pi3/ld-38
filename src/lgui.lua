
--[[ lgui.lua A minimalistic GUI library useful for games.
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

local math = require('math')
local util = require('util')

local lgui = {}

function lgui.label(prot)
    prot = prot or {}

    local label = {}
    -- these 3 variables are needed by the label.height or condition
    local font = prot.font or love.graphics.getFont()
    local text = prot.text or ''
    local width = prot.width or love.graphics.getWidth()

    label.t = 'label'
    label.active = true
    label.pause = false

    label.x = prot.x
    label.y = prot.y
    label.width = prot.width or love.graphics.getWidth()
    label.height = prot.height or select(1, font:getWrap(text, width))

    label.text = prot.text or ''
    label.align = prot.align or 'left'
    label.font = prot.font or love.graphics.getFont()
    label.color = prot.color

    label.onClick = prot.onClick
    label.onRelease = prot.onRelease
    label.onHover = prot.onHover
    label.onHold = prot.onHold

    label.draw = prot.draw or lgui.draw_label

    return label
end

function lgui.image(prot)
    prot = prot or {}

    local image = {}

    image.t = 'image'
    image.active = true
    image.pause = false

    image.x = prot.x
    image.y = prot.y
    image.width = prot.width or img.getWidth()
    image.height = prot.height or img.getHeight()

    image.img = prot.img
    image.r = prot.r or 0
    image.quad = love.graphics.newQuad(0, 0, image.width, image.height,
                                       img.getWidth(), img.getHeight())

    image.onClick = prot.onClick
    image.onRelease = prot.onRelease
    image.onHover = prot.onHover
    image.onHold = prot.onHold

    image.draw = prot.draw or lgui.draw_image

    return image
end

function lgui.button(prot)
    prot = prot or {}

    local button = {}

    button.t = 'button'
    button.active = true
    button.pause = false

    button.x = prot.x
    button.y = prot.y
    button.width = prot.width
    button.height = prot.height

    button.text = prot.text
    button.align = prot.align or 'center'
    button.font = prot.font or love.graphics.getFont()
    button.bgcolor = prot.bgcolor
    button.downcolor = prot.downcolor
                        or {button.bgcolor[1]/2,
                            button.bgcolor[2]/2,
                            button.bgcolor[3]/2}
    button.framecolor = prot.framecolor
                        or {255-button.bgcolor[1],
                            255-button.bgcolor[2],
                            255-button.bgcolor[3]}
    button.textcolor = prot.textcolor or button.framecolor
    button.line_width=  prot.line_width or 1

    button.down = false

    button.onClick = prot.onClick
    button.onRelease = prot.onRelease
    button.onHover = prot.onHover
    button.onHold = prot.onHold

    button.draw = prot.draw or lgui.draw_button

    return button
end

function lgui.slider(prot)
    prot = prot or {}

    local slider = {}

    slider.t = 'slider'
    slider.active = true
    slider.pause = false

    slider.x = prot.x
    slider.y = prot.y
    slider.width = prot.width
    slider.height = prot.height

    slider.color = prot.color or {0, 0, 0}
    slider.textcolor = prot.textcolor
                        or {255-slider.color[1],
                            255-slider.color[2],
                            255-slider.color[3]}
    slider.line_width = prot.line_width or 1

    slider.min = prot.min or 0
    slider.max = prot.max or 1
    slider.value = prot.value or slider.min
    slider.round = prot.round or false
    slider.slider_width = prot.slider_width or slider.height
    slider.down = false

    slider.onClick = prot.onClick
    slider.onRelease = prot.onRelease
    slider.onHover = prot.onHover
    slider.onHold = prot.onHold

    slider.mid = {0, slider.height/2, slider.width, slider.height/2}

    local sw, sh = slider.slider_width, slider.slider_width
    slider.slider = love.graphics.newMesh(
                        {{-sw/2, 0},
                         {0, sh/2},
                         {sw/2, 0},
                         {0, -sh/2}})

    slider.draw = prot.draw or lgui.draw_slider
    slider.update = lgui.update_slider

    return slider
end

function lgui.checkbox(prot)
    prot = prot or {}

    local checkbox = {}

    checkbox.t = 'checkbox'
    checkbox.active = true
    checkbox.pause = false

    checkbox.x = prot.x
    checkbox.y = prot.y
    checkbox.width = prot.width
    checkbox.height = prot.height

    checkbox.bgcolor = prot.bgcolor
    checkbox.framecolor = prot.framecolor
                        or {255-checkbox.bgcolor[1],
                            255-checkbox.bgcolor[2],
                            255-checkbox.bgcolor[3]}
    checkbox.line_width = prot.line_width or 1

    checkbox.value = prot.value or false

    checkbox.onClick = prot.onClick
    checkbox.onRelease = prot.onRelease
    checkbox.onHover = prot.onHover
    checkbox.onHold = prot.onHold

    checkbox.draw = prot.draw or lgui.draw_checkbox

    return checkbox
end

function lgui.container(prot)
    prot = prot or {}

    local container = {}

    container.t = 'container'
    container.active = true
    container.pause = false

    container.x = prot.x
    container.y = prot.y
    container.width = prot.width
    container.height = prot.height

    container.elements = prot.elements or {}
    container.bgcolor = prot.bgcolor
    container.framecolor = prot.framecolor
                        or {255-container.bgcolor[1],
                            255-container.bgcolor[2],
                            255-container.bgcolor[3]}
    container.line_width = prot.line_width or 1

    container.scroll = {x = 0, y = 0}
    container.maxscroll = prot.maxscroll or {x0 = 0, y0 = 0, x1 = 0, y1 = 0}
    container.down = false

    container.onClick = prot.onClick
    container.onRelease = prot.onRelease
    container.onHover = prot.onHover
    container.onHold = prot.onHold

    container.draw = prot.draw or lgui.draw_container
    container.update = lgui.update_container

    return container
end

function lgui.textfield(prot)
    prot = prot or {}

    local textfield = {}

    textfield.t = 'textfield'
    textfield.active = true
    textfield.pause = false

    textfield.x = prot.x
    textfield.y = prot.y
    textfield.width = prot.width
    textfield.height = prot.height

    textfield.font = prot.font or love.graphics.getFont()
    textfield.text = prot.text or ''
    textfield.editable = (prot.editable ~= nil) and prot.editable or true
    textfield.focus = false
    textfield.bgcolor = prot.bgcolor
    textfield.framecolor = prot.framecolor
                        or {255-textfield.bgcolor[1],
                            255-textfield.bgcolor[2],
                            255-textfield.bgcolor[3]}
    textfield.textcolor = prot.textcolor or textfield.framecolor
    textfield.line_width = prot.line_width or 1

    textfield.onClick = prot.onClick
    textfield.onRelease = prot.onRelease
    textfield.onHover = prot.onHover
    textfield.onHold = prot.onHold

    textfield.draw = prot.draw or lgui.draw_textfield

    return textfield
end

function lgui.list(prot)
    prot = prot or {}

    local list = {}

    list.t = 'list'
    list.active = true
    list.pause = false

    list.x = prot.x
    list.y = prot.y
    list.width = prot.width
    list.height = prot.height

    list.elements = prot.elements or {}
    list.selection = list.elements[1]

    list.font = prot.font or love.graphics.getFont()
    list.bgcolor = prot.bgcolor
    list.framecolor = prot.framecolor
                        or {255-list.bgcolor[1],
                            255-list.bgcolor[2],
                            255-list.bgcolor[3]}
    list.textcolor = prot.textcolor or list.framecolor
    list.selcolor = prot.selcolor
                        or {list.bgcolor[1]/2,
                            list.bgcolor[2]/2,
                            list.bgcolor[3]/2}
    list.line_width = prot.line_width or 1

    list.focus_height = prot.focus_height
    list.toggle = false
    list.down = false
    list.scroll = 0
    list.maxscroll = prot.maxscroll or {0, 0}

    list.onClick = prot.onClick
    list.onRelease = prot.onRelease
    list.onHover = prot.onHover
    list.onHold = prot.onHold

    list.draw = prot.draw or lgui.draw_list

    return list
end

function lgui.printf(e, text, font, color, vcenter, align)
    if not e.text or text then
        return
    end

    font = font or e.font or love.graphics.getFont()
    color = color or e.textcolor or e.color
    align = align or e.align or 'left'
    text = text or e.text

    local y
    if vcenter then
        local _, wrap = font:getWrap(e.text, e.width)
        local height = font:getHeight() * #wrap
        y = e.y + e.height/2 - height/2
    else
        y = e.y
    end

    love.graphics.setFont(font)
    love.graphics.setColor(color)
    love.graphics.printf(e.text, e.x, y, e.width, align)
end

function lgui.draw_label(self)
    lgui.printf(self)
end

function lgui.draw_image(self)
    love.graphics.draw(self.img, self.quad, self.x, self.y, self.r)
end

function lgui.draw_button(self)
    if self.down then
        love.graphics.setColor(self.downcolor)
    else
        love.graphics.setColor(self.bgcolor)
    end
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

    love.graphics.setColor(self.framecolor)
    love.graphics.setLineStyle('smooth')
    love.graphics.setLineWidth(self.line_width)

    lgui.printf(self, nil, nil, nil, true, nil)
end

function lgui.draw_slider(self)
    love.graphics.setColor(self.color)
    love.graphics.setLineStyle('smooth')
    love.graphics.setLineWidth(self.line_width)
    love.graphics.translate(self.x, self.y)
    love.graphics.line(self.mid)
    love.graphics.translate(-self.x, -self.y)

    local sx, sy = self.x + ((self.value-self.min)/(self.max-self.min))
                   * self.width,
                   self.y + self.height/2

    love.graphics.draw(self.slider, sx, sy)

    local v = math.floor(self.value*100)/100
    love.graphics.printf(tostring(v), self.x, self.y+self.height/2,
                         self.width, 'center')
end

function lgui.draw_checkbox(self)
    love.graphics.setColor(self.bgcolor)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

    love.graphics.setColor(self.framecolor)
    love.graphics.setLineStyle('smooth')
    love.graphics.setLineWidth(self.line_width)

    love.graphics.rectangle('line', self.x, self.y, self.width, self.height)

    if self.value then
        love.graphics.line(self.x, self.y,
                           self.x+self.width, self.y+self.height)
        love.graphics.line(self.x+self.width, self.y,
                           self.x, self.y+self.height)
    end
end

function lgui.draw_container(self)
    local function draw_stencil()
        love.graphics.rectangle('fill', self.x, self.y,
                                self.width, self.height)
    end

    love.graphics.setColor(self.bgcolor)
    love.graphics.rectangle('fill', self.x, self.y,
                            self.width, self.height)

    love.graphics.setColor(self.framecolor)
    love.graphics.setLineStyle('smooth')
    love.graphics.setLineWidth(self.line_width)
    love.graphics.rectangle('line', self.x, self.y,
                            self.width, self.height)

    love.graphics.stencil(draw_stencil)

    love.graphics.translate(self.x + self.scroll.x, self.y + self.scroll.y)

    love.graphics.setStencilTest('greater', 0)
    lgui.drawall(self.elements)
    love.graphics.setStencilTest()

    love.graphics.translate(-(self.x + self.scroll.x), -(self.x + self.scroll.y))
end

function lgui.draw_textfield(self)
    local function draw_stencil()
        love.graphics.rectangle('fill', self.x, self.y,
                                self.width, self.height)
    end

    love.graphics.setColor(self.bgcolor)
    love.graphics.rectangle('fill', self.x, self.y,
                            self.width, self.height)

    love.graphics.setColor(self.framecolor)
    love.graphics.setLineStyle('smooth')
    love.graphics.setLineWidth(self.line_width)
    love.graphics.rectangle('line', self.x, self.y,
                            self.width, self.height)

    love.graphics.stencil(draw_stencil)

    love.graphics.setStencilTest('greater', 0)
    local text = self.text
    if self.focus then
        text = text .. '|'
    end

    local offset = self.font:getWidth('|') -- arbitrary offset to make
                                           -- textfields more pleasant to read

    lgui.printf({text = text, x = self.x+offset, y = self.y+offset,
                width = self.width, height = self.height,
                font = self.font, color = self.textcolor})

    love.graphics.setStencilTest()
end

function lgui.draw_list(self)
    local offset = self.font:getWidth('|') -- arbitrary offset to make
                                           -- textfields more pleasant to read

    if self.toggle then
        local function draw_stencil()
            love.graphics.rectangle('fill', self.x, self.y,
                                    self.width, self.focus_height)
        end

        love.graphics.setColor(self.bgcolor)
        love.graphics.rectangle('fill', self.x, self.y,
                                self.width, self.focus_height)

        love.graphics.setColor(self.framecolor)
        love.graphics.setLineStyle('smooth')
        love.graphics.setLineWidth(self.line_width)
        love.graphics.rectangle('line', self.x, self.y,
                                self.width, self.focus_height)

        love.graphics.stencil(draw_stencil)
        love.graphics.setStencilTest('greater', 0)

        local y = self.y+self.scroll
        local font = self.font or love.graphics.getFont()

        for i, v in ipairs(self.elements) do
            if y > self.y + self.focus_height then
                break
            end

            local _, wrap = font:getWrap(v.key, self.width)
            local height = font:getHeight() * #wrap

            if v == self.selection then
                love.graphics.setColor(self.selcolor)
                love.graphics.rectangle('fill', self.x, y+offset,
                                        self.width, height)
            end

            lgui.printf({text = v.key, x = self.x+offset, y = y+offset,
                        width = self.width, height = self.height,
                        font = self.font, color = self.textcolor})

            y = y + height
        end

        love.graphics.setStencilTest()
    else
        local function draw_stencil()
            love.graphics.rectangle('fill', self.x, self.y,
                                    self.width, self.height)
        end

        love.graphics.setColor(self.selcolor)
        love.graphics.rectangle('fill', self.x, self.y,
                                self.width, self.height)

        love.graphics.setColor(self.framecolor)
        love.graphics.setLineStyle('smooth')
        love.graphics.setLineWidth(self.line_width)
        love.graphics.rectangle('line', self.x, self.y,
                                self.width, self.height)

        love.graphics.stencil(draw_stencil)
        love.graphics.setStencilTest('greater', 0)

        lgui.printf({text = self.selection.key,
                    x = self.x+offset, y = self.y+offset,
                    width = self.width, height = self.height,
                    font = self.font, color = self.textcolor})

        love.graphics.setStencilTest()
    end
end

function lgui.interaction(e, mx, my, callback)
    if not callback or e.pause then
        return
    end

    if mx >= e.x and mx <= e.x+e.width
        and my >= e.y and my <= e.y+e.height then
        callback(e, mx, my)
    end
end

function lgui.mousepressed(elements, mx, my)
    for _, e in pairs(elements) do
        if not e.pause and e.active then
            if e.x and e.y and e.width and e.height
                and mx >= e.x and mx <= e.x+e.width
                and my >= e.y and my <= e.y+e.height then

                e.down = true

                if e.t == 'checkbox' then
                    e.value = not e.value
                elseif e.t == 'textfield' and e.editable then
                    e.focus = true
                    love.keyboard.setTextInput(true)
                elseif e.t == 'container' then
                    lgui.mousepressed(e.elements,
                                     mx-e.x-e.scroll.x, my-e.y-e.scroll.y)
                end

                if e.onClick
                    and (e.t ~= 'list'
                    or (e.t == 'list' and not e.toggle)) then
                    e:onClick(mx, my)
                end
            else
                if e.t == 'textfield' then
                    e.focus = false
                end
            end

            if e.t == 'list' and e.toggle
                and mx >= e.x and mx <= e.x+e.width
                and my >= e.y and my <= e.y+e.focus_height then
                e.down = true
                if e.onClick then
                    e:onClick(mx, my)
                end
            end
        end
    end
end

function list_getsel(e, my)
    local offset = e.font:getWidth('|') -- arbitrary offset to make
                                        -- textfields more pleasant to read
    local y = e.y+offset+e.scroll

    for k, v in pairs(e.elements) do
        local _, wrap = e.font:getWrap(v.key, e.width)
        local height = e.font:getHeight() * #wrap

        if util.between(my, y, y+height) then
            return k
        end

        y = y + height
    end
end

function lgui.mousereleased(elements, mx, my)
    for _, e in pairs(elements) do
        if not e.pause and e.active then
            if e.t == 'container' then
                lgui.mousereleased(e.elements,
                                  mx-e.x-e.scroll.x, my-e.y-e.scroll.y)
            elseif e.t == 'list' then
                local height = (e.toggle and e.focus_height or e.height)
                if mx >= e.x and mx <= e.x+e.width
                    and my >= e.y and my <= e.y+height then

                    if e.toggle and not e.moved then
                        e.toggle = false

                        local sel = list_getsel(e, my)
                        if sel and e.elements[sel] then
                            e.selection = e.elements[sel]
                        end
                        e.scroll = 0

                        if e.onRelease then
                            e:onRelease(mx, my)
                        end
                    elseif not e.toggle then
                        e.toggle = true
                    end

                end
                e.moved = false
            end

            if e.x and e.y and e.width and e.height
                and mx >= e.x and mx <= e.x+e.width
                and my >= e.y and my <= e.y+e.height then
                if e.onRelease
                    and (e.t ~= 'list'
                    or (e.t == 'list' and not e.toggle)) then
                    e:onRelease(mx, my)
                end
            end

            e.down = false
        end
    end
end

function lgui.mousemoved(elements, mx, my, dx, dy)
    for _, e in pairs(elements) do
        if not e.pause and e.active then
            if e.t == 'container' and e.down then
                e.scroll.x = util.clamp(e.scroll.x+dx,
                                        e.maxscroll.x0,
                                        e.maxscroll.x1)
                e.scroll.y = util.clamp(e.scroll.y+dy,
                                        e.maxscroll.y0,
                                        e.maxscroll.y1)
            elseif e.t == 'list' and e.toggle and e.down then
                e.moved = true
                e.scroll = e.scroll + dy
            end


            if e.t == 'container' and e.active then
                lgui.mousemoved(e.elements,
                               mx-e.x-e.scroll.x, my-e.y-e.scroll.y,
                               dx, dy)
            end
        end
    end
end

function lgui.wheelmoved(elements, dx, dy, x, y)
    local mx, my = love.mouse.getPosition()
    if x then mx = mx + x end
    if y then my = my + y end

    for _, e in pairs(elements) do
        if not e.pause and e.active then
            if e.x and e.y and e.width and e.height
                and mx >= e.x and mx <= e.x+e.width
                and my >= e.y and my <= e.y+e.height then
                if e.t == 'container' then
                    e.scroll.x = util.clamp(e.scroll.x+dx*3,
                                            e.maxscroll.x0,
                                            e.maxscroll.x1)
                    e.scroll.y = util.clamp(e.scroll.y+dy*3,
                                            e.maxscroll.y0,
                                            e.maxscroll.y1)
                end
                if e.t == 'container' then
                    lgui.wheelmoved(e.elements, dx, dy,
                                   -e.x-e.scroll.x, -e.y-e.scroll.y)
                end
            end

            if e.t == 'list' and e.toggle then
                local height = e.focus_height
                if mx >= e.x and mx <= e.x+e.width
                    and my >= e.y and my <= e.y+height then
                    e.scroll = util.clamp(e.scroll + dy*3,
                                          e.maxscroll[0],
                                          e.maxscroll[1])
                end
            end
        end
    end
end

function lgui.textinput(elements, c)
    for _, e in pairs(elements) do
        if not e.pause and e.active then
            if e.t == 'textfield' and e.focus then
                e.text = e.text .. c
            elseif e.t == 'container' then
                lgui.textinput(e.elements, c)
            end
        end
    end
end

function lgui.keypressed(elements, key, scancode, isrepeat)
    for _, e in pairs(elements) do
        if not e.pause and e.active then
            if e.t == 'textfield' and e.focus then
                if key == 'escape' then
                    e.focus = false
                elseif key == 'backspace' then
                    e.text = string.sub(e.text, 1, #e.text-1)
                elseif key == 'return' then
                    e.text = e.text .. '\n'
                end
            elseif e.t == 'container' then
                lgui.keypressed(e.elements, key, scancode, isrepeat)
            end
        end
    end

    -- on android the return key creates key 'escape' and scancode 'acback'
    if key == 'escape' or scancode == 'acback' then
        if love.keyboard.hasTextInput() then
            love.keyboard.setTextInput(false)
        elseif elements.escape then
            if elements.escape.onClick then
                elements.escape.onClick()
            elseif elements.escape.onRelease then
                elements.escape.onRelease()
            elseif elements.escape.onEscape then
                elements.escape.onEscape()
            end
        end
    end
end

function lgui.update_slider(self, mx, my)
    if self.down
        and mx >= self.x and mx <= self.x+self.width
        and my >= self.y and my <= self.y+self.height then
        self.value = util.clamp(
            (mx-self.x)/self.width * (self.max-self.min) + self.min,
            self.min,
            self.max)

        if self.round == 'floor' then
            self.value = math.floor(self.value)
        elseif self.round == 'ceil' then
            self.value = math.ceil(self.value)
        elseif self.round == 'round'
            or self.round == true then
            self.value = math.floor(self.value+0.5)
        end
    end
end

function lgui.update_container(self, mx, my)
    lgui.updateall(self.elements, -self.x-self.scroll.x, -self.y-self.scroll.y)
end

function lgui.updateall(elements, x, y)
    if not elements then
        return
    end

    local mx, my = love.mouse.getPosition()
    if x then mx = mx + x end
    if y then my = my + y end

    for _, e in pairs(elements) do
        if not e.pause and e.active then
            if e.update then
                e:update(mx, my)
            end

            local callback = e.down and e.onHold or e.onHover
            lgui.interaction(e, mx, my, callback)
        end
    end
end

function lgui.drawall(elements)
    if not elements then
        return
    end

    -- this table guarantees that containers will be drawn at the end
    local containers = {}

    for _, e in pairs(elements) do
        if e.active and e.draw then
            if e.t == 'container' then
                table.insert(containers, e)
            else
                e:draw()
            end
        end
    end

    for _, e in pairs(containers) do
        -- no need to check if e's active or not, because we already checked
        e:draw()
    end
end

return lgui
