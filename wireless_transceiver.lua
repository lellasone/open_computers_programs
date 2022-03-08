--[[
Makes the microprocessor act as a CWB wireless receiver or transmitter.
Since this system is slower than a normal CWB transmitter (and uses 
power) the main application is warp ships, where regular CWB blocks 
can be unreliable. 

The MCU is configured using a sign placed on the front as follows:

Line 1: In/Out [transmitter / receiver]
Line 2: Frequency 
Line 3: In/Out side [See sides api]
Line 4: State Readout

Example: (receiver on channel 10, outputting to the back)
in
10
2
[computer controlled, don't modify]

Prior to use configure the channel and output sides as needed. 

Requires:
    - Tier 2 microcontroller case.
    - Tier 1 CPU.
    - Tier 1 ram. 
    - Tier 2 redstone card.
    - Sign Controller.
    - EEPROM flashed with this program. 
]]--

local red = component.proxy(component.list("redstone")())
local sign = component.proxy(component.list("sign")())
red.setWakeThreshold(1)

local channel = 0
local type = "in"
local side = 2
state = 0

function read_sign()
    local sign_val = sign.getValue()
    local count = 0
    for line in sign_val:gmatch("([^\n]*)\n?") do
        if count == 1 then
	    channel = tonumber(line)
        elseif count == 0 then
	    type = line
        elseif count == 2 then
    	    side = tonumber(line)
        count = count + 1
    end
end



function write_sign()
	sign.setValue(string.format(" %s \n %4.0f\n %4.0f \n%4.0f",type, channel, side, state))
end

while true do 
    read_sign()
    red.setWirelessFrequency(channel)
    if type == "in" then
	state = red.getWirelessInput()
	red.setOutput(side, state)
    elseif type == "out" then
	state = red.getInput(side)
	red.setWirelessOutput(state)
    end
    write_sign()
end