local Button = require('../Button')

local Screen = {
    monitor = nil,
    name = "Screen",
    buttonsRegistry = {},
    backgroundColor = colors.black,
}

function Screen:new(_o, name, monitor, backgroundColor)
    assert(type(monitor) == "table", "monitor must be a table.")
    local o = _o or {}
    setmetatable(o, self)
    self.__index = self
    self.name = name
    self.monitor = monitor
    self.width, self.height = monitor.getSize()
    self.backgroundColor = backgroundColor or colors.black
    self.buttonsRegistry = {}

    return o
end

function Screen:clearWindow(color)
    local monitor = self.monitor
    monitor.setTextScale(1)
    self.width, self.height = monitor.getSize()
    monitor.setBackgroundColor(color)
    monitor.clear()
    monitor.setCursorPos(1, 1)
end

function Screen:getCenter(x_content, y_content)
    local x_offset = math.floor(self.width  / 2) - math.floor(x_content / 2) + 1
    local y_offset = math.floor(self.height / 2) + math.floor(y_content / 2) + 1
    return x_offset, y_offset
end

function Screen:registerButton(button)
    assert(button.isButton, "You can only register buttons.")
    table.insert(self.buttonsRegistry, button)
end

function Screen:createButton(clickEvent, _x, _y, _width, _height, backgroundColorNormal, backgroundColorPressed, borderColorNormal, borderColorPressed, label, labelPad, textColorNormal, textColorPressed, isCenter)
    assert(type(clickEvent) == "function", "clickEvent is not a function.")

    local x = _x or 0
    local y = _y or 0

    if isCenter then
        x, y = self:getCenter((#label + 4), 5)
    end

    local button = Button:new(nil, self.monitor, clickEvent, x, y, _width, _height, backgroundColorNormal, backgroundColorPressed, borderColorNormal, borderColorPressed, label, labelPad, textColorNormal, textColorPressed)
    self:registerButton(button)
    return button
end

function Screen:placeButtons()
    for index, button in pairs(self.buttonsRegistry) do
        button:displayOnScreen()
    end
end

function Screen:loadScreen()
    self:clearWindow(self.backgroundColor)
    self:placeButtons()
end

return Screen