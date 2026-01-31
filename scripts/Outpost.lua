-- Common pieces
local base = piece ("base")
local crateLink = piece("cratelink") or base

--include ("anims/outposts/" .. unitDef.name .. ".lua")

-- Weapon pieces
local flares = {}
local barrels = {}
local turrets = {}
local mantlets = {}

for i = 1, #unitDef.weapons do
	flares[i] = piece("flare_" .. i)
end

for i = 1,#unitDef.weapons do
	barrels[i] = piece("barrel_" .. i)
end

for i = 1,#unitDef.weapons do
	turrets[i] = piece("turret_" .. i)
	mantlets[i] = piece("mantlet_" .. i)
end

local legs = {}
for i = 1, 4 do
	legs[i] = piece("leg" .. i)
end

local screws = {}
for i = 1, 4 do
	screws[i] = piece("screw" .. i)
end

local screwheads = {}
for i = 1, 4 do
	screwheads[i] = piece("screwhead" .. i)
end

-- Constants
local name = unitDef.name
local rad = math.rad
local CRATE_SPEED = math.rad(50)
local RANDOM_ROT = math.random(-180, 180)

---------------------------------------------------------------------
-- Common functions
---------------------------------------------------------------------
local crateID
pointID = nil
beaconID = nil
function ParentBeacon(callingPointID, parentBeaconID)
	pointID = callingPointID
	beaconID = parentBeaconID
end

function Upgrade(level)
	if level == 2 then
		StartThread(Upgrade2)
	elseif level == 3 then
		StartThread(Upgrade3)
	end
end

function script.Create()
	local x,y,z = Spring.GetUnitBasePosition(unitID)
	crateID = Spring.CreateUnit("crate", x,y,z, 0, teamID, false, false)
	Spring.UnitAttach(unitID, crateID, crateLink, true)
	if Setup then
		StartThread(Setup)
	end
	Sleep(100) -- wait a few frames
	if not Spring.GetUnitTransporter(unitID) then
		Spring.SetUnitRulesParam(unitID, "beaconID", unitID)
		Unloaded()
	end
end

function Unloaded(ry)
	if crateID then
		env = Spring.UnitScript.GetScriptEnv(crateID)
		Spring.UnitScript.CallAsUnit(crateID, env.Unloaded, unitDef.isFactory and ry or nil)
	end
	StartThread(Unpack, ry)
end

function Unpack(ry)
	if unitDef.isFactory then
		-- AirCon and Vehiclepad are actual structure with yardmap as it needs factory buildoptions / commands
		-- Engine forces it to grid on unload, so turn model instead
		Turn(base, y_axis, (ry and ry - math.pi/2) or 0)
	end
	-- Wait for delivery van to bug out
	Sleep(2000)
	if crateID then
		-- Wait a little longer for the crate anim to play
		Sleep(2000)	
	end
	-- Begin outpost-specific anims
	GG.PlaySoundForTeam(Spring.GetUnitTeam(unitID), "bb_" .. name .. "_deployed", 1)
	if Deploy then
		StartThread(Deploy)
	end
	
	if crateID then
		env = Spring.UnitScript.GetScriptEnv(crateID)
		Spring.UnitScript.CallAsUnit(crateID, env.Sands)
	end
end

function script.Killed(recentDamage, maxRepairth)
	if not Spring.GetUnitTransporter(unitID) then
		GG.PlaySoundForTeam(Spring.GetUnitTeam(unitID), "bb_" .. name .. "_destroyed", 1)
	end
	if crateID and not Spring.GetUnitIsDead(crateID) then
		Spring.DestroyUnit(crateID, false, true)
	end
end

---------------------------------------------------------------------
-- Weapon functions
---------------------------------------------------------------------
if unitDef.weapons[1] then

	function script.AimWeapon(weaponID, heading, pitch)
		if noFiring then return false end
		Signal(2 ^ weaponID) -- 2 'to the power of' weapon ID
		SetSignalMask(2 ^ weaponID)
		if turrets[weaponID] then
			Turn(turrets[weaponID], y_axis, heading, CRATE_SPEED / 4)
			WaitForTurn(turrets[weaponID], y_axis)
			Turn(mantlets[weaponID], x_axis, -pitch, CRATE_SPEED / 4)
			WaitForTurn(mantlets[weaponID], x_axis)
		elseif 	name == "outpost_launcher" then
			local launcher, launchdoor1, launchdoor2, gantry, projectile = piece ("launcher", "launchdoor1", "launchdoor2", "gantry", "projectile")
			Move(launchdoor1, x_axis, 7, CRATE_SPEED * 8)
			Move(launchdoor2, x_axis, -7, CRATE_SPEED * 8)
			PlaySound("Whir_Small")
			WaitForMove(launchdoor1, x_axis)
			WaitForMove(launchdoor2, x_axis)
			Move(gantry, y_axis, 10, CRATE_SPEED * 8)
			PlaySound("Hydraulic")
			WaitForMove(gantry, y_axis)
		else
			Turn(flares[weaponID], y_axis, heading)
			Turn(flares[weaponID], x_axis, -pitch)
		end
		return true
	end

	function script.Shot(weaponID)
		EmitSfx(flares[weaponID], SFX.CEG + weaponID)
		if name == "outpost_artillery" then 
			Move(barrels[weaponID], z_axis, -25, CRATE_SPEED * 175)
			GG.EmitSfxName(unitID, base, "dust_bloom_big")
			WaitForMove(barrels[weaponID], z_axis)
			Move(barrels[weaponID], z_axis, 0, CRATE_SPEED * 25)
			StartThread(ArtilleryReload)
			WaitForMove(barrels[weaponID], z_axis)
			for i = 1,25 do
				GG.EmitSfxName(unitID, piece("flare_1"), "barrelsmoke")
				Sleep(150)
			end
		elseif 	name == "outpost_launcher" then
			LauncherClose()
		end
	end

	function script.AimFromWeapon(weaponID) 
		return flares[weaponID]
	end

	function script.QueryWeapon(weaponID) 
		return flares[weaponID]
	end

