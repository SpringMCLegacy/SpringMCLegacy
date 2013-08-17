--pieces
local base = piece ("base")

local crate_base, crate_top, crate_right, crate_left, crate_front, crate_back = piece ("crate_base", "crate_top", "crate_right", "crate_left", "crate_front", "crate_back")

-- includes
local rad = math.rad
local CRATE_SPEED = math.rad(200)

function script.Create()
end

function Unpack()
	-- TODO: Unpack anim goes here!
	-- TODO: Don't forget to Move(crate_base, y_axis, -SOME_NUMBER, SOME_SLOW_SPEED) :)
	Turn(crate_front, x_axis, rad(45), CRATE_SPEED)
	Turn(crate_back, x_axis, rad(-45), CRATE_SPEED)
	Turn(crate_left, z_axis, rad(-45), CRATE_SPEED)
	Turn(crate_right, z_axis, rad(45), CRATE_SPEED)
	sleep(50)
	Turn(crate_front, x_axis, rad(90), CRATE_SPEED * 4)
	Turn(crate_back, x_axis, rad(-90), CRATE_SPEED * 4)
	Turn(crate_left, z_axis, rad(-90), CRATE_SPEED * 4)
	Turn(crate_right, z_axis, rad(90), CRATE_SPEED * 4)
	
end

function script.Killed(recentDamage, maxHealth)
end
