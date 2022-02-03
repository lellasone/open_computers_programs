--[[ A script for auto-running the mining program (whichever is in use)
]]--

local event = require("event")
local term = require("term")

local startup_action
startup_action = function()
    event.ignore("term_available", startup_action)
    term.clear()
    print("starting mining program, press control-c now to exit")
    os.wait(5)
    print("starting mine.lua")
    dofile("mine.lua")
end
event.listen("term_available", startup_action)
