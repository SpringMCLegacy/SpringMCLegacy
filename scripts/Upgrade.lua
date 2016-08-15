-- Common pieces
local base = piece ("base")
local crate_base, crate_top, crate_right, crate_left, crate_front, crate_back = piece ("crate_base", "crate_top", "crate_right", "crate_left", "crate_front", "crate_back")
-- C3 pieces
local antennarot, antenna1, antenna2, antenna3, emitter, geo = piece ("antennarot", "antenna1", "antenna2", "antenna3", "emitter", "geo")
-- Mechbay pieces
local rampr, rampl, ramprfoldrear, ramprfoldfront, ramplfoldrear, ramplfoldfront = piece ("rampr", "rampl", "ramprfoldrear", "ramprfoldfront", "ramplfoldrear", "ramplfoldfront")
local supportrlower, supportllower, supportrupper, supportlupper = piece ("supportrlower", "supportllower", "supportrupper", "supportlupper")
local ramprtoolupper, ramprtoolmid, ramprtoollower, ramprtoolfinger1, ramprtoolfinger2 = piece ("ramprtoolupper", "ramprtoolmid", "ramprtoollower", "ramprtoolfinger1", "ramprtoolfinger2")
local rampltoolupper, rampltoolmid, rampltoollower, rampltoolfinger1, rampltoolfinger2 = piece ("rampltoolupper", "rampltoolmid", "rampltoollower", "rampltoolfinger1", "rampltoolfinger2")
-- Orbital Uplink pieces
local antennabase, antennamast, antennareceiver, antennapole = piece ("antennabase", "antennamast", "antennareceiver", "antennapole")
local dishs = {}
for i = 1, 15 do
	dishs[i] = piece("dish" .. i)
end
-- Vehicle Pad pieces
local ramps = {}
local blinks = {}
for i = 1, 6 do
	ramps[i] = piece("ramp" .. i)
	blinks[i] = piece("blink" .. i)
end
local base2 = piece("base2")
local flags = piece("flags")
-- Seismic Sensor pieces
local foot1, foot2, foot3, lifter, hammer, spike = piece ("foot1", "foot2", "foot3", "lifter", "hammer", "spike")
-- Turret Control pieces
local hatch = {}
for i = 1, 4 do
	hatch[i] = piece("hatch" .. i)
end
local pole = {}
for i = 1, 4 do
	pole[i] = piece("pole" .. i)
end
-- Garrison pieces
local flares = {}
for i = 1, 6 do
	flares[i] = piece("flare_" .. i)
end

-- Constants
local unitDefID = Spring.GetUnitDefID(unitID)
local unitDef = UnitDefs[unitDefID]
local name = unitDef.name
local rad = math.rad
local CRATE_SPEED = math.rad(50)
local RANDOM_ROT = math.random(-180, 180)
local UNLOAD_X, UNLOAD_Z

pointID = nil
beaconID = nil
function ParentBeacon(callingPointID, parentBeaconID)
	pointID = callingPointID
	beaconID = parentBeaconID
end

local function Blinks()
	local i = 1
	while true do
		EmitSfx(blinks[i], SFX.CEG)
		Sleep(500)
		i = i + 1
		if i == 7 then i = 1 end
	end
end

function Upgrade(level)
	if name == "upgrade_vehiclepad" then
		if level == 2 then
			Show(base2)
			Hide(base)
			for i = 1,6 do
				Hide(ramps[i])
			end
		elseif level == 3 then
			Show(flags)
		end
	end
end

function script.Create()
	if ramps[1] then 
		for i = 1, 6 do
			Turn(ramps[i], y_axis, rad((i-1) * -60))
		end
		Hide(base2)
		Hide(flags)
	elseif foot1 then
		Turn(foot2, y_axis, rad(-60), CRATE_SPEED * 10)
		Turn(foot3, y_axis, rad(60), CRATE_SPEED * 10)
	end
	Sleep(100) -- wait a few frames
	if not Spring.GetUnitTransporter(unitID) then
		Unloaded()
	end
end

function Unloaded()
	StartThread(Unpack)
end

local BAY_RESTORE = 5000 -- 5 seconds
local bayReady = false

function MechBayOpen()
	Move(rampr, x_axis, 10, CRATE_SPEED * 10)
	Move(ramprtoolupper, x_axis, 10, CRATE_SPEED * 5)
	Move(rampl, x_axis, -10, CRATE_SPEED * 10)
	Move(rampltoolupper, x_axis, -10, CRATE_SPEED * 5)
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
	if name == "upgrade_mechbay" then
		StartThread(MechBayClose)
	end
