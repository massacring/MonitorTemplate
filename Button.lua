local Button = {
    isButton = true,
    isActive = false,
    monitor = nil,
    clickEvent = function() print("Click!") end,
    x = 1,
    y = 1,
    width = 7,
    height = 3,
    isPressed = false,
    backgroundColorCurrent = colors.black,
    backgroundColorNormal = colors.black,
    backgroundColorPressed = colors.gray,
    hasBorder = false,
    borderColorCurrent = nil,
    borderColorNormal = nil,
    borderColorPressed = nil,
    label = "Press",
    labelPad = 0,
    textColorCurrent = colors.lightGray,
    textColorNormal = colors.lightGray,
    textColorPressed = colors.white
}

function Button:new(_o, monitor, clickEvent, x, y, width, height, backgroundColorNormal, backgroundColorPressed, borderColorNormal, borderColorPressed, label, labelPad, textColorNormal, textColorPressed)
    assert(type(monitor) == "table", "display must be a table.")
    local o = _o or {}
    setmetatable(o, self)
    self.__index = self
    self.isButton = true
    self.isActive = false
    self.monitor = monitor
    self.clickEvent = clickEvent or function() print("Click!") end
    self.x = x or 1
    self.y = y or 1
    self.width = width or 3
    self.height = height or 3
    self.isPressed = false
    self.backgroundColorCurrent = backgroundColorNormal or colors.black
    self.backgroundColorNormal = backgroundColorNormal or colors.black
    self.backgroundColorPressed = backgroundColorPressed or colors.gray
    self.hasBorder = borderColorNormal and borderColorPressed
    if self.hasBorder then
        self.borderColorCurrent = borderColorNormal
        self.borderColorNormal = borderColorNormal
        self.borderColorPressed = borderColorPressed
    else
        self.borderColorCurrent = nil
        self.borderColorNormal = nil
        self.borderColorPressed = nil
    end
    self.label = label or "Press"
    self.labelPad = labelPad or 0
    self.textColorCurrent = textColorNormal or colors.lightGray
    self.textColorNormal = textColorNormal or colors.lightGray
    self.textColorPressed = textColorPressed or colors.white

    self.width = self.width + (self.labelPad * 2)
    self.height = self.height + (self.labelPad * 2)
    if self.hasBorder then
        self.width = self.width + 2
        self.height = self.height + 2
    end

    -- self:displayOnScreen()

    return o
end

function Button:displayOnScreen()
    local monitor = self.monitor
    local x_offset, y_offset = self.labelPad, self.labelPad
    monitor.setBackgroundColor(self.backgroundColorCurrent)
    for i = 0, self.height-1, 1 do
        monitor.setCursorPos(self.x, self.y - i)
        monitor.write(string.rep(" ", self.width))
    end

    if self.hasBorder then
        x_offset = x_offset + 1
        y_offset = y_offset + 1
        monitor.setBackgroundColor(self.borderColorCurrent)
        for i = 1, self.width, 1 do
            for j = 1, self.height, 1 do
                if not ((i == 1 or j == 1) or (i == self.width or j == self.height)) then goto continue end

                monitor.setCursorPos(self.x + (i-1), self.y - j + 1)
                monitor.write(" ")

                ::continue::
            end
        end
        monitor.setBackgroundColor(self.backgroundColorCurrent)
    end

    monitor.setCursorPos(
        self.x + x_offset,
        (self.y - y_offset)
    )
    monitor.setTextColor(self.textColorCurrent)
    monitor.write(self.label)
    self.isActive = true
end

function Button:clear(color)
    local monitor = self.monitor
    monitor.setBackgroundColor(color)
    for i = 0, self.height-1, 1 do
        monitor.setCursorPos(self.x, self.y - i)
        monitor.write(string.rep(" ", self.width))
    end
    self.isActive = false
end

function Button:move(x, y, color)
    self:clear(color or colors.black)
    self.x = x
    self.y = y
    self:displayOnScreen()
end

function Button:toggle()
    self.isPressed = not self.isPressed
    if self.isPressed then
        self.backgroundColorCurrent = self.backgroundColorPressed
        self.borderColorCurrent = self.borderColorPressed
        self.textColorCurrent = self.textColorPressed
    else
        self.backgroundColorCurrent = self.backgroundColorNormal
        self.borderColorCurrent = self.borderColorNormal
        self.textColorCurrent = self.textColorNormal
    end
    self:displayOnScreen()
end

return Button