end

---------------------------------------------------------------------
-- Individualised functions
---------------------------------------------------------------------
if name == "outpost_aircon" then
	-- AirCon pieces
	local tower_mid, tower_top, ladder, antennadoor1, radardoor1, radardoor2 = piece ("tower_mid", "tower_top", "ladder", "antennadoor1", "radardoor1", "radardoor2")
	local radar_mount, radar_spin, radar_arm1, radar_arm2, antennabase, antenna1_1, antenna1_2, antenna2_1, antenna2_2 = piece ("radar_mount", "radar_spin", "radar_arm1", "radar_arm2", "antennabase", "antenna1_1", "antenna1_2", "antenna2_1", "antenna2_2")
	
	function Deploy()
		Move(tower_mid, y_axis, 7, CRATE_SPEED * 8)
		PlaySound("HeavyLift")
		WaitForMove(tower_mid, y_axis)
		Move(tower_top, y_axis, 24, CRATE_SPEED * 12)
		Turn(legs[1], z_axis, rad(90), CRATE_SPEED * 2)
		Move(legs[1], x_axis, -11, CRATE_SPEED * 8)
		Move(legs[1], y_axis, 1, CRATE_SPEED * 8)
		Turn(legs[2], x_axis, rad(90), CRATE_SPEED * 2)
		Move(legs[2], z_axis, 11, CRATE_SPEED * 8)
		Move(legs[2], y_axis, 1, CRATE_SPEED * 8)
		Turn(legs[3], z_axis, rad(-90), CRATE_SPEED * 2)
		Move(legs[3], x_axis, 11, CRATE_SPEED * 8)
		Move(legs[3], y_axis, 1, CRATE_SPEED * 8)
		Turn(legs[4], x_axis, rad(-90), CRATE_SPEED * 2)
		Move(legs[4], z_axis, -11, CRATE_SPEED * 8)
		Move(legs[4], y_axis, 1, CRATE_SPEED * 8)
		PlaySound("Hydraulic_Click")
		WaitForMove(tower_top, y_axis)
		Move(radardoor1, z_axis, 8, CRATE_SPEED * 10)
		Move(radardoor2, z_axis, -8, CRATE_SPEED * 10)
		Move(antennadoor1, z_axis, -8, CRATE_SPEED * 14)
		PlaySound("ElectricDoor")
		Sleep(50)
		PlaySound("ElectricDoor")
		WaitForMove(radardoor1, z_axis)
		Move(radar_mount, y_axis, 35, CRATE_SPEED * 18)
		Move(antennabase, y_axis, 5, CRATE_SPEED * 12)
		Move(antenna2_1, y_axis, 10, CRATE_SPEED * 12)
		PlaySound("Uplink_Whir")
		Sleep(100)
		PlaySound("Whir_Small")
		Move(antenna2_2, y_axis, 6, CRATE_SPEED * 8)
		Move(antenna1_1, y_axis, 10, CRATE_SPEED * 10)
		WaitForMove(radar_mount, y_axis)
		PlaySound("Whir_Small")
		Turn(radar_arm1, x_axis, rad(-90), CRATE_SPEED * 1)
		Turn(radar_arm2, x_axis, rad(90), CRATE_SPEED * 1)
		PlaySound("Hydraulic_Click")
		Sleep(50)
		Spin(radar_spin, y_axis, math.rad(40), math.rad(10))
		Sleep(100)
		Move(ladder, y_axis, -26, CRATE_SPEED * 32)
		PlaySound("Gear_Small")
		WaitForMove(antenna1_1, y_axis)
		Move(antenna1_2, y_axis, 11, CRATE_SPEED * 12)
		PlaySound("Whir_Small")
		Spring.UnitScript.SetUnitValue(COB.ACTIVATION, 1)
	end

