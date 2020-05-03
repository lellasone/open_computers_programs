
local c = require("component")
local r = require("robot")
local s = require("sides")

-- by default the robot's "forward" is along z+ to start.
local x = 0 --x axis position relative to reference
local y = 0 --vertical position relative to reference
local z = 0 --z position relative to referene
local h = s.front --heading relative to start
function tracked_move()
  if (r.forward())
    if h = s.front then
      z = z + 1
    elseif h = s.back then
      z = z - 1
    elseif h = s.left then
      x = x + 1
    elseif h = s.right then 
      x = x - 1 
    else
      error("invalid h")
    end
    return(true)
  end
  return(nil)
  
end
