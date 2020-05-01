
local component = require("component")
local sides = require("sides")
local inventory = component.inventory_controller

--[[
  A dead simple function that says hello
--]]
hello_world()
  print("Hello World!")
end

--[[
  Find the first instance of the specified item in this device's general 
  inventory. This function does not set a new selected slot. 
  returns: number of first slot containing item, 0 if none found. 
]]--
find_item_self(item)
  for i = 1, inventory.getInventorySize(sides.back)
    temp = inventory.getStackInSlot(side.back, i) --lets see what we have found.
    if(temp.name == item)
      print("found")
    end
  end
end

print(inventory.getInventorySize(sides.back))
find_item_self("minecraft:dirt")
