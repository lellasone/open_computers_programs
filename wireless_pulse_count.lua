--[[
Counts the number of pulses on a wireless channel and outputs as 
two analogue digits to the sides every time it gets a pulse from the
back
]]--


--[[
local r = require("component").redstone
local s = require("sides")
]]--


local red = component.proxy(component.list("redstone")())
local sign = component.proxy(component.list("sign")())

local count = 0
local last_state = false
local last_trigger = false
local last_count = 0
local output_side_low = 5
local output_side_middle = 2
local output_side_high = 4
local trigger_update_side = 0
local channel = 1010
local max = 999

red.setWirelessFrequency(channel)
red.setWakeThreshold(1)

--[[Added to count before output, useful if there is a wake signal on the 
line that you do not want counted]]--
local count_adjust = -1

--[[ from Birdelther on devforum.roblox ]]--
function getDigit(num, digit)
    local n = 10 ^ digit
    local n1 = 10 ^ (digit -1)
    return math.floor((num % n) / n1)

end

while true do
    computer.pullSignal(1)
    --[[Update pulse count ]]-- 
    local state = red.getWirelessInput()
    if last_state == false then
        if state == true then
            count = count + 1
            sign.setValue(string.format("Running Count: \n %4.0f\n Last Count: \n%4.0f",count, last_count))
            
        end
    end
    last_state = state

    --[[If we get an input pulse, update the output]]--
    trigger = tobool(red.getInput(trigger_update_side))
    if last_trigger == false then
        if trigger == true then
            count = count + count_adjust

            if count > max then
                count = max
            end
     

            local ones = getDigit(count, 1)
            local tens = getDigit(count, 2)
            local hundreds = getDigit(count, 3)

            red.setOutput(output_side_low, ones)
            red.setOutput(output_side_middle, tens)
            red.setOutput(output_side_high, hundreds)


            last_count = count
            count = 0    
        end
    end 
    last_trigger = trigger
end
    
    
