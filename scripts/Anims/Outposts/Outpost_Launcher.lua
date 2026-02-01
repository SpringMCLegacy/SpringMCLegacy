-- Cruise Missile Launcher pieces
local launcher, launchdoor1, launchdoor2, gantry, projectile = piece ("launcher", "launchdoor1", "launchdoor2", "gantry", "projectile")

function Deploy()	
	PlaySound("Clicks")
	for i = 1, 2 do
		Turn(legs[i], z_axis, math.rad(90), CRATE_SPEED * 4)
	end
	for i = 3, 4 do
		Turn(legs[i], z_axis, math.rad(-90), CRATE_SPEED * 4)
	end
	Sleep(400)
	PlaySound("Thunk")
	Sleep(500)
	for i = 1,4 do
		Spin(screwheads[i], x_axis, math.rad(200), math.rad(25))
	end
	for i = 1,4 do	
		Move(screws[i], y_axis, -10, CRATE_SPEED * 12)
	end
	PlaySound("Drill")
	Sleep(2500)
	for i = 1,4 do
		StopSpin(screwheads[i], x_axis, math.rad(100))
	end
	Sleep(500)
	noFiring = false
	Spring.SetUnitRulesParam(unitID, "weapon_1", "active")
	Spring.UnitScript.SetUnitValue(COB.ACTIVATION, 1)
end

function Reload()
	Hide(projectile)
	Sleep(1000)
	Move(gantry, y_axis, 0, CRATE_SPEED * 8)
	PlaySound("Hydraulic")
	WaitForMove(gantry, y_axis)
	Move(launchdoor1, x_axis, 0, CRATE_SPEED * 8)
	Move(launchdoor2, x_axis, 0, CRATE_SPEED * 8)
	PlaySound("Whir_Small")
	WaitForMove(launchdoor1, x_axis)
	WaitForMove(launchdoor2, x_axis)
	Sleep(500)
	Show(projectile)
end	