end
	
function SeismicPings()
	while true do
		Move(hammer, y_axis, 0, CRATE_SPEED * 50)
		WaitForMove(hammer, y_axis)
		PlaySound("stomp")
		GG.EmitSfxName(unitID, spike, "mech_jump_dust")
		Spring.SetUnitSensorRadius(unitID, "seismic", unitDef.seismicRadius)
		Sleep(500)
		Move(hammer, y_axis, 7, CRATE_SPEED * 5)
		WaitForMove(hammer, y_axis)
		Spring.SetUnitSensorRadius(unitID, "seismic", 0)
		Sleep(5000)
	end
end

function Unpack()
	-- Wait for delivery van to bug out
	Sleep(2000)
	-- Unpack the crate
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
	
	-- Begin upgrade-specific anims
	GG.PlaySoundForTeam(Spring.GetUnitTeam(unitID), "BB_" .. name .. "_deployed", 1)
	if name == "upgrade_c3array" then
		Move(emitter, y_axis, 30, CRATE_SPEED * 5)
		Turn(antennarot, x_axis, rad(-90), CRATE_SPEED)
		WaitForTurn(antennarot, x_axis)
		Move(antenna1, z_axis, 20, CRATE_SPEED * 10)
		Move(antenna2, z_axis, 20, CRATE_SPEED * 10)
		Move(antenna3, z_axis, 20, CRATE_SPEED * 10)
		WaitForMove(emitter, y_axis)
		Spin(geo, y_axis, math.rad(20), math.rad(5))
		-- We're deployed, grant the extra tonnage
		local teamID = Spring.GetUnitTeam(unitID)
		GG.LanceControl(teamID, unitID, true)
	elseif name == "upgrade_mechbay" then
		MechBayOpen()
		local x, _ ,z = Spring.GetUnitPosition(unitID)
		local dx, _, dz = Spring.GetUnitDirection(unitID)
		UNLOAD_X = x + 150 * dx
		UNLOAD_Z = z + 150 * dz
	elseif name == "upgrade_uplink" then
		Move(antennabase, z_axis, -15, CRATE_SPEED * 5)
		Turn(antennamast, x_axis, rad(90), CRATE_SPEED)
		Turn(antennareceiver, x_axis, rad(-45), CRATE_SPEED * 2)
		WaitForTurn(antennamast, x_axis)
		WaitForTurn(antennareceiver, x_axis)
		Move(antennapole, y_axis, 10, CRATE_SPEED * 10)
		for i = 2,15 do
			Turn(dishs[i], y_axis, rad(24), CRATE_SPEED / 4)
		end
		Turn(antennabase, y_axis, rad(RANDOM_ROT), CRATE_SPEED)
		WaitForTurn(antennabase, y_axis)
	elseif name == "upgrade_vehiclepad" then
		for i = 1, 6 do
			Turn(ramps[i], x_axis, rad(-115), CRATE_SPEED)
		end
		WaitForTurn(ramps[6], x_axis)
		StartThread(Blinks)
		GG.LCLeft(nil, unitID, teamID) -- fake call, no dropship really left
	elseif name == "upgrade_garrison" then
		-- nothing special
	elseif name == "upgrade_seismic" then
		Turn(foot1, x_axis, rad(-90), CRATE_SPEED * 5)
		Turn(foot2, x_axis, rad(90), CRATE_SPEED * 5)
		Turn(foot3, x_axis, rad(90), CRATE_SPEED * 5)
		Move(lifter, y_axis, 10, CRATE_SPEED * 5)
		WaitForMove(lifter, y_axis)
		for i = 1,3 do
			Move(hammer, y_axis, 7, CRATE_SPEED * 5)
			WaitForMove(hammer, y_axis)
			Move(hammer, y_axis, 0, CRATE_SPEED * 50)
			WaitForMove(hammer, y_axis)
			PlaySound("stomp")
			GG.EmitSfxName(unitID, spike, "mech_jump_dust")
		end
		StartThread(SeismicPings)
	elseif name == "upgrade_turretcontrol" then
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
		-- parent beacon location not our own, if it exists
		local x, y, z = Spring.GetUnitPosition(beaconID or unitID)
		GG.BuildMaskCircle(x, z, 460, 2)
	end
	-- Let the sands of time cover the crate
	Sleep(2500)
	Move(crate_base, y_axis, -5, CRATE_SPEED)
	Sleep (5000)
	RecursiveHide(crate_base, true)
