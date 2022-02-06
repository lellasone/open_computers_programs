--[[ This program broadcasts commands to a remote computer. It was initially
intended as an access terminal for a shielded facility and works well in that
capacity (although note that passphrases are sent in the clear). 

The computer should be T3 with T2 ram, cpu, T1 hard drive, and openos loaded.  

--]]
port = 666
local component = require("component")
local m = component.modem
local computer = require("computer")
local event = require("event")



print("Booting up remote computer, please wait 0.5s")
m.broadcast(port, "wake")
os.sleep(.5)


print("Please enter passcode and (optional) command. Then press enter to send")
local password = io.read()

print("Sending passcode...")
m.broadcast(port, password)

print("Passcode sent, waiting 3s for a reply then shutting down")


local _, _, from, port, _, message = event.pull(3, "modem_message")

if port ~= port then
    print("received message from unknown machine")
elseif response == "good" then 
    print("passcode correct.")
    print("this computer will shut down in 10s")
    os.sleep(60)
    computer.shutdown()
elseif response == "bad" then 
    print("passcode incorrect")
elseif response == nil then
    print("no reply")
else 
    print("unknown error")
end
