--[[ A script for auto-running the mining program (whichever is in use)
]]--

local event = require("event")
local term = require("term")
local component = require("component")

drive_label =  nil

local startup_action
local mnt_add = "default_something_broke"
startup_action = function()
    event.ignore("term_available", startup_action)
    term.clear()
    print("finding floppy drive location")
    for address in component.list('filesystem')do
        if component.proxy(address).getLabel() == drive_label then
            mnt_add = string.sub(address,0,3)
        end
    end
    print("got address: ",mnt_add)
    print("starting mine.lua")
    os.execute(string.format("/mnt/%s/mine.lua",mnt_add))
end
event.listen("term_available", startup_action)
