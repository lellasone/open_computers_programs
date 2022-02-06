
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

Commands:
    "password" - Lower shield for 60s.
    "password:on" - Activate shield. 
    "password:off" - Lower shield.
    "password:ping" - Do nothing, but return a valid response. (good for 
        debugging)
--]]
port = 666
password = "gdbg"
off = password..":off"
on = password..":on"
ping = password..":ping"

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
    modem.open(port)
  
    while true
    do 
        local _, _, from, port, _, message = event.pull(60, "modem_message")
        
        if message == on then
            print("got shield enable command")
            shield.enable(1)
            modem.broadcast(port,"good")
        elseif message == off then
            print("got shield disable command")
            shield.disable(0)
            modem.broadcast(port,"good") 
        elseif message == password then
            print("got shield flicker command, lowering for 60s")
            shield.enable(0)
            modem.broadcast(port,"good")
            os.sleep(60)
            shield.enable(1)
        elif message = ping then
            print("got valid password ping. Taking no actions."
            modem.broadcast(port,"good")
        elseif message ~= nil then
            print("got invalid message")
            modem.broadcast(port,"bad")
        end
    end
    print("program has ended, shutting down")
    os.sleep(2)
    computer.shutdown() 
    print(term.read())
end

event.listen("term_available", startup_action)
