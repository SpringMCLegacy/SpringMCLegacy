--pieces
local base = piece ("base")

local crate_base, crate_top, crate_right, crate_left, crate_front, crate_back = piece ("crate_base", "crate_top", "crate_right", "crate_left", "crate_front", "crate_back")
local antennarot, antenna1, antenna2, antenna3, emitter, geo = piece ("antennarot", "antenna1", "antenna2", "antenna3", "emitter", "geo")
-- includes
local rad = math.rad
local CRATE_SPEED = math.rad(50)

function script.Create()
end

function Unloaded()
	StartThread(Unpack)
end

function Unpack()
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
	Move(emitter, y_axis, 30, CRATE_SPEED * 5)
	Turn(antennarot, x_axis, rad(-90), CRATE_SPEED)
	WaitForTurn(antennarot, x_axis)
	Move(antenna1, z_axis, 20, CRATE_SPEED * 10)
	Move(antenna2, z_axis, 20, CRATE_SPEED * 10)
	Move(antenna3, z_axis, 20, CRATE_SPEED * 10)
	WaitForMove(emitter, y_axis)
	Spin(geo, y_axis, math.rad(20), math.rad(5))
	-- We're deployed, grant the extra tonnage
	Spring.AddTeamResource(Spring.GetUnitTeam(unitID), "energy", 200)
	Sleep(10000)
	Move(crate_base, y_axis, -5, CRATE_SPEED)
	Sleep (5000)
	RecursiveHide(crate_base, true)
end

function script.Killed(recentDamage, maxHealth)
end
