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

local RAIL_UNPOWERED = 4 -- how long should the stretches of unpowered rail be.
local RAIL_POWERED = 1 -- how long should the stretches of powered rail be. 
local RAIL_ACTIVATOR = "minecraft:redstone_block"


--[[
  This function places the markers and quarry for the right quarry.
  This function uses tracked movement. 
  Precondition: Robot placed in the block where the quarry should be. 
  		line of blocks placed out to forward landmark location. 
  postcondition: Quarry placed and activated. 
]]--
function place_right_quarry()
  place_line_below(65, "minecraft:stone")
  tracked_up()
  set_item_self("buildcraftcore:marker_volume")
  r.placeDown()   --Place outer landmark. 
  tracked_left()
  tracked_left()
  break_line(64)  --return to start (but up by one)
  tracked_right()
  break_line(64)
  r.placeDown()   --place forward marker. 
  tracked_right()
  tracked_right()
  break_line(64)
  r.placeDown() --place center marker. 
  r.use() --activate markers. 
  tracked_right()
  break_move()
  tracked_right()
  tracked_right()
  set_item_self("buildcraftbuilders:quarry")
  r.placeDown()
end

--[[
  This function places a long distance rail line composed of mixed powered and
  unpowered track. The track will always start with a standard sized length of
  powered track. The end of the line may be powered or unpowered depending on 
  where it falls. The rail is placed directly below the robot (meaning it must
  start one block above the surface where the rail is to be placed). 
  This function uses tracked movement. 
  args:
    length - int, how long the track should be in blocks. 
--]]
function place_rail_line(length)
  while length > 0 do
    break_move()
    place_powered(RAIL_POWERED, RAIL_ACTIVATOR)
    length = length - RAIL_POWERED
    
    if length > RAIL_UNPOWERED then
      -- not near end of track, place another strech of unpowered rail. 
      place_line_below(RAIL_UNPOWERED, "minecraft:rail")
      length = length - RAIL_UNPOWERED
    else
      -- remaining distance less than unpowered strech, place regular till we get
      -- to the end of the track. 
      place_line_below(length, "minecraft:rail")
      length = 0
    end
  end
end

--[[
  This function places a stretch of powered golden rail starting directly below
  the robot. An actiator plock as specified is placed to the right of the first
  golden rail. 
  This function uses tracked movement.
  args:
    length - int, how long of a strech to place. 
    activator - minecraft block name, the block to place to power the rail
--]]
function place_powered(length, activator)
  tracked_right()
  break_move()
  set_item_self(activator)
  r.placeDown()
  tracked_left()
  tracked_left()
  break_move()
  tracked_right()
  place_line_below(length, "minecraft:golden_rail")
end


--[[
  This function places a rectangular plate of material below the robot. The 
  plate is placed in the x+ z+ directions (left and forward) starting from 
  the block diretly below the robot. 
  this funciton uses tracked movement. 
]]--
function place_rect_below(zcord, xcord, item)
  local x_plate = 0 -- robot position in the coordinate system of the plate. 
  local z_plate = 0 -- robot position in the coordinate system of the plate. 

  -- we only build in one configuration, so lets turn the turtle to match the
  -- starting corner of the plate. This feature is only kind of supported. 
  if zcord > 0 and xcord < 0 then
    tracked_right()
    xcord = -1* xcord
  elseif zcord < 0 and xcord > 0 then
    tracked_left()
    zcord = -1*zcord
  elseif zcord < 0 and xcord < 0 then
    tracked_left()
    tracked_left()
    zcord = -1*zcord
    xcord = -1*xcord
  end

  -- place the first line. 
  tracked_left()
  place_line_below(xcord, item)
  x_plate = xcord
  tracked_right()

  while z_plate < zcord - 1 do
    z_plate = z_plate + 1
    place_line_below(2, item) -- go to the next z cord. 
    if x_plate == xcord then
      tracked_right()
      x_plate = x_plate - xcord
    elseif x_plate == 0 then
      tracked_left()
      x_plate = x_plate + xcord
    else
      error("invalid platform coordinates")
    end


    place_line_below(xcord, item) -- build to the other side of the plate. 


    -- turn back in the z direction. 
    if x_plate == 0 and xcord > 0 then
      tracked_left()
    elseif x_plate == xcord and xcord > 0 then
      tracked_right()
    else 
      error("invalid platform coordinates")
    end
  end

end

--[[
  This function will place a line of blocks below the robot. It will automatically
  switch from one stack to another as needed, but does not check that enough blocks
  are in inventory before starting. Stacks will be used from low to high according
  to slot location. The robot will not return to it's starting position after
  it is done placing blocks. 
  args: 
    item - type of block to place, for example "minecraft:dirt"
    length - distance to place blocks. 
--]]
function place_line_below(length, item)
  local loc = 1
  set_item_self(item)
  r.placeDown()
  while loc < length do
    break_move()
    set_item_self(item) -- go to a stack of our blocks. 
    r.placeDown()

    loc = loc + 1
  end

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

--[[
  This function is used for reporting errors as the occur. 
  for now it is a place holder which prints the error. 
]]--
function error(msg)
  print(msg)
end

function print_loc()
  print(x)
  print(y)
  print(z)
  print(h)
end

--[[
  A dead simple function that says hello
--]]
function hello_world()
  print("Hello World!")
end


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

print(add_coal())
print_inventory()
place_right_quarry()
place_rail_line(10)