end


-- Code for MechBay Only

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


function Repair(passengerID)
	local curHP, maxHP = GetUnitHealth(passengerID)
	while curHP ~= maxHP do
		local newHP = math.min(curHP + maxHP * REPAIR_RATE, maxHP)
		SetUnitHealth(passengerID, newHP)
		curHP, maxHP = GetUnitHealth(passengerID)
		curHP, maxHP = GetUnitHealth(passengerID)
		Sleep(1000)
	end
	repaired = true
	if resupplied and restored then -- I'm the last task to finish, move out!
		script.TransportDrop(passengerID)
	end
end

function Restore(passengerID)
	local limbHPs = passengerInfo.limbHPs
	if passengerEnv.limbHPControl then -- N.B. currently this runs for all mechs
		for limb, maxHP in pairs(limbHPs) do
			local curHP = passengerEnv.limbHPControl(limb, 0)
			while curHP ~= maxHP do
				curHP = passengerEnv.limbHPControl(limb, -maxHP * LIMB_REPAIR_RATE)
				Sleep(1000)
			end
		end
	end
	restored = true
	if repaired and resupplied then -- I'm the last task to finish, move out!
		script.TransportDrop(passengerID)
	end	
end

function Resupply(passengerID)
	local ammoTypes = passengerInfo.ammoTypes
	if passengerEnv.ChangeAmmo then -- N.B. currently this runs for all mechs regardless of whether they have any ammo using weapons...
		while true do
			local moreToDo = false
			for weaponNum, ammoType in pairs(ammoTypes) do --... but this loop will finish immediatly in that case
				local amount = passengerInfo.burstLengths[weaponNum]
				local supplied = passengerEnv.ChangeAmmo(ammoType, amount)
				--if supplied then Spring.Echo("Deduct " .. amount .. " " .. ammoType) end
				moreToDo = moreToDo or supplied
			end
			if not moreToDo then break end
			Sleep(1000)
		end
	end
	resupplied = true
	if repaired and restored then -- I'm the last task to finish, move out!
		script.TransportDrop(passengerID)
	end	
end

function script.TransportPickup (passengerID)
	if bayReady then
		passengerDefID = GetUnitDefID(passengerID)
		passengerInfo = GG.lusHelper[passengerDefID]
		passengerEnv = Spring.UnitScript.GetScriptEnv(passengerID)
		-- TODO: pickup animation
		Spring.UnitScript.AttachUnit(base, passengerID)
		StartThread(Repair, passengerID)
		StartThread(Resupply, passengerID)
		StartThread(Restore, passengerID)
	end
end



function script.TransportDrop (passengerID, x, y, z)
	local isTransporting = Spring.GetUnitIsTransporting(unitID)
	if isTransporting and #isTransporting > 0 then
		passengerID = passengerID or isTransporting[1]
		Spring.SetUnitBlocking(unitID, false, false) -- make it easy to get out
		Spring.UnitScript.DropUnit(passengerID)
		Spring.SetUnitMoveGoal(passengerID, UNLOAD_X, 0, UNLOAD_Z, 50) -- bug out over here
		-- reset states
		repaired = false
		resupplied = false
		restored = false
		-- wait for current passenger to get out
		Sleep(1000)
		Spring.SetUnitBlocking(unitID, true, true)
	end
end

-- Garrison weapons
noFiring = true
function script.AimWeapon(weaponID, heading, pitch)
	if noFiring then return false end
	Signal(2 ^ weaponID) -- 2 'to the power of' weapon ID
	SetSignalMask(2 ^ weaponID)

	Turn(flares[weaponID], y_axis, heading)
	Turn(flares[weaponID], x_axis, -pitch)

	return true
end

function script.Shot(weaponID)
	EmitSfx(flares[weaponID], SFX.CEG + weaponID)
end

function script.AimFromWeapon(weaponID) 
	return flares[weaponID]
end

function script.QueryWeapon(weaponID) 
	return flares[weaponID]
end

function script.Killed(recentDamage, maxRepairth)
	GG.PlaySoundForTeam(Spring.GetUnitTeam(unitID), "BB_" .. name .. "_destroyed", 1)
end
