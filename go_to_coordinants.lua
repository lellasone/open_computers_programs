

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

   return fb, ud, lr
end

function set_jump_distance (desired_jump, max_jump)
    local j = 0
    local final = false
    if desired_jump > max_jump then
	j = max_jump
    elseif desired_jump < -1 * max_jump then
	j = -1 * max_jump
    else 
        j = desired_jump
        final = true
    end
    return j, final
end


-- Get desired target. 
x, y, z = w.getLocalPosition()

-- Get ship jump range.
w.movement(0,0,0)
w.command("MANUAL",false)
success, max_jump = w.getMaxJumpDistance()

print("The ship is at: ", x, y, z)
print("The ship has jump range: ", max_jump)

print("Enter your desired X coordinant")
xf = io.read()

print("Enter your desired Y coordinant (height)")
yf = io.read()

print("Enter your desired Z Cordinant")
zf = io.read()

print("Enter your desired cruising height")
yc = io.read()

-- Calculate approximate jumps required
jumps = math.sqrt((xf - x)*(xf-x) + (zf - z)*(zf - z))/max_jump

print("Heading to: ", xf, yf, zf)
print("Rough jump count estimate: ",  jumps)
print("Enter 'Y' to execute, or any other charicter to cancel")
go = io.read()

-- Start jump sequence. 


local last= False
local first = True
if go == 'y' or go == 'Y' then
    while not last do 
        print("Starting jump sequence to: ",  xf, yf, zf)
	    r0,  r1, r2 = w.getOrientation()
            x, y, z = w.getLocalPosition()

	    dx = xf - x
	    dz = zf - z
	    jy = 0
	print(dz)
	jx, x_final = set_jump_distance(dx, max_jump)
	jz, z_final = set_jump_distance(dz, max_jump)
	if z_final and x_final then last = true end
	
	jy = yc - y
        if last then 
	    jy = yf - y
	end
	print(jz)
	fb, ud, lr = global_cords_to_ship_cords(r0, r1, r2, jx, jy, jz)
	print("Executing the following jump (fb, ud, lr): ", fb, ud, lr)
	
	-- command the jump
	w.movement(fb, ud, lr)
	w.rotationSteps(0)
	w.command("MANUAL", true)
	os.sleep(10)
	
    end
    print("Jump sequence complete")
else
    print("Ending program")
end
