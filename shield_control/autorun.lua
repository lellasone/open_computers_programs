
--[[

Commands:
    "password" - Lower shield for 60s.
    "password:on" - Activate shield. 
    "password:off" - Lower shield.
--]]
port = 666
password = "gdbg"
off = password..":off"
on = password..":on"

local component = require("component")
local event = require("event")
local term = require("term")
local computer = require("computer")

local modem = component.modem
local shield = component.warpdriveForceFieldProjector

local startup_action
startup_action = function()
    event.ignore("term_available", startup_action)
    term.clear()

    -- Set up the auto-wake. 
    print("setting startup message")
    modem.setWakeMessage("wake")
    modem.isOpen(666)
  
    while true
    do 
        local _, _, from, port, _, message = event.pull(60, "modem_message")
        
        if message == on then
            print("got shield enable command")
            shield.enable(1)
            modem.broadcast(666,"good")
        elseif message == off then
            print("got shield disable command")
            shield.disable(0)
            modem.broadcast(666,"good") 
        elseif message == password then
            print("got shield flicker command, lowering for 60s")
            shield.enable(0)
            modem.broadcast(666,"good")
            os.sleep(60)
            shield.enable(1)
        elseif message ~= nil then
            print("got invalid message")
            modem.broadcast(666,"bad")
        end
    end
    print("program has ended, shutting down")
    os.sleep(2)
    computer.shutdown() 
    print(term.read())
end

event.listen("term_available", startup_action)