elseif name == "outpost_c3array" then
	 -- C3 Pieces
	local emitterbase1, emitter1, geo1, emitterbase2, emitter2, geo2 = piece ("emitterbase1", "emitter1", "geo1", "emitterbase2", "emitter2", "geo2")
	local door1a, door1b, door2a, door2b, gendoor1, gendoor2, generator1, generator2 = piece ("door1a", "door1b", "door2a", "door2b", "gendoor1", "gendoor2", "generator1", "generator2")
	local leg1, leg2, leg3, leg4, foot1, foot2, foot3, foot4 = piece ("leg1", "leg2", "leg3", "leg4", "foot1", "foot2", "foot3", "foot4")
	
	-- C3 unpack anim
	function Deploy()
		PlaySound("Whir")
		Move(leg1, x_axis, 12, CRATE_SPEED * 10)
		Move(leg1, y_axis, -2, CRATE_SPEED * 3)
		Move(leg2, x_axis, 12, CRATE_SPEED * 10)
		Move(leg2, y_axis, -2, CRATE_SPEED * 3)
		Move(leg3, x_axis, -12, CRATE_SPEED * 10)
		Move(leg3, y_axis, -2, CRATE_SPEED * 3)
		Move(leg4, x_axis, -12, CRATE_SPEED * 10)
		Move(leg4, y_axis, -2, CRATE_SPEED * 3)
		WaitForMove(leg1, x_axis)
		WaitForMove(leg2, x_axis)
		WaitForMove(leg3, x_axis)
		WaitForMove(leg4, x_axis)
		Turn(foot1, z_axis, math.rad(-90), CRATE_SPEED * 2)
		Turn(foot2, z_axis, math.rad(-90), CRATE_SPEED * 2)
		Turn(foot3, z_axis, math.rad(90), CRATE_SPEED * 2)
		Turn(foot4, z_axis, math.rad(90), CRATE_SPEED * 2)
		PlaySound("Thunk")
		Sleep(1000)
		Move(door1a, z_axis, 10, CRATE_SPEED * 20)
		WaitForMove(door1a, z_axis)
		Move(door1b, z_axis, 15, CRATE_SPEED * 20)
		WaitForMove(door1b, z_axis)
		Move(emitterbase1, y_axis, 15, CRATE_SPEED * 10)
		WaitForMove(emitterbase1, y_axis)
		Move(emitter1, y_axis, 11.5, CRATE_SPEED * 10)
		WaitForMove(emitter1, y_axis)
		Move(gendoor1, z_axis, -12, CRATE_SPEED * 8)
		WaitForMove(gendoor1, z_axis)
		Move(generator1, x_axis, 13, CRATE_SPEED * 8)
		WaitForMove(generator1, x_axis)
		Spin(geo1, y_axis, math.rad(100), math.rad(15))
		Sleep(1000)
		GG.LanceControl(teamID, unitID, true)
		Spring.UnitScript.SetUnitValue(COB.ACTIVATION, 1)
	end

	-- C3 upgrade anim
	function Upgrade2()
		Move(door2a, z_axis, -10, CRATE_SPEED * 20)
		WaitForMove(door2a, z_axis)
		Move(door2b, z_axis, -15, CRATE_SPEED * 20)
		WaitForMove(door2b, z_axis)
		Move(emitterbase2, y_axis, 15, CRATE_SPEED * 10)
		WaitForMove(emitterbase2, y_axis)
		Move(emitter2, y_axis, 11.5, CRATE_SPEED * 10)
		WaitForMove(emitter2, y_axis)
		Move(gendoor2, z_axis, 12, CRATE_SPEED * 8)
		WaitForMove(gendoor2, z_axis)
		Move(generator2, x_axis, -13, CRATE_SPEED * 8)
		WaitForMove(generator2, x_axis)
		Spin(geo2, y_axis, math.rad(100), math.rad(15))
		Sleep(1000)
	end

elseif name == "outpost_sensor" then 

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
	
elseif name == "outpost_artillery" then
	
	function Setup()
		local barrelend, casing, rammoarm, lammoarm, rammorail, lammorail = piece ("barrelend", "casing", "rammoarm", "lammoarm", "rammorail", "lammorail")
		Move(barrelend, z_axis, -30)
		Hide(casing)
		Hide(rammoarm)
		Hide(lammoarm)
		Hide(rammorail)
		Hide(lammorail)
	end

	function Deploy()
		local barrel_1, barrelend, breechblock, hydraulic, casing = piece ("barrel_1", "barrelend", "breechblock", "hydraulic", "casing")
		local rammoarm, rammorail, rammobin, rammo, rammotray, rram = piece ("rammoarm", "rammorail", "rammobin", "rammo", "rammotray", "rram")
		local lammoarm, lammorail, lammobin, lammo, lammotray, lram = piece ("lammoarm", "lammorail", "lammobin", "lammo", "lammotray", "lram")

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

	function ArtilleryReload()
		local barrel_1, barrelend, breechblock, hydraulic, casing = piece ("barrel_1", "barrelend", "breechblock", "hydraulic", "casing")
		local rammoarm, rammorail, rammobin, rammo, rammotray, rram = piece ("rammoarm", "rammorail", "rammobin", "rammo", "rammotray", "rram")
		local lammoarm, lammorail, lammobin, lammo, lammotray, lram = piece ("lammoarm", "lammorail", "lammobin", "lammo", "lammotray", "lram")
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
	
elseif name == "outpost_launcher" then
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

	function LauncherClose()
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

elseif name == "outpost_vehiclepad" then

	-- Vehicle Pad pieces
	local ramps = {}
	local blinks = {}
	for i = 1, 6 do
		ramps[i] = piece("ramp" .. i)
		blinks[i] = piece("blink" .. i)
	end
	local base2 = piece("base2")
	local flags = piece("flags")
	
	function Setup()
		for i = 1, 6 do
			Turn(ramps[i], y_axis, rad((i-1) * -60))
		end
	end

	function Deploy()
		for i = 1, 6 do
			Turn(ramps[i], x_axis, rad(-115), CRATE_SPEED)
		end
		WaitForTurn(ramps[6], x_axis)
		StartThread(Blinks)
		GG.LCLeft(nil, unitID, teamID) -- fake call, no dropship really left
		Spring.UnitScript.SetUnitValue(COB.ACTIVATION, 1)
	end
	
	function Blinks()
		local i = 1
		while true do
			EmitSfx(blinks[i], SFX.CEG)
			Sleep(500)
			i = i + 1
			if i == 7 then i = 1 end
		end
	end

	local function CloseAnim(delay)
		for i = 1, 6 do
			Turn(ramps[i], x_axis, 0, CRATE_SPEED)
		end
		WaitForTurn(ramps[6], x_axis)
		Sleep(delay * 1000 / 30) -- convert frame-seconds to milliseconds
		for i = 1, 6 do
			Turn(ramps[i], x_axis, rad(-115), CRATE_SPEED)
		end
		WaitForTurn(ramps[6], x_axis)
	end

	function Close(delay)
		StartThread(CloseAnim, delay)
	end

