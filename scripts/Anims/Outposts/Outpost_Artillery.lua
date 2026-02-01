-- Artillery pieces
local barrel_1, barrelend, breechblock, hydraulic, casing = piece ("barrel_1", "barrelend", "breechblock", "hydraulic", "casing")
local rammoarm, rammorail, rammobin, rammo, rammotray, rram = piece ("rammoarm", "rammorail", "rammobin", "rammo", "rammotray", "rram")
local lammoarm, lammorail, lammobin, lammo, lammotray, lram = piece ("lammoarm", "lammorail", "lammobin", "lammo", "lammotray", "lram")
	
function Setup()
	Move(barrelend, z_axis, -30)
	Hide(casing)
	Hide(rammoarm)
	Hide(lammoarm)
	Hide(rammorail)
	Hide(lammorail)
end

function Deploy()
	Show(rammoarm)
	Show(lammoarm)
	Show(rammorail)
	Show(lammorail)
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
	PlaySound("Whir")
	Move(barrelend, z_axis, 0, CRATE_SPEED * 15)
	WaitForMove(barrelend, z_axis)
	noFiring = false
	Spring.SetUnitRulesParam(unitID, "weapon_1", "active")
	Spring.UnitScript.SetUnitValue(COB.ACTIVATION, 1)
end

function Reload()
	local rad = math.rad
	--RELOAD anim
	Sleep(1000)
	--Open breech and eject used casing
	Turn(breechblock, x_axis, rad(90), CRATE_SPEED * 4)
	PlaySound("Breech_Open")
	WaitForTurn(breechblock, x_axis)
	Explode(piece("casing"), SFX.SMOKE + SFX.FALL)
	Sleep(500)
	--Pull out trays
	Move(lammotray, z_axis, -17, CRATE_SPEED * 20)
	Move(rammotray, z_axis, -17, CRATE_SPEED * 20)
	PlaySound("Gear_Small")
	WaitForMove(lammotray, z_axis)
	WaitForMove(rammotray, z_axis)
	Sleep(200)
	--Right Tray projectile
	PlaySound("Whir_Small")
	Turn(rammoarm, y_axis, rad(-90), CRATE_SPEED * 4)
	Turn(rammorail, y_axis, rad(90), CRATE_SPEED * 4)
	WaitForTurn(rammoarm, y_axis)
	Turn(rammoarm, y_axis, rad(-180), CRATE_SPEED * 4)
	Turn(rammorail, y_axis, rad(180), CRATE_SPEED * 4)
	WaitForTurn(rammoarm, y_axis)
	Move(rram, z_axis, 10, CRATE_SPEED * 20)
	PlaySound("Hydraulic")
	WaitForMove(rram, z_axis)
	Hide(rammo)
	PlaySound("Shell")
	Sleep(500)
	Move(rram, z_axis, 0, CRATE_SPEED * 20)
	PlaySound("Hydraulic")
	WaitForMove(rram, z_axis)
	Sleep(200)
	PlaySound("Whir_Small")
	Turn(rammoarm, y_axis, rad(-90), CRATE_SPEED * 4)
	Turn(rammorail, y_axis, rad(90), CRATE_SPEED * 4)
	WaitForTurn(rammoarm, y_axis)
	Turn(rammoarm, y_axis, rad(0), CRATE_SPEED * 4)
	Turn(rammorail, y_axis, rad(0), CRATE_SPEED * 4)
	WaitForTurn(rammoarm, y_axis)
	Sleep(200)
	
	--Left Tray, Propellant
	PlaySound("Whir_Small")
	Turn(lammoarm, y_axis, rad(90), CRATE_SPEED * 4)
	Turn(lammorail, y_axis, rad(-90), CRATE_SPEED * 4)
	WaitForTurn(lammoarm, y_axis)
	Turn(lammoarm, y_axis, rad(180), CRATE_SPEED * 4)
	Turn(lammorail, y_axis, rad(-180), CRATE_SPEED * 4)
	WaitForTurn(lammoarm, y_axis)
	Move(lram, z_axis, 10, CRATE_SPEED * 20)
	PlaySound("Hydraulic")
	WaitForMove(lram, z_axis)
	Hide(lammo)
	PlaySound("Shell")
	Sleep(500)
	Move(lram, z_axis, 0, CRATE_SPEED * 20)
	PlaySound("Hydraulic")
	WaitForMove(lram, z_axis)
	Sleep(200)
	PlaySound("Whir_Small")
	Turn(lammoarm, y_axis, rad(90), CRATE_SPEED * 4)
	Turn(lammorail, y_axis, rad(-90), CRATE_SPEED * 4)
	WaitForTurn(lammoarm, y_axis)
	Turn(lammoarm, y_axis, rad(0), CRATE_SPEED * 4)
	Turn(lammorail, y_axis, rad(0), CRATE_SPEED * 4)
	WaitForTurn(lammoarm, y_axis)
	Sleep(200)
	--END RELOAD anim
	
	Turn(breechblock, x_axis, rad(0), CRATE_SPEED * 4)
	PlaySound("Breech_Close")
	Sleep(100)
	Move(lammotray, z_axis, 0, CRATE_SPEED * 20)
	Move(rammotray, z_axis, 0, CRATE_SPEED * 20)
	PlaySound("Gear_Small")
	WaitForMove(lammotray, z_axis)
	WaitForMove(rammotray, z_axis)
	Show(rammo)
	Show(lammo)
	WaitForTurn(breechblock, x_axis)
	Sleep(500)
end
	