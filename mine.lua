local c = require("component")
local r = require("robot")
local s = require("sides")
local r = require("robot")
local g = c.generator
local inventory = c.inventory_controller




-- by default the robot's "forward" is along z+ to start.
local x = 0 --x axis position relative to reference
local y = 0 --vertical position relative to reference
local z = 0 --z position relative to referene
local h = s.front --heading relative to start


--[[
  This function moves the robot a specified distance, breaking any blocks that happen
  to be in the way. It uses tracked movement. 
 ]]--
 function break_line(length)
   for i = 0, length, 1 do
     break_move()
   end
 end

--[[
  This function will attempt to break the block in front of it and then move into 
  that space. This function will continue to attempt to break blocks and move for 
  as long as its block breaks are succesful. If it is unable to break the block it
  will give up. This is a tracked movement. 
  returns: true if move succesful, false if can't break. 
--]]
function break_move()
  if tracked_move() == true then
    return(true)
  else
    if(r.swing()) then
      break_move() --hitting it worked, so lets keep trying.
    end
    return(false) --seems there's no point in hitting it more, lets give up. 
  end
end

--[[
  This function moves the robot up one block and updates the y value appropriatly. 
  It should be used in place of robot.up
--]]
function tracked_up()
  if(r.up()) then
    y = y + 1
    return(true)
  end
  return(nil)
end

--[[
  This function moves the robot down one block and updates the y value appropriatly.
  It should be used in place of robot.down
--]]
function tracked_down()
  if(r.down()) then
    y = y-1
    return(true)
  end
  return(false)
end

--[[
  This function is the tracked equivilent of turnLeft(). It will turn the robot 
  left and then update the h value appropriatly. It shold be used in place of 
  turnLeft(). 
]]--
function tracked_left()
  r.turnLeft() 
  if h == s.left then
    h = s.back
  elseif h == s.right then
    h = s.front
  elseif h == s.front then
    h = s.left
  elseif h == s.back then
    h = s.right
  else
    error ("invalid h")
  end
end



--[[
  This function is the tracked equivilent of turnRight(). It will turn the robot 
  right and then update the h value appropriatly. It shold be used in place of 
  turnLeft(). 
]]--
function tracked_right()
  r.turnRight()
  if h == s.left then
    h = s.front
  elseif h == s.right then
    h = s.back
  elseif h == s.front then
    h = s.right
  elseif h == s.back then
    h = s.left
  else
    error ("invalid h")
  end
end


--[[
  This function moves the robot forward relative to it's current heading and 
  updates the tracking coordinates appropriatly to match. If the robot does 
  not move then the coordinates will not be updated. This should be moved 
  in place of forward() in pretty much all 
  cases. 
]]--
function tracked_move()
  if (r.forward()) then
    if h == s.front then
      z = z + 1
    elseif h == s.back then
      z = z - 1
    elseif h == s.left then
      x = x + 1
    elseif h == s.right then 
      x = x - 1 
    else
      error("invalid h")
    end
    return(true)
  end
  return(nil)
  
end

function mine_line(length)

    print(length)
end

function place_powered()
    print("placing powered block")

end
function place_regular()
    print("placing regular block")
end

POWERED_FREQ = 20

local i = 0
while i < 20 do 
    tracked_right()
    if i%2 == 0 then
        break_move()
        mine_line(15)
    else
        mine_line(16)
    end    
    tracked_right()
    tracked_right()
    break_line(16)
    tracked_right()
    if i%POWERED_FREQ == 0 then
        place_powered()
        i = 0
    else
        place_regular()
    end 
    break_move()
end

