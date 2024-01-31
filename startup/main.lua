local Screen = require('../Screen')

local modem = peripheral.wrap("left") or error("No modem attached", 0)
if not modem.isWireless() then error("No wireless modem attached", 0) end
local channel = 4243
modem.open(channel)

local _monitor = peripheral.wrap("monitor_0") or error("No monitor attached", 0)

local mainScreen = Screen:new(nil, "main", _monitor, colors.gray)
local storageScreen = Screen:new(nil, "storage", _monitor, colors.gray)
local currentScreen = storageScreen

local function loadStorageScreen()
    local label = "Home"
    local button = storageScreen:createButton(function (button)
        currentScreen = mainScreen
        mainScreen:loadScreen()
    end, 2, storageScreen.height - 1, #label, 1, colors.lightBlue, colors.yellow, colors.blue, colors.orange, label, 1, colors.white, colors.lightGray, false)
end
loadStorageScreen()

local function loadMainScreen()
    local label = "Storage"
    local button = mainScreen:createButton(function (button)
        currentScreen = storageScreen
        storageScreen:loadScreen()
    end, 0, 0, #label, 1, colors.lightBlue, colors.yellow, colors.blue, colors.orange, label, 1, colors.white, colors.lightGray, true)
end
loadMainScreen()

local function loadRainbow()
    local colorTable = {
        colors.yellow;
        colors.orange;
        colors.red;
        colors.magenta;
        colors.purple;
        colors.lime;
        colors.green;
        colors.cyan;
        colors.lightBlue;
        colors.blue;
        colors.brown;
    }

    for t = 1, 100, 1 do
        for i = 2, currentScreen.width-1, 1 do
            for j = 2, currentScreen.height-1, 1 do
                currentScreen.monitor.setCursorPos(i, j)
                currentScreen.monitor.setBackgroundColor(colorTable[(i+j+t) % #colorTable + 1])
                currentScreen.monitor.write(" ")
            end
        end
        sleep(0.05)
    end
end

currentScreen:loadScreen()

while true do
    local eventData = {os.pullEvent()}
    local event = eventData[1]

    if event == 'monitor_touch' then
        local x, y = eventData[3], eventData[4]
        for index, button in pairs(currentScreen.buttonsRegistry) do
            if not button.isActive then goto continue end
            if ((x >= button.x) and (x < (button.x + button.width))) and ((y <= button.y) and (y > (button.y - button.height))) then
                button.clickEvent(button)
                break
            end
            ::continue::
        end
    elseif event == 'modem_message' then
        local senderChannel, replyChannel, message = eventData[3], eventData[4], eventData[5]
        if senderChannel == channel then
            print("Received a message:", tostring(message))

            local switch = function (argument)
                argument = argument and tonumber(argument) or argument
            
                local case =
                {
                    reboot = function ()
                        modem.transmit(replyChannel, senderChannel, "Rebooting...")
                        os.reboot()
                    end,
                    rainbow = function ()
                        modem.transmit(replyChannel, senderChannel, "How tasteful!")
                        loadRainbow()
                        currentScreen:loadScreen()
                    end,
                    default = function ()
                        print("Invalid command")
                    end
                }
            
                if case[argument] then
                    case[argument]()
                else
                    case["default"]()
                end
            end

            switch(message)
        end
    end
end
