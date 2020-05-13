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
  This function outputs the inventory to the console for debugging purposes. 
--]]
function print_inventory()
  for i = 1, r.inventorySize(),  1 do
    local temp = inventory.getStackInInternalSlot(i)
    if temp ~= nil then print(temp.name) end
  end
end

--[[ 
  Locates the specified item in inentory and selects that slot.
  if the slot cannot be found then no change is made. 
  returns: slot number if found, nil if not found. 
--]]
function set_item_self(item)
  local temp = find_item_self(item)
  if temp ~= nil then 
    r.select(temp)
    return(temp)
  else 
    return(nil)
  end
end





--[[
  Find the first instance of the specified item in this device's general 
  inventory. This function does not set a new selected slot. 
  returns: number of first slot containing item, nil if none found. 
]]--
function find_item_self(item)
  for i = 1, r.inventorySize() do
    local temp = inventory.getStackInInternalSlot(i) --lets see what we have found.
    if(temp ~= nil and temp.name == item) then
      print("found")
      return(i)
    end
  end
  return(nil) -- we did not find the object.
end


--[[
  This function tops up the generator with coal. It is safe to call if the
  generator is already full, and should be called often as a result. This
  function does not change the curser position.
  
  Note: This is not designed to work in a mixed-fuel environment. Only coal 
  will be added. 

  returns: true if generator full or filled, false if no coal is found.
]]--
function add_coal()
  local old_slot = r.select()
  if g.count() < 64 then
    if set_item_self("minecraft:coal") then
      g.insert(64) --add fuel to the generator
      r.select(old_slot)
      return('true')
    else
      r.select(old_slot)
      error("no coal found")
      return(false)
    end
  end
  r.select(old_slot)
  return(true) --generator already full
end


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


--[[ This function column-mines for the specified number of blocks in a straght
    line. The robot will mine a column every other block along the line and 
    will dump it's materials and refuel after every column. 
    Precondition: Robot above column to mine. An ender chest should be in the
                  inventory containing coal, and the ender chest should remove
                  depositied materials. 
    args: 
        length - how far should the robot travel while mining. Total mined
                 length will be two greater than this (because the robot mines
                 the adjacent columns each time it decends)
]]--
function mine_line(length)
    for a = 0, length, 1 do
        if a%2 == 1 then
            grab_supplies()
            mine_column()
            dump_goods()
            fuel_robot()
        end
        break_move()
    end 
    print(length)
end

function grap_supplies()

end

function mine_column()

end

--[[ 
    Places an ender chest below the robot. Dumps the entire contents of the 
    robot's inventory into the ender chest. Then picks up the ender chest. 
]]--
function dump_goods()
    r.swingDown()
    set_item_self("enderstorage:ender_storage")
    r.placeDown()
    for i = 1, r.inventorySize(),  1 do
       r.dropDown()
    end
    r.swingDown()
end

function fuel_robot()

end

function place_powered()
    print("placing powered block")

end
function place_regular()
    print("placing regular block")
end

POWERED_FREQ = 5
print_invenotry() 
local i = 0
while i < 20 do 
    i = i + 1
    print(i)
    tracked_right()
    if i%2 == 0 then
        break_move()
        mine_line(5)
    else
        mine_line(6)
    end    
    print("returning")
    tracked_right()
    tracked_right()
    break_line(6)
    tracked_right()
    if i%POWERED_FREQ == 0 then
        place_powered()
        i = 0
    else
        place_regular()
    end 
    break_move()
    break_move()
    os.sleep(1)
end