elseif name == "outpost_ewar" then
	-- EWAR pieces
	local tagbase1, tagstand1, tagbase2, tagstand2 = piece("tagbase1", "tagstand1", "tagbase2", "tagstand2")
	local bapstand, bapmantlet, bapturret = piece("bapstand", "bapmantlet", "bapturret")
			
	function Setup()
		Spring.SetUnitRulesParam(unitID, "FXOFF", 1, {public = true})
		Turn(bapstand, x_axis, math.rad(-90))
		Turn(bapmantlet, x_axis, math.rad(135))	
		Turn(tagbase1, z_axis, math.rad(90))
		Turn(tagstand1, z_axis, math.rad(90))
		Turn(tagbase2, z_axis, math.rad(-90))
		Turn(tagstand2, z_axis, math.rad(-90))
	end

	function Deploy()
		local console2 = piece("console2")
		Move(console2, z_axis, 7, CRATE_SPEED)
		local bapstand, bapmantlet = piece("bapstand", "bapmantlet")
		Turn(bapstand, x_axis, 0, CRATE_SPEED/4)
		Turn(bapmantlet, x_axis, 0, CRATE_SPEED/2)
		WaitForTurn(bapstand, x_axis)
		WaitForTurn(bapmantlet, x_axis)
		WaitForMove(console2, z_axis)
		StartThread(ECM)
		Spring.UnitScript.SetUnitValue(COB.ACTIVATION, 1)
	end
	
	function Upgrade2()
		-- Angel
		local ecm, ecmdoor1, ecmdoor2, console1 = piece("ecm", "ecmdoor1", "ecmdoor2", "console1")
		Move(console1, z_axis, -7, CRATE_SPEED)
		Move(ecmdoor1, x_axis, 5, CRATE_SPEED)
		Move(ecmdoor2, x_axis, -5, CRATE_SPEED)
		WaitForMove(ecmdoor2, x_axis)
		Move(ecm, y_axis, 11, CRATE_SPEED)
		WaitForMove(ecm, y_axis)
		GG.angels[unitID] = true
	end
	
	function Upgrade3()
		-- CumOnFeelTheNoise
		Turn(tagbase1, z_axis, 0, CRATE_SPEED)
		Turn(tagbase2, z_axis, 0, CRATE_SPEED)
		WaitForTurn(tagbase2, z_axis)
		Turn(tagstand1, z_axis, 0, CRATE_SPEED)
		Turn(tagstand2, z_axis, 0, CRATE_SPEED)
		WaitForTurn(tagstand2, z_axis)

		local noiseRange = 1000
		local noiseDelay = 5000
		local noiseNum = 10
		local bx, by, bz = Spring.GetUnitBasePosition(unitID)
		local x, z
		local noiseID = Spring.CreateUnit("noise", bx,by,bz, 0, teamID, false, false)
		
		while true do
			for i = 1, noiseNum do
				-- TODO: add anim here
				x = math.max(math.min(bx + math.random(-noiseRange, noiseRange), Game.mapSizeX), 0)
				z = math.max(math.min(bz + math.random(-noiseRange, noiseRange), Game.mapSizeZ), 0)
				local y = Spring.GetGroundHeight(x, z) - 15
				Spring.SetUnitPosition(noiseID, x,y,z)
				Spring.SetUnitVelocity(noiseID, math.random() * 50, 0, math.random() * 50)
				Sleep(math.random(500, 1500))
			end
			Sleep(noiseDelay)
		end
	end
		
	function ECM()
		Sleep(2000)
		GG.SetUnitECMRadius(unitID, nil, 1000)
		while true do
			Turn(bapmantlet, x_axis, rad(math.random(-15, 15)), CRATE_SPEED/2)
			Turn(bapturret, y_axis, rad(math.random(-180, 180)), CRATE_SPEED/2)
			WaitForTurn(bapmantlet, x_axis)
			WaitForTurn(bapturret, y_axis)
			Sleep(math.random(2000, 5000))
		end
	end

elseif name == "outpost_uplink" then
	-- Orbital Uplink pieces
	local antennabase, antennamast, antennareceiver, antennapole = piece ("antennabase", "antennamast", "antennareceiver", "antennapole")
	local dishs = {}
	for i = 1, 15 do
		dishs[i] = piece("dish" .. i)
	end
	
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
	
