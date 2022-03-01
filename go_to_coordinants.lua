

w = require("component").warpdriveShipCore

function global_cords_to_ship_cords (r0, r1, r2, x, y, z)
    local fb = 0
    local rl = 0
    local ud = y

    if r0 == 1 then
	print("case A")
	fb = x
	rl = z
    end
    if r0 == -1 then
	print("case B")
	fb = -x
	rl = -z
    end
    if r2 == 1 then
	print("case C")
	fb = z
	rl = -x
    end
    if r2 == -1 then 
	print("case D")
	fb = -z
	rl = x
    end

   return fb, rl, ud
end

-- Get desired target. 
x, y, z = w.getLocalPosition()

print("The ship is at: ", x, y, z)

print("Enter your desired X coordinant")
xf = io.read()

print("Enter your desired Y coordinant (height)")
yf = io.read()

print("Enter your desired Z Cordinant")
zf = io.read()

print("Enter your desired cruising height")
yc = io.read()

print("Heading to: ", xf, yf, zf)
print("Enter 'Y' to execute, or any other charicter to cancel")
go = io.read()

-- Start jump sequence. 

r0,  r1, r2 = w.getOrientation()

if go == 'y' or go == 'Y' then
    print("Starting jump sequence to: ",  xf, yf, zf)
end


print("Jump sequence complete")