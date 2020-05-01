
local component = require("component")
local sides = require("sides")
local inventory = component.inventory_controller

--[
  A dead simple function that says hello
--]
hello_world()
  print("Hello World!")
end

print(inventory.getInventorySize(sides.back))
