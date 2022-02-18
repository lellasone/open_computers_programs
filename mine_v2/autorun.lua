--[[ A script for auto-running the mining program (whichever is in use)
]]--

local event = require("event")
local term = require("term")

local startup_action
startup_action = function()
    event.ignore("term_available", startup_action)
    term.clear()
    print("starting mine.lua")
    os.execute("cd floppy && ./mine.lua")
end
event.listen("term_available", startup_action)
