
local component = require("component")
local sides = require("sides")
local inventory = component.inventory_controller
local r = require("robot")
local g = require("generator")

--[[
  A dead simple function that says hello
--]]
function hello_world()
  print("Hello World!")
end


--[[ 
  Locates the specified item in inentory and selects that slot.
  if the slot cannot be found then no change is made. 
  returns: slot number if found, 0 if not found. 
--]]
function set_item_self(item)
  local temp = find_item_self(item)
  if temp then 
    r.select(temp)
    return(temp)
  else 
    return(nil)
  end
end





--[[
  Find the first instance of the specified item in this device's general 
  inventory. This function does not set a new selected slot. 
  returns: number of first slot containing item, 0 if none found. 
]]--
function find_item_self(item)
  for i = 1, r.inventorySize() do
    temp = inventory.getStackInSlot(side.back, i) --lets see what we have found.
    if(temp ~= nil and temp.name == item) then
      print("found")
      return(i)
    end
  end
  return(nil) -- we did not find the object.
end


--[[
  This function tops up the generator with coal. It is safe to call if the
  generator is already full, and should be called often as a result. 
  
  Note: This is not designed to work in a mixed-fuel environment. Only coal 
  will be added. 

  returns: true if generator full or filled, false if no coal is found.
]]--
function add_coal()
  if count() < 64 then
    if set_item_self("minecraft:coal") then
      g.insert(64) --add fuel to the generator
      return('true')
    else
      error("no coal found")
      return(false)
    end
  end
  return(true) --generator already full

print(inventory.getInventorySize(sides.front))
find_item_self("minecraft:dirt")
print(add_coal)
