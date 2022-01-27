--[[
    This program moves forward indefinitly mining a patch of specified 
    width in a straight line. Blocks can be blacklisted for mining, but    
    note that alrge cobble towers will render mined areas unusable. This
    program is appropriate for mining when power is at a premium, or when 
    the end has not yet been reached

    The robot is to be placed one block in from the left side of the chunk
    to be mined. A pick, block of scaffold material, and encoded ender 
    chest should be placed in it's inventory before activation. 

    The ender chest should be set up to maintain the specified quantity of 
    each material (below) and should rapidly extract all other materials
    placed into the chest. If the scaffold material or fuel overlap with 
    mined materiasl (say using cobble for the scaffold) the chest should
    be configured to extract those materials as well. The number of robots
    which can share a chest is determined by the material extraction and 
    supply speed. Generally extraction is the limit rather than supply. 
    
    The robot should be configured as follows. It will be nessary to
    install the os on the hard drive before use. 


    Note: Cobble is self sustaining as a scaffold material for low-height 
          mining, but not if the robot begins near world-height. Coal is
          not energy positive at any height and must thus be suplimented
          if used as the fuel sorce.  

    Ender Chest Contents: 
        (256x) Scaffold Material. 
        (128x) Fuel Material.
        (20x)  Redstone Block. 
        (20x)  Powered Rail. 
        (20x)  Normal Rail. 
        (1x)   Pick (Diamond Tier). 
    Robot Components: 
        (1x) Tier 3 case. 
        (2x) Inventory Upgrade.
        (1x) Tier 2 upgrade.
        (1x) Tier 3 upgrade.
        (1x) Keyboard. 
        (1x) Screen Tier 1. 
        (1x) Solar Generator. 
        (1x) Angle Upgrade.
        (1x) Inventory Controller.
        (1x) Chunkloader Upgrade.
        (1x) Geolyzer. 
        (2x) 2mb Ram. 
        (1x) 1mb Hard Drive. 
        (1x) Tier 3 CPU. 
        (1x) Graphics Card. 
        (1x) Internet Card.
        (1x) Generator.
        (1x) LUA ROM.

    Changelog:
        1.1 - Place filler on all four sides and down.
        1.2 - clears a 2 high space above, breaks on all sides.
]]--

local c = require("component")
local r = require("robot")
local s = require("sides")
local r = require("robot")
local computer = require("computer")
local g = c.generator
local ge = c.geolyzer
local inventory = c.inventory_controller
local chunk = c.chunkloader


local POWERED_FREQ = 16
local SWATH_WIDTH  = 14 -- width to travel (mined width will be two greater)
local SCAFFOLD_MATERIAL = "minecraft:cobblestone" -- what block to use for movement scaffolds.
local FUEL_MATERIAL = "ic2:itemcellempty"
-- List of items to not mine on the sides. These will still be broken if in the way of robot movement. 
NO_MINE_LIST = {"minecraft:stone", SCAFFOLD_MATERIAL, "minecraft:dirt", "minecraft:glass","minecraft:netherrack"}
local MAX_DAMAGE = 1250 --max damage a pick is allowed to take. 

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
  Find the first instance of the specified item in an adjacent storage 
  inventory. This function does not set a new selected slot. 
  args:
    item - string, name of the item to search for ("minecraft:dirt")
    side - int, number of the side to check inventory on. 
  returns: number of first slot containing item, nil if none found. 
]]--
function find_item_other(side, item)
  for i = 1, inventory.getInventorySize(side) do
    local temp = inventory.getStackInSlot(side, i) --lets see what we have found.
    if(temp ~= nil and temp.name == item) then
      return(i)
    end
  end
  return(nil) -- we did not find the object.
end

--[[
    Get the specified number of items from the specified inventory. This
    function will pull from each slot (with the correct item) in turn until it
    gets enough items. If the inventory is exhausted before that occurs it will
    wait a short time and then try again. 
    args:
        item - string, minecraft name of item to get ("minecraft:coal")
        side - int, number of side to pull from. 
        quantity - int, number of items to get. 
        timeout - int, seconds to wait before giving up (default 100). 
    returns: true if all items collected, false if timeout trips first.
]]-- 
function get_item_other(side, item, quantity, timeout)
    timeout = timeout or 100 --set the default number of tries. 
    
    for i = 0, timeout * 4, 1 do
        local slot = find_item_other(side, item)
        if (slot ~= nil) then  
            local target = inventory.getStackInSlot(side, slot)
            if(target ~= nil and target.name == item) then
                local quant = target.size -- get number of items in target stack. 
                inventory.suckFromSlot(side, slot, quantity)
                quantity = quantity - quant
            end
        end
        if quantity <= 0 then
            return(true) -- we got all our items, end the loop.
        end
        os.sleep(0.25) -- wait before next search 
    end
    return(false) -- we didn't get everything we wanted before timeout. 
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
    if set_item_self(FUEL_MATERIAL) then
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
  This function will attempt to break the block above it and then move into 
  that space. This function will continue to attempt to break blocks and move for 
  as long as its block breaks are succesful. If it is unable to break the block it
  will give up. This is a tracked movement. 
  returns: true if move succesful, false if can't break. 
--]]
function break_up()
  if tracked_up() == true then
    return(true)
  else
    if(r.swingUp()) then
      break_up() --hitting it worked, so lets keep trying.
    end
    return(false) --seems there's no point in hitting it more, lets give up. 
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
    leng256- distance to place blocks. 
