-- Sensor Array Pieces
local radarbase, radarlift, radarspin, radardish, radarpoke, dishflapl, dishflapr = piece ("radarbase", "radarlift", "radarspin", "radardish", "radarpoke", "dishflapl", "dishflapr")
local console1, console2, bloodhounddoor1, bloodhounddoor2, bloodhound  = piece ("console1", "console2", "bloodhounddoor1", "bloodhounddoor2", "bloodhound")
local hammerdoor1, hammerdoor2, hammermount, hammerarm1, hammerarm2, hammerhousing, hammer  = piece ("hammerdoor1", "hammerdoor2", "hammermount", "hammerarm1", "hammerarm2", "hammerhousing", "hammer")

function Setup()
	Turn(hammerarm1, x_axis, math.rad(25))
	Turn(hammerhousing, x_axis, math.rad(-100))
end

function Deploy()
	Move(radarlift, y_axis, 8, CRATE_SPEED * 4)
	PlaySound("HeavyLift")
	WaitForMove(radarlift, y_axis)
	Turn(radardish, z_axis, math.rad(90), CRATE_SPEED * 1)
	PlaySound("Whir")
	Sleep(900)
	Turn(dishflapr, x_axis, math.rad(55), CRATE_SPEED * 1)
	Turn(dishflapl, x_axis, math.rad(-55), CRATE_SPEED * 1)
	PlaySound("Whir_Small")
	WaitForTurn(dishflapr, x_axis)
	Move(radarpoke, x_axis, 8.4, CRATE_SPEED * 4)
	Move(radarpoke, y_axis, 1.5, CRATE_SPEED * 1)
	PlaySound("Gear_Small")
	Sleep(400)
	Move(console1, x_axis, 7, CRATE_SPEED * 3)
	Move(console2, x_axis, -7, CRATE_SPEED * 3)
	PlaySound("Gear_Small")
	Sleep(700)
	Spin(radarspin, y_axis, math.rad(100), math.rad(15))
	WaitForMove(console1, x_axis)
	Spring.UnitScript.SetUnitValue(COB.ACTIVATION, 1)
end

function Upgrade2()
	-- Bloodound AP
	Move(bloodhounddoor1, x_axis, 6, CRATE_SPEED * 4)
	Move(bloodhounddoor2, x_axis, -6, CRATE_SPEED * 4)
	PlaySound("ElectricDoor")
	WaitForMove(bloodhounddoor1, x_axis)
	Move(bloodhound, y_axis, 12, CRATE_SPEED * 5)
	PlaySound("HeavyLift")
	WaitForMove(bloodhound, y_axis)
	Sleep(1000)
	GG.bloodHounds[unitID] = true
end

function Upgrade3()
	-- Seismic
	Move(hammerdoor1, x_axis, 6, CRATE_SPEED * 4)
	Move(hammerdoor2, x_axis, -6, CRATE_SPEED * 4)
	PlaySound("ElectricDoor")
	WaitForMove(hammerdoor1, x_axis)
	Move(hammermount, z_axis, 5, CRATE_SPEED * 4)
	Move(hammerarm2, z_axis, 2.5, CRATE_SPEED * 2)
	PlaySound("Whir_Small")
	WaitForMove(hammermount, z_axis)
	Sleep(100)
	Turn(hammerarm1, x_axis, 0, CRATE_SPEED * 1)
	Turn(hammerhousing, x_axis, math.rad(-25), CRATE_SPEED * 1)
	PlaySound("Whir")
	PlaySound("HeavyLift")
	WaitForTurn(hammerhousing, x_axis)
	Sleep(100)
	Turn(hammerhousing, x_axis, 0, CRATE_SPEED * 1)
	Move(hammermount, z_axis, 0, CRATE_SPEED * 4)
	Move(hammermount, y_axis, -2, CRATE_SPEED * 4)
	PlaySound("Hydraulic_Click")
	Sleep(300)
	PlaySound("Thunk")
	StartThread(SeismicPings)
end

function SeismicPings()
	seismicRange = 50000 -- unitDef.seismicRadius
	seismicDelay = 5000
	seismicDuration = 500
	
	-- initial raise
	Move(hammer, y_axis, 7, CRATE_SPEED * 5)
	WaitForMove(hammer, y_axis)
	local spike = piece("spike")
	while true do
		Move(hammer, y_axis, 0, CRATE_SPEED * 50)
		WaitForMove(hammer, y_axis)
		PlaySound("seismicstomp")
		GG.EmitSfxName(unitID, spike, "mech_jump_dust")
		Spring.SetUnitSensorRadius(unitID, "seismic", seismicRange)
		Sleep(seismicDuration)
		Move(hammer, y_axis, 7, CRATE_SPEED * 5)
		WaitForMove(hammer, y_axis)
		Spring.SetUnitSensorRadius(unitID, "seismic", 0)
		Sleep(seismicDelay)
	end
end