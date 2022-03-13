--[[

Structure:
This program implemenents a Moore state machine which is evaluated every few
minutes. The "state" variable tracks the program's path through the state 
machine.

Each state is implemented as a function, and the order of the if statements
at the bottom of each state determines the transition priority order. 
]]--
warp = require("component").warpdriveShipCore
red = require("component").redstone
sides = require("sides")
colors = require("colors")
-- configuration settings
local min_cut_time = 6000 -- How long must the ship cut before being allowed 
                         -- to advance if nothing is mined. This should be
                         -- equal to the time required to scan the area for the
                         -- pure void case.
local step_delay = 120 -- How long to wait between state updates (s)
local jump_dir = -1 -- 1 to jump the ship "forward" -1 to jump it "backward"
                    -- relative to the warp core. Default: -1
local channel_report = 1013

-- Hardware Configuration
local channel_players = 10
local color_itemflow = colors.white
local color_localpower = colors.orange
local color_cutterpower = colors.red
local color_cutterreset = colors.blue -- This has to be externally inverted, or
                                      -- the cutters must be set to reset on 
                                      -- high. 
local side_cable = sides.back

-- State machine states.
s_start = 0
s_cut = 1
s_idle = 2
s_jump = 3
s_newpatch = 4
state = s_start

-- Global variables
local cut_time = 0 

-- Get the maximum jump range (will vary slightly depending on reactor design)
w.movement(0,0,0)
w.command("MANUAL",false)
success, max_jump = w.getMaxJumpDistance()

function start()
    
    -- No special actions, this is a transitional state 
    
    if players_on then state = s_idle end
    if localpower_low then state = s_idle end
    state = s_cut
end

function cut() 
   
    -- Enable power to cutting systems.
    red.setBundledOutput(side_cable, color_cutterpower, 15)
    red.setBundledOutput(side_cable, color_cutterreset, 0)
    cut_time = cut_time + step_delay

    
    if players_on then state = s_idle end
    if localpower_low then state = s_idle end
    if item_flow then state = s_cut  end
    if cut_time < min_cut_time then state = s_cut end
    state = s_jump
end

function idle() 
    -- Disable power to cutting systems
    red.setBundledOutput(side_cable, color_cutterpower, 0) 

    if players_on then state = s_idle end
    if localpower_low then state = s_idle end
    state = s_cut
end


function jump() 

    -- Disable cutter power, then jump the node.
    red.setBundledOutput(side_cable, color_cutterpower, 0) 

    -- command the jump
    w.movement(jump_dir * max_jump, 0, 0)
    w.rotationSteps(0)
    w.command("MANUAL", true)
    os.sleep(jump_delay)

    state = s_newpatch
    
end


function new_patch() 
    
    -- Reset the cutters and cut time
    red.setBundledOutput(side_cable, color_cutterreset, 15)
    cut_time = 0 
    
    if players_on then state = s_idle end
    if localpower_low then state = s_idle end
    state = s_cut
end

while true do
    -- Get node readouts and pulse.
    print("state" state)
    red.setWirelessFrequency(channel_report)
    local flow1 = red.getBundledInput(side_cable, color_itemflow)
    red.setWirelessOutput(1) 
    os.sleep(0.5)
    red.setWirelessOutput(0)
    local flow2 = red.getBundledInput(side_cable, color_itemflow)
    if flow1 + flow2 > 0 then item_flow = true 
    else item_flow = false end

    if red.getBundledInput(side_cable, color_localpower) > 0 then
        localpower_low = false
    else
        localpower_low = true
    end 
    
    red.setWirelessFrequency(channel_players)
    if red.getWirelessInput() > 0 then players_on = true
    else players_on = false end     
     
    if state == s_start then
        start() 
    elseif state == s_cut then
        cut() 
    elseif state == s_idle then
        idle() 
    elseif state == s_jump then
        jump()
    elseif state == s_newpatch then
        new_patch() 
    else
        print("Invalid State Reached")
    end
    print("Item Flow: ", itemflow, "Local Power Low: ", localpower_Low, "Players On", players_on)
    
    os.sleep(step_delay)

end

print("program ended, an error has arisen")
