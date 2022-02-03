--[[
Counts the number of pulses on a wireless channel and outputs as 
two analogue digits to the sides every time it gets a pulse from the
back
]]--


local r = require("component")
local sides = require("sides")


local r = component.proxy(component.list("redstone")())
local s = sides


local count = 0
local on = false
local output_side_low = s.left
local output_side_middle = s.front
local output_side_high = s.right
local trigger_update_side = s.back

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
    local state = r.getWirelessInput()
    if last_state == false then
        if state == true then
            count = count + 1
        end
    end
    last_state = state

    --[[If we get an input pulse, update the output]]--
    if red.getInput(trigger_update_side) > 0 then
        count = count + count_adjust
 

        local ones = getDigit(count, 1)
        local tens = getDigit(count, 2)
        local hundreds = getDigit(count, 3)

        red.setOutput(output_side_low, ones)
        red.setOutput(output_side_middle, tens)
        red.setOutput(output_side_high, hundreds)

        count = 0    
    end
        
end
    
    
