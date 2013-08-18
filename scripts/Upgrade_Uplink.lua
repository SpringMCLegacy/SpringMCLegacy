--pieces
local base = piece ("base")

local crate_base, crate_top, crate_right, crate_left, crate_front, crate_back = piece ("crate_base", "crate_top", "crate_right", "crate_left", "crate_front", "crate_back")
local antennabase, antennamast, antennareceiver, antennapole = piece ("antennabase", "antennamast", "antennareceiver", "antennapole")
local dish1, dish2, dish3, dish4, dish5, dish6, dish7, dish8, dish9, dish10, dish11, dish12, dish13, dish14, dish15 = piece ("dish1", "dish2", "dish3", "dish4", "dish5", "dish6", "dish7", "dish8", "dish9", "dish10", "dish11", "dish12", "dish13", "dish14", "dish15")

-- includes
local rad = math.rad
local CRATE_SPEED = math.rad(50)
local RANDOM_ROT = math.random(-180, 180)

function script.Create()
end

function Unloaded()
	StartThread(Unpack)
end

function Unpack()
	-- TODO: Unpack anim goes here!
	-- TODO: Don't forget to Move(crate_base, y_axis, -SOME_NUMBER, SOME_SLOW_SPEED) :)
	Turn(crate_front, x_axis, rad(45), CRATE_SPEED)
	Turn(crate_back, x_axis, rad(-45), CRATE_SPEED)
	Turn(crate_left, z_axis, rad(45), CRATE_SPEED)
	Turn(crate_right, z_axis, rad(-45), CRATE_SPEED)
	WaitForTurn(crate_right, z_axis)
	WaitForTurn(crate_left, z_axis)
	WaitForTurn(crate_back, x_axis)
	WaitForTurn(crate_front, x_axis)
	Turn(crate_front, x_axis, rad(90), CRATE_SPEED * 2)
	Turn(crate_back, x_axis, rad(-90), CRATE_SPEED * 2)
	Turn(crate_left, z_axis, rad(90), CRATE_SPEED * 2)
	Turn(crate_right, z_axis, rad(-90), CRATE_SPEED * 2)
	WaitForTurn(crate_right, z_axis)
	WaitForTurn(crate_left, z_axis)
	WaitForTurn(crate_back, x_axis)
	WaitForTurn(crate_front, x_axis)
	Turn(crate_top, z_axis, rad(-45), CRATE_SPEED)
	WaitForTurn(crate_top, z_axis)
	Turn(crate_top, z_axis, rad(-90), CRATE_SPEED * 2)
	Move(antennabase, z_axis, -15, CRATE_SPEED * 5)
	Turn(antennamast, x_axis, rad(90), CRATE_SPEED)
	Turn(antennareceiver, x_axis, rad(-45), CRATE_SPEED * 2)
	WaitForTurn(antennamast, x_axis)
	WaitForTurn(antennareceiver, x_axis)
	Move(antennapole, y_axis, 10, CRATE_SPEED * 10)
	Turn(dish2, y_axis, rad(24), CRATE_SPEED / 4)
	Turn(dish3, y_axis, rad(24), CRATE_SPEED / 4)
	Turn(dish4, y_axis, rad(24), CRATE_SPEED / 4)
	Turn(dish5, y_axis, rad(24), CRATE_SPEED / 4)
	Turn(dish6, y_axis, rad(24), CRATE_SPEED / 4)
	Turn(dish7, y_axis, rad(24), CRATE_SPEED / 4)
	Turn(dish8, y_axis, rad(24), CRATE_SPEED / 4)
	Turn(dish9, y_axis, rad(24), CRATE_SPEED / 4)
	Turn(dish10, y_axis, rad(24), CRATE_SPEED / 4)
	Turn(dish11, y_axis, rad(24), CRATE_SPEED / 4)
	Turn(dish12, y_axis, rad(24), CRATE_SPEED / 4)
	Turn(dish13, y_axis, rad(24), CRATE_SPEED / 4)
	Turn(dish14, y_axis, rad(24), CRATE_SPEED / 4)
	Turn(dish15, y_axis, rad(24), CRATE_SPEED / 4)
	Turn(antennabase, y_axis, rad(RANDOM_ROT), CRATE_SPEED)
	Sleep(10000)
	Move(crate_base, y_axis, -5, CRATE_SPEED)
	Sleep (5000)
	RecursiveHide(crate_base, true)
end

function script.Killed(recentDamage, maxHealth)
end
