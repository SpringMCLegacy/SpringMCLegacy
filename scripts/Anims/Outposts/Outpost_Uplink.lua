-- Orbital Uplink pieces
local antennabase, antennamast, antennareceiver, antennapole = piece ("antennabase", "antennamast", "antennareceiver", "antennapole")
local dishs = {}
for i = 1, 15 do
	dishs[i] = piece("dish" .. i)
end

local RANDOM_ROT = math.random(-180, 180)
local rad = math.rad

function Deploy()
	Move(antennabase, z_axis, -15, CRATE_SPEED * 5)
	Turn(antennamast, x_axis, rad(90), CRATE_SPEED)
	Turn(antennareceiver, x_axis, rad(-45), CRATE_SPEED * 2)
	PlaySound("uplink_whir")
	WaitForTurn(antennamast, x_axis)
	WaitForTurn(antennareceiver, x_axis)
	Move(antennapole, y_axis, 10, CRATE_SPEED * 10)
	for i = 2,15 do
		Turn(dishs[i], y_axis, rad(24), CRATE_SPEED / 4)
	end
	PlaySound("dish_deploy")
	Turn(antennabase, y_axis, rad(RANDOM_ROT), CRATE_SPEED)
	WaitForTurn(antennabase, y_axis)
	Spring.UnitScript.SetUnitValue(COB.ACTIVATION, 1)
end