--]]
function place_line_below(length, item)
  local loc = 1
  set_item_self(item)
  r.placeDown()
  while loc < length do
    break_move()
    r.swingUp()
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
	    dump_goods()
            grab_supplies()
	    swap_pick()
	    tracked_right()
	    tracked_right()
            mine_column(128)
	    tracked_right()
	    tracked_right()
        end
        place_line_below(2, SCAFFOLD_MATERIAL)
    end 
    print(length)
end


function swap_pick()
    set_item_self("minecraft:diamond_pickaxe")
    local slot = find_item_self("minecraft:diamond_pickaxe")
    inventory.equip()
    local pick = inventory.getStackInInternalSlot(slot)
    if pick.damage > MAX_DAMAGE then 
        r.drop() -- this pick is bad, lets toss it. 
    else 
        inventory.equip() -- it's fine, lets keep it equiped. 
    end
end


function grab_supplies()
    r.swingDown()
    set_item_self("enderstorage:ender_storage")
    r.placeDown()
    get_item_other(s.bottom, FUEL_MATERIAL, 8)
    get_item_other(s.bottom, SCAFFOLD_MATERIAL, 192)
    get_item_other(s.bottom, "minecraft:diamond_pickaxe",1)
    get_item_other(s.bottom, "minecraft:redstone_block",8)
    get_item_other(s.bottom, "minecraft:golden_rail", 8)
    get_item_other(s.bottom, "minecraft:rail", 8)
    add_coal() -- can't be too careful. 
    r.swingDown()
end

function mine_column(timeout)
    local y_start = y 
    for i = 0, timeout, 1 do
   	tracked_down()
	wait_power(0.2) -- make sure we have the energy to move. 
	set_item_self(SCAFFOLD_MATERIAL)
	-- mine to all sides. 
        break_black(NO_MINE_LIST)
        r.place(s.front)
        tracked_right()
        break_black(NO_MINE_LIST)
        r.place(s.front)
        tracked_right()
        break_black(NO_MINE_LIST)
        r.place(s.front)
        tracked_right()
        break_black(NO_MINE_LIST)
        r.place(s.front)
	-- lets place our scaffold. 
	r.swingDown()
	if (r.detectDown()) then break end
    end
    print(y)
    print(y_start)
    while y < y_start do
    	r.place(s.front)
        set_item_self(SCAFFOLD_MATERIAL)
        break_up() 
    end
    print("finished column")
end

--[[ 
    Turn the robot right until it is facing in the desired direction in global cords. 
    This function uses tracked movement. 
    args:
        side - the side to head too.
]]--
function set_heading(side)
   while h ~= side do
   	tracked_right()
   end
end
--[[ 
    This function adds fuel and waits for the generator to recharge above the threshold
    before allowing the robot to continue moving. It is blocking, and will not get more
    fuel from an external inventory if it runs out. 
    params: 
        threshold - value between 0 and 1 specifying the min allowable ratio of max energy
	            to current energy in the robot's buffers
]]--
function wait_power(threshold)
    while computer.energy() / computer.maxEnergy() < threshold do
    	fuel_robot()
	os.sleep()
    end
end


--[[
    Breaks the block in front of the robot if that block is not on the
    blacklist.
    args: 
        blacklist - list of strings containing block names not to break. 
    Returns: false if the block is on the list or cannot be broken, else true. 
]]--
function break_black(blacklist)
    local temp = ge.analyze(s.front)
    for l, block in ipairs(blacklist) do 
        if temp ~= nil then 
	    if temp.name == block then
                return(false)
	    end
        end
    end
    return(r.swing())
end 

--[[ 
    Places an ender chest below the robot. Dumps the entire contents of the 
    robot's inventory into the ender chest. Then picks up the ender chest. 
    pre-condition: the robot must be placed such that the block below it is
    placeable for that robot (if no angel upgrade). 
]]--
function dump_goods()
    r.swingDown()
    set_item_self("enderstorage:ender_storage")
    r.placeDown()
    for i = 1, r.inventorySize(),  1 do
        r.select(i)
        r.dropDown()
    end
    r.swingDown()
end

--[[
    This function adds new fuel to the robot. Right now it just wraps add_coal
    so the robot needs to already have fuel in it's inventory. 
]]--
function fuel_robot()
    local temp = set_item_self(FUEL_MATERIAL)
    if temp ~= nil then add_coal() end
end


print_inventory() 
print(chunk.setActive(true))
local ii = 0
while ii < 40 do 
    ii = ii + 1
    print(i)
    print(chunk.isActive())
    tracked_right()
    if ii%2 == 1 then
        place_line_below(2,SCAFFOLD_MATERIAL)
        mine_line(SWATH_WIDTH - 1)
    else
        mine_line(SWATH_WIDTH)
    end    
    print("returning")
    tracked_right()
    tracked_right()
    break_line(SWATH_WIDTH)
    tracked_right()
    -- place the rails and move to the next set of holes. 
    if ii%POWERED_FREQ == 0 then
	place_line_below(2, "minecraft:redstone_block")
	set_item_self("minecraft:rail")
	tracked_right()
	tracked_right()
	r.place(s.front)
	tracked_right()
	tracked_right()
	place_line_below(2,SCAFFOLD_MATERIAL) 
	set_item_self("minecraft:golden_rail")
	tracked_right()
	tracked_right()
	r.place(s.front)
	tracked_right()
	tracked_right()
        ii = 0
    else
       	place_line_below(2, SCAFFOLD_MATERIAL)
	set_item_self("minecraft:rail")
	tracked_right()
	tracked_right()
	r.place(s.front)
	tracked_right()
	tracked_right()
	place_line_below(2,  SCAFFOLD_MATERIAL)
	set_item_self("minecraft:rail")
	tracked_right()
	tracked_right()
	r.place(s.front)
	tracked_right()
	tracked_right()
    end 
    os.sleep(1)
end

