
--[[ This is a lua program for controlling a warpdrive force field generator 
based on open computers network messages. This program should be placed on a 
floppy in a computer connected to the projector, and that computer should be
connected by network (wired or wireless) to a computer running
"password.lua"

This program can either be used to create an external access terminal for a
secured facility (wireless cards), or to create a command terminal within a 
ship/base (wired card). 




The computer should be Tier 3, with T2 ran T3 CPU, T1 hard drive, and a screen
with keyboard. OpenOS should be loaded

Cable Colors:
    red - Red Flower Production.
    blue - Blue flower Production.
    green - Green Flower Production.
    pink - Red Flower Product Buffer. 
    light blue - Blue Flower Product Buffer.
    light green - Green Flower Product Buffer.
    White - Bonemeal Production.
    Yellow - Bonemeal Buffer.
    Yellow - Command Override (on).
--]]

local component = require("component")
local event = require("event")
local term = require("term")
local computer = require("computer")
local sides = require("sides")
local colors = require("colors")


local red = component.redstone

-- Which side does the cable come in on. 
side_red = sides.back

-- Set values for the various redstone cables. 
local red_in = colors.pink
local red_out = colors.red
local blue_in = colors.lightblue
local blue_out = colors.blue
local green_in = colors.lightgreen
local green_out = colors.green
local bone_in = colors.yellow
local bone_out = colors.white
local override = colors.black

local woodfarm = colors.grey
local dye_buff_low_full = colors.orange
local dye_buff_high_full = colors.cyan
local fuel_out = colors.purple


direct_control = function(input, output, override, invert_input, invert_output)
    --[[ This allows one redstone signal to set another redstone signal
         subject to override and remote shutdown signals. The override (on)
         trumps the remote shudown (off).
    
         Unless otherwise indicated redstone on is a logical high. 
    ]]--

    -- get input signal
    local into = false
    local out = false
    local shutdown = red.getWirelessInput()
    local over = red.getBundledInput(side_red, override)
    if red.getBundledInput(side_red, input) > 0 then
        into = not invert_input
    else
        into = invert_input
    end

    if shutdown and not over then
        out = invert_output
    elseif into then 
        out = not invert_output
    else
        out = invert_output
    end
    red.setBundledOutput(side_red, output, out)
end

print_state = function()
     





end
 
local startup_action
startup_action = function()
    event.ignore("term_available", startup_action)
    term.clear()

    -- Set up the auto-wake. 
    print("Setting Redstone Auto-Wake")
    red.setWakeThreshold(1)

    print(format("Setting Remote Shutdown Frequency")
    
     
    while true
    do
        -- Wait for a while.
        os.sleep(60)

        -- process fuel control.

        -- process bone control.

        -- process red flower control.
        direct_control(red_in, red_out, override, true, false)
        -- process green flower control.

        direct_control(green_in, green_out, override, true, false)
        -- process blue flower control.
         
        direct_control(blue_in, blue_out, override, true, false)
        -- Print out system state.
    

    end
    print("program has ended, shutting down")
    os.sleep(2)
    computer.shutdown() 
end

event.listen("term_available", startup_action)