elseif name == "outpost_turretcontrol" then
	-- Turret Control pieces
	local hatch = {}
	for i = 1, 4 do
		hatch[i] = piece("hatch" .. i)
	end
	local pole = {}
	for i = 1, 4 do
		pole[i] = piece("pole" .. i)
	end
	
	function Deploy()
		for i = 1,4 do
			local signX = i <= 2 and 1 or -1
			local signZ = (i > 1 and i < 4) and -1 or 1
			Move(hatch[i], x_axis, 6 * signX, CRATE_SPEED * 4)
			Move(hatch[i], z_axis, 6 * signZ, CRATE_SPEED * 4)
			WaitForMove(hatch[4], z_axis)
		end
		local poleHeights = {4, 3.25, 10.5, 15.5}
		 for i = 1, #pole do
			Move(pole[i], y_axis, poleHeights[i], CRATE_SPEED * 5)
		end
		WaitForMove(pole[#pole], y_axis)
		Spin(pole[1], y_axis, math.rad(20), math.rad(5))
		SetUnitValue(COB.INBUILDSTANCE, 1)
		-- use our own location, not beaconID
		local x, y, z = Spring.GetUnitPosition(unitID)
		GG.BuildMaskCircle(x, z, 460 * 1.5, 2)
		GG.UpdateTurretSlots(unitID, teamID, 4)
		Spring.UnitScript.SetUnitValue(COB.ACTIVATION, 1)
	end

elseif name == "outpost_salvageyard" then
	-- Salvage Yard pieces
	local foundation, recoveryrail, armature1, armature2 = piece ("foundation", "recoveryrail", "armature1", "armature2")
	local supporttorchattach, supporttorchupper, supporttorchmid, supporttorchlower = piece ("supporttorchattach", "supporttorchupper", "supporttorchmid", "supporttorchlower")
	local supporthandattach, supporthandupper, supporthandmid, supporthandlower, supporthandjoint, supporthandfingers1, supporthandfingers2 = piece ("supporthandattach", "supporthandupper", "supporthandmid", "supporthandlower", "supporthandjoint", "supporthandfingers1", "supporthandfingers2")
	local doora1, doora2, doorb1, doorb2, doorc1, doorc2 = piece ("doora1", "doora2", "doorb1", "doorb2", "doorc1", "doorc2")
	local doors = {}
	for i = 1, 6 do
		doors[i] = piece("door" .. i)
	end
	local armPieces = {"armattach", "armjointa", "armextender", "armjointb", "saw"}
	local arms = {}
	for i, pieceType in ipairs(armPieces) do
		arms[pieceType] = {}
	end
	for i = 1, 6 do
		for j, pieceType in ipairs(armPieces) do
			arms[pieceType][i] = piece(pieceType .. i)
		end
	end
	
	function Setup()
		Hide(foundation)
		--RecursiveHide(recoveryrail, true)
		Move(armature1, z_axis, 10)
		Move(armature2, z_axis, -10)
	end

	function Deploy()
		GG.SpawnSalvager(unitID, teamID)
		Show(foundation)
		Move(armature1, z_axis, 0, CRATE_SPEED * 2)
		Move(armature2, z_axis, 0, CRATE_SPEED * 2)
		WaitForMove(armature2, z_axis)
		--GG.PopulateQueue(unitID) -- initialise the queue with any existing corpses
		Spring.SetUnitBlocking(unitID, false, false) -- make it easy to get out
		for i = 1, 6 do
			local sign = i % 2 == 0 and -1 or 1
			Move(doors[i], z_axis, sign, CRATE_SPEED * 2)
		end
		WaitForMove(doors[6], z_axis)
		for i = 1, 6 do
			local sign = i % 2 == 1 and -1 or 1
			Turn(arms["armjointa"][i], z_axis, sign * rad(-45), CRATE_SPEED * 2)
			Turn(arms["armjointb"][i], z_axis, sign * rad(220), CRATE_SPEED * 2)
		end
		Turn(supporthandupper, z_axis, rad(45), CRATE_SPEED * 2)
		Turn(supporthandlower, z_axis, rad(-45), CRATE_SPEED * 2)
		Turn(supporttorchupper, z_axis, rad(-45), CRATE_SPEED * 2)
		Turn(supporttorchlower, z_axis, rad(45), CRATE_SPEED * 2)
		WaitForTurn(arms["armjointb"][6], z_axis)
		Turn(arms["armattach"][1], x_axis, rad(-30), CRATE_SPEED * 2)
		Turn(arms["armattach"][3], x_axis, rad(10), CRATE_SPEED * 2)
		Move(arms["armextender"][3], y_axis, 2, CRATE_SPEED * 2)
		Turn(arms["armattach"][2], x_axis, rad(10), CRATE_SPEED * 2)
		Move(arms["armextender"][2], y_axis, 2, CRATE_SPEED * 2)
		Turn(arms["armattach"][5], x_axis, rad(-20), CRATE_SPEED * 2)
		Spring.UnitScript.SetUnitValue(COB.ACTIVATION, 1)
	end

	function Upgrade2()
		Show(foundation)
		RecursiveHide(recoveryrail, false)
	end

elseif name == "outpost_mechbay" then
	-- Mechbay pieces
	local rampr, rampl, ramprfoldrear, ramprfoldfront, ramplfoldrear, ramplfoldfront = piece ("rampr", "rampl", "ramprfoldrear", "ramprfoldfront", "ramplfoldrear", "ramplfoldfront")
	local supportrlower, supportllower, supportrupper, supportlupper = piece ("supportrlower", "supportllower", "supportrupper", "supportlupper")
	local ramprtoolupper, ramprtoolmid, ramprtoollower, ramprtoolfinger1, ramprtoolfinger2 = piece ("ramprtoolupper", "ramprtoolmid", "ramprtoollower", "ramprtoolfinger1", "ramprtoolfinger2")
	local rampltoolupper, rampltoolmid, rampltoollower, rampltoolfinger1, rampltoolfinger2 = piece ("rampltoolupper", "rampltoolmid", "rampltoollower", "rampltoolfinger1", "rampltoolfinger2")
	local supportrtorchattach, supportrtorchupper, supportrtorchmid, supportrtorchlower = piece ("supportrtorchattach", "supportrtorchupper", "supportrtorchmid", "supportrtorchlower")
	local supportrhandattach, supportrhandupper, supportrhandmid, supportrhandlower, supportrhandjoint, supportrhandfingers1, supportrhandfingers2 = piece ("supportrhandattach", "supportrhandupper", "supportrhandmid", "supportrhandlower", "supportrhandjoint", "supportrhandfingers1", "supportrhandfingers2")
	local supportltorchattach, supportltorchupper, supportltorchmid, supportltorchlower = piece ("supportltorchattach", "supportltorchupper", "supportltorchmid", "supportltorchlower")
	local supportlhandattach, supportlhandupper, supportlhandmid, supportlhandlower, supportlhandjoint, supportlhandfingers1, supportlhandfingers2 = piece ("supportlhandattach", "supportlhandupper", "supportlhandmid", "supportlhandlower", "supportlhandjoint", "supportlhandfingers1", "supportlhandfingers2")
	local supportltorchspark, supportrtorchspark = piece ("supportltorchspark", "supportrtorchspark")
	local ramprtoolspark, rampltoolspark = piece ("ramprtoolspark", "rampltoolspark")

	-- Constants
	local BAY_RESTORE = 5000 -- 5 seconds
	local UNLOAD_X, UNLOAD_Z
	
	-- Variables
	local bayReady = false
	
	function Deploy()
		Spring.SetUnitBlocking(unitID, false, false) -- make it easy to get out
		MechBayOpen()
		local x, _ ,z = Spring.GetUnitPosition(unitID)
		local dx, _, dz = Spring.GetUnitDirection(unitID)
		UNLOAD_X = x + 150 * dx
		UNLOAD_Z = z + 150 * dz
		Spring.UnitScript.SetUnitValue(COB.ACTIVATION, 1)
	end


	function MechBayOpen()
		Move(rampr, x_axis, 10, CRATE_SPEED * 10)
		Move(ramprtoolupper, x_axis, 5, CRATE_SPEED * 5)
		Move(rampl, x_axis, -10, CRATE_SPEED * 10)
		Move(rampltoolupper, x_axis, -5, CRATE_SPEED * 5)
		Sleep(100)
		Turn(ramprtoolupper, x_axis, rad(90), CRATE_SPEED)
		Turn(rampltoolupper, x_axis, rad(-90), CRATE_SPEED)
		Turn(ramprtoolmid, z_axis, rad(-70), CRATE_SPEED)
		Turn(rampltoolmid, z_axis, rad(70), CRATE_SPEED)
		Turn(ramprtoollower, x_axis, rad(-90), CRATE_SPEED)
		Turn(rampltoollower, x_axis, rad(90), CRATE_SPEED)
		Turn(ramprtoolfinger1, y_axis, rad(-45), CRATE_SPEED)
		Turn(ramprtoolfinger2, y_axis, rad(45), CRATE_SPEED)
		Turn(rampltoolfinger1, y_axis, rad(-30), CRATE_SPEED)
		Turn(rampltoolfinger2, y_axis, rad(30), CRATE_SPEED)
		Move(supportrupper, y_axis, 22, CRATE_SPEED * 10)
		Move(supportlupper, y_axis, 22, CRATE_SPEED * 10)
		Sleep(100)
		Turn(ramplfoldfront, x_axis, rad(179), CRATE_SPEED)
		Turn(ramprfoldfront, x_axis, rad(179), CRATE_SPEED)
		Turn(ramplfoldrear, x_axis, rad(-179), CRATE_SPEED)
		Turn(ramprfoldrear, x_axis, rad(-179), CRATE_SPEED)
		WaitForTurn(ramprfoldrear, x_axis)
		bayReady = true
	end

	function MechBayRepair()
		SetSignalMask(1)
		while true do
			PlaySound("MechbayWorking")
			--ramptools
			Turn(ramprtoolmid, z_axis, rad(-70), CRATE_SPEED * 5)
			Turn(rampltoolmid, z_axis, rad(70), CRATE_SPEED * 5)
			--r torch
			Move(supportrtorchattach, z_axis, 5, CRATE_SPEED * 5)
			Move(supportrtorchupper, z_axis, 0, CRATE_SPEED* 5)
			Move(supportrtorchmid, y_axis, 0, CRATE_SPEED* 5)
			Turn(supportrtorchattach, z_axis, rad(45), CRATE_SPEED * 5)
			Turn(supportrtorchupper, y_axis, rad(-10), CRATE_SPEED * 5)
			Turn(supportrtorchlower, z_axis, rad(-90), CRATE_SPEED * 5)
			--l torch
			Move(supportltorchattach, z_axis, 5, CRATE_SPEED * 5)
			Move(supportltorchupper, z_axis, 0, CRATE_SPEED* 5)
			Move(supportltorchmid, y_axis, 0, CRATE_SPEED* 5)
			Turn(supportltorchattach, z_axis, rad(-45), CRATE_SPEED * 5)
			Turn(supportltorchupper, y_axis, rad(10), CRATE_SPEED * 5)
			Turn(supportltorchlower, z_axis, rad(90), CRATE_SPEED * 5)
			--r hand
			Move(supportrhandattach, z_axis, -3, CRATE_SPEED * 5)
			Turn(supportrhandupper, z_axis, rad(35), CRATE_SPEED * 5)
			Turn(supportrhandlower, z_axis, rad(-90), CRATE_SPEED * 5)
			Move(supportrhandfingers1, z_axis, -1, CRATE_SPEED * 5)
			Move(supportrhandfingers2, z_axis, 1, CRATE_SPEED * 5)
			--l hand
			Move(supportlhandattach, z_axis, -3, CRATE_SPEED * 5)
			Turn(supportlhandupper, z_axis, rad(-35), CRATE_SPEED * 5)
			Turn(supportlhandlower, z_axis, rad(90), CRATE_SPEED * 5)
			Move(supportlhandfingers1, z_axis, -1, CRATE_SPEED * 5)
			Move(supportlhandfingers2, z_axis, 1, CRATE_SPEED * 5)
			WaitForMove(supportlhandattach, z_axis)
			PlaySound("MechbayWelding")
			for i = 1, 10 do
				GG.EmitSfxName(unitID, supportltorchspark, "sparks")
				GG.EmitSfxName(unitID, supportrtorchspark, "sparks")
				GG.EmitSfxName(unitID, ramprtoolspark, "sparks")
				GG.EmitSfxName(unitID, rampltoolspark, "sparks")
				Sleep(100)
			end
			PlaySound("MechbayWorking")
			Turn(ramprtoolmid, z_axis, rad(-50), CRATE_SPEED * 5)
			Turn(rampltoolmid, z_axis, rad(30), CRATE_SPEED * 5)
			--r torch
			Move(supportrtorchattach, z_axis, 0, CRATE_SPEED* 5)
			Move(supportrtorchupper, z_axis, 3, CRATE_SPEED* 5)
			Turn(supportrtorchupper, y_axis, rad(20), CRATE_SPEED * 5)
			Turn(supportrtorchlower, z_axis, rad(-120), CRATE_SPEED * 5)
			--l torch
			Move(supportltorchattach, z_axis, 0, CRATE_SPEED* 5)
			Move(supportltorchupper, z_axis, 3, CRATE_SPEED* 5)
			Turn(supportltorchupper, y_axis, rad(20), CRATE_SPEED * 5)
			Turn(supportltorchlower, z_axis, rad(120), CRATE_SPEED * 5)
			--r hand
			Move(supportrhandattach, z_axis, 7, CRATE_SPEED * 5)
			Turn(supportrhandupper, z_axis, rad(50), CRATE_SPEED * 5)
			Turn(supportrhandlower, z_axis, rad(-120), CRATE_SPEED * 5)
			Turn(supportrhandjoint, y_axis, rad(0), CRATE_SPEED * 5)
			Move(supportrhandfingers1, z_axis, 0, CRATE_SPEED * 5)
			Move(supportrhandfingers2, z_axis, 0, CRATE_SPEED * 5)
			-- l hand
			Move(supportlhandattach, z_axis, 7, CRATE_SPEED * 5)
			Turn(supportlhandupper, z_axis, rad(-50), CRATE_SPEED * 5)
			Turn(supportlhandlower, z_axis, rad(120), CRATE_SPEED * 5)
			Turn(supportlhandjoint, y_axis, rad(0), CRATE_SPEED * 5)
			Move(supportlhandfingers1, z_axis, 0, CRATE_SPEED * 5)
			Move(supportlhandfingers2, z_axis, 0, CRATE_SPEED * 5)
			WaitForMove(supportlhandattach, z_axis)
			PlaySound("MechbayWelding")
			for i = 1, 10 do
				GG.EmitSfxName(unitID, supportltorchspark, "sparks")
				GG.EmitSfxName(unitID, supportrtorchspark, "sparks")
				GG.EmitSfxName(unitID, ramprtoolspark, "sparks")
				GG.EmitSfxName(unitID, rampltoolspark, "sparks")
				Sleep(100)
			end
			PlaySound("MechbayWorking")
			Turn(ramprtoolmid, z_axis, rad(-90), CRATE_SPEED * 5)
			Turn(rampltoolmid, z_axis, rad(10), CRATE_SPEED * 5)
			--r torch
			Move(supportrtorchattach, z_axis, -4, CRATE_SPEED * 5)
			Move(supportrtorchupper, z_axis, 2, CRATE_SPEED* 5)
			Move(supportrtorchmid, y_axis, -5, CRATE_SPEED* 5)
			Turn(supportrtorchattach, z_axis, rad(30), CRATE_SPEED * 5)
			Turn(supportrtorchupper, y_axis, rad(20), CRATE_SPEED * 5)
			Turn(supportrtorchlower, z_axis, rad(-110), CRATE_SPEED * 5)
			WaitForMove(supportrtorchattach, z_axis)
			--l torch
			Move(supportltorchattach, z_axis, -4, CRATE_SPEED * 5)
			Move(supportltorchupper, z_axis, 2, CRATE_SPEED* 5)
			Move(supportltorchmid, y_axis, -5, CRATE_SPEED* 5)
			Turn(supportltorchattach, z_axis, rad(-30), CRATE_SPEED * 5)
			Turn(supportltorchupper, y_axis, rad(10), CRATE_SPEED * 5)
			Turn(supportltorchlower, z_axis, rad(110), CRATE_SPEED * 5)
			--r hand
			Move(supportrhandattach, z_axis, 0, CRATE_SPEED * 5)
			Turn(supportrhandupper, z_axis, rad(50), CRATE_SPEED * 5)
			Turn(supportrhandlower, z_axis, rad(-40), CRATE_SPEED * 5)
			Turn(supportrhandjoint, y_axis, rad(90), CRATE_SPEED * 5)
			Move(supportrhandfingers1, z_axis, 1, CRATE_SPEED * 5)
			Move(supportrhandfingers2, z_axis, -1, CRATE_SPEED * 5)
			--l hand
			Move(supportlhandattach, z_axis, 0, CRATE_SPEED * 5)
			Turn(supportlhandupper, z_axis, rad(-50), CRATE_SPEED * 5)
			Turn(supportlhandlower, z_axis, rad(40), CRATE_SPEED * 5)
			Turn(supportlhandjoint, y_axis, rad(-90), CRATE_SPEED * 5)
			Move(supportlhandfingers1, z_axis, 1, CRATE_SPEED * 5)
			Move(supportlhandfingers2, z_axis, -1, CRATE_SPEED * 5)
			WaitForMove(supportlhandattach, z_axis)
			PlaySound("MechbayWelding")
			for i = 1, 10 do
				GG.EmitSfxName(unitID, supportltorchspark, "sparks")
				GG.EmitSfxName(unitID, supportrtorchspark, "sparks")
				GG.EmitSfxName(unitID, ramprtoolspark, "sparks")
				GG.EmitSfxName(unitID, rampltoolspark, "sparks")
				Sleep(100)
			end
		end
	end

	function MechBayClose()
		bayReady = false
		script.TransportDrop()
		Signal(BAY_RESTORE)
		SetSignalMask(BAY_RESTORE)
		Turn(ramplfoldfront, x_axis, 0, CRATE_SPEED)
		Turn(ramprfoldfront, x_axis, 0, CRATE_SPEED)
		Turn(ramplfoldrear, x_axis, 0, CRATE_SPEED)
		Turn(ramprfoldrear, x_axis, 0, CRATE_SPEED)
		Sleep(100)
		Turn(ramprtoolupper, x_axis, 0, CRATE_SPEED)
		Turn(rampltoolupper, x_axis, 0, CRATE_SPEED)
		Turn(ramprtoolmid, z_axis, 0, CRATE_SPEED)
		Turn(rampltoolmid, z_axis, 0, CRATE_SPEED)
		Turn(ramprtoollower, x_axis, 0, CRATE_SPEED)
		Turn(rampltoollower, x_axis, 0, CRATE_SPEED)
		Turn(ramprtoolfinger1, y_axis, 0, CRATE_SPEED)
		Turn(ramprtoolfinger2, y_axis, 0, CRATE_SPEED)
		Turn(rampltoolfinger1, y_axis, 0, CRATE_SPEED)
		Turn(rampltoolfinger2, y_axis, 0, CRATE_SPEED)
		Move(supportrupper, y_axis, 0, CRATE_SPEED * 10)
		Move(supportlupper, y_axis, 0, CRATE_SPEED * 10)
		Sleep(100)	
		Move(rampr, x_axis, 0, CRATE_SPEED * 10)
		Move(ramprtoolupper, x_axis, 0, CRATE_SPEED * 5)
		Move(rampl, x_axis, 0, CRATE_SPEED * 10)
		Move(rampltoolupper, x_axis, 0, CRATE_SPEED * 5)	
		WaitForMove(rampr, x_axis)
		Sleep(BAY_RESTORE)
		MechBayOpen()
	end

	function script.HitByWeapon()
		StartThread(MechBayClose)
	end
	
	-- Localisations
	local GetUnitDefID	= Spring.GetUnitDefID
	local GetUnitHealth	= Spring.GetUnitHealth
	local SetUnitHealth	= Spring.SetUnitHealth
	-- Constants
	local REPAIR_RATE = 0.05
	local LIMB_REPAIR_RATE = REPAIR_RATE
	-- Variables
	local passengerDefID
	local passengerInfo
	local passengerEnv

	local repaired = false
	local resupplied = false
	local restored = false

	local restoredLimbs = {}
	local suppliedAmmos = {}

	autoGetOut = true

	local SIG_EXIT = 1

	function Repair(passengerID)
		SetSignalMask(SIG_EXIT)
		StartThread(MechBayRepair)
		local curHP, maxHP = GetUnitHealth(passengerID)
		while curHP ~= maxHP do
			local newHP = math.min(curHP + maxHP * REPAIR_RATE, maxHP)
			SetUnitHealth(passengerID, newHP)
			--curHP, maxHP = GetUnitHealth(passengerID)
			curHP, maxHP = GetUnitHealth(passengerID)
			Sleep(1000)
		end
		repaired = true
		if autoGetOut and resupplied and restored then -- I'm the last task to finish, move out!
			Sleep(5000) -- always wait 5 seconds before shoving the mech out
			if autoGetOut then script.TransportDrop(passengerID) end -- check again
		end
	end


	function RestoreLimb(passengerID, limb, maxHP)
		restoredLimbs[limb] = false -- so the loop has something to go over
		local curHP = passengerEnv.limbHPControl(limb, 0)
		while curHP ~= maxHP do
			curHP = passengerEnv.limbHPControl(limb, -maxHP * LIMB_REPAIR_RATE)
			Sleep(1000)
		end
		restoredLimbs[limb] = true
	end

	function Restore(passengerID)
		SetSignalMask(SIG_EXIT)
		local limbHPs = passengerInfo.limbHPs
		if passengerEnv.limbHPControl then -- N.B. currently this runs for all mechs
			for limb, maxHP in pairs(limbHPs) do
				restoredLimbs[limb] = false
				StartThread(RestoreLimb, passengerID, limb, maxHP)
			end
		end
		while not restored do
			local allDone = true
			for limb, done in pairs(restoredLimbs) do
				allDone = allDone and done
			end
			restored = allDone
			Sleep(1000)
		end
		if autoGetOut and repaired and resupplied then -- I'm the last task to finish, move out!
			Sleep(5000) -- always wait 5 seconds before shoving the mech out
			if autoGetOut then script.TransportDrop(passengerID) end -- check again
		end	
	end

	function ResupplyAmmoType(passengerID, weaponNum, ammoType)
		if ammoType then
			suppliedAmmos[ammoType] = false -- so the loop has something to go over
			local moreToDo = true
			while moreToDo do
				local amount = passengerInfo.burstLengths[weaponNum] or 1
				local tookSome = passengerEnv.ChangeAmmo(ammoType, amount)
				--if tookSome then Spring.Echo("Deduct " .. amount .. " " .. ammoType) end
				moreToDo = moreToDo and tookSome
				Sleep(1000)
			end
			suppliedAmmos[ammoType] = true
		end
	end

	function Resupply(passengerID)
		SetSignalMask(SIG_EXIT)
		local ammoTypes = passengerInfo.ammoTypes
		if passengerEnv.ChangeAmmo then
			for weaponNum, ammoType in pairs(ammoTypes) do
				StartThread(ResupplyAmmoType, passengerID, weaponNum, ammoType)
			end
		end
		while not resupplied do
			local allDone = true
			for ammoType, done in pairs(suppliedAmmos) do
				allDone = allDone and done
			end
			resupplied = allDone
			Sleep(1000)
		end
		if autoGetOut and repaired and restored then -- I'm the last task to finish, move out!
			Sleep(5000) -- always wait 5 seconds before shoving the mech out
			if autoGetOut then script.TransportDrop(passengerID) end -- check again
		end	
	end

	function script.TransportPickup (passengerID)
		if bayReady then
			repaired = false
			resupplied = false
			restored = false
			passengerDefID = GetUnitDefID(passengerID)
			passengerInfo = GG.lusHelper[passengerDefID]
			passengerEnv = Spring.UnitScript.GetScriptEnv(passengerID)
			if passengerEnv then
				Spring.UnitScript.CallAsUnit(passengerID, passengerEnv.script.StopMoving)
			end
			-- TODO: pickup animation
			Spring.UnitScript.AttachUnit(base, passengerID)
			bayReady = false
			StartThread(Repair, passengerID)
			StartThread(Resupply, passengerID)
			StartThread(Restore, passengerID)
		end
	end

	function script.TransportDrop (passengerID, x, y, z)
		local isTransporting = Spring.GetUnitIsTransporting(unitID)
		if isTransporting and #isTransporting > 0 then
			Signal(1) -- kill repair anim & threads
			passengerID = passengerID or isTransporting[1]
			Spring.UnitScript.DropUnit(passengerID)
			bayReady = true
			Spring.SetUnitMoveGoal(passengerID, UNLOAD_X, 0, UNLOAD_Z, 50) -- bug out over here
			-- reset states
			repaired = false
			resupplied = false
			restored = false
		end
		autoGetOut = true
	end

end