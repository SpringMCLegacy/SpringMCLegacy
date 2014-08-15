-- Test Mech Script
-- useful global stuff
local ud = UnitDefs[Spring.GetUnitDefID(unitID)] -- unitID is available automatically to all LUS
local weapons = ud.weapons
local deg, rad = math.deg, math.rad
local currUnitDef

--piece defines

local hull = piece("hull")
-- Landing Gear Pieces
local gears = {}
for i = 1,4 do
	gears[i] = {
		door  = piece("gear" .. i .. "_door"),
		joint = piece("gear" .. i .. "_joint"),
		gear  = piece("gear" .. i)
	}
end

-- Exhaust Pieces
local exhaustlarge = piece("exhaustlarge")
local exhausts = {}
for i = 1,4 do
	exhausts[i] = piece("exhaust" .. i)
end

local dustlarge = piece("dust1")
local dusts = {}
for i = 1,4 do
	dusts[i] = piece("dust" .. i + 1)
end

-- localised functions
-- SyncedCtrl
local SpawnCEG = Spring.SpawnCEG
-- Constants
local DROP_HEIGHT = 10000
local GRAVITY = 120/Game.gravity
local X, _, Z = Spring.GetUnitPosition(unitID)
local GY = Spring.GetGroundHeight(X, Z)
local CEG = SFX.CEG + #weapons

local HALF_MAP_X = Game.mapSizeX/2
local HALF_MAP_Z = Game.mapSizeZ/2
local facing = math.abs(HALF_MAP_X - X) > math.abs(HALF_MAP_Z - Z)
			and ((X > HALF_MAP_X) and 3 or 1)
			or ((Z > HALF_MAP_Z) and 2 or 0)
			
local HEADING = facing * 16384 + math.random(-1820, 1820)

-- LANDING CODE
-- Variables
local stage = 0
local up = false
local feetDown = false

function TouchDown()
	stage = 4
	for i = 1, 4 do
		EmitSfx(dusts[i], CEG + 6)
	end
end

local fxStages = {
	[1] = {
		{1, "dropship_hull_heat", {count = 70, pos = {0,0,0}, repeatEffect = 4}},
		{1, "dropship_hull_heat", {count = 90, pos = {0,0,0}, repeatEffect = 3, delay = 10}},
		{1, "dropship_hull_heat", {count = 90, pos = {0,0,0}, repeatEffect = 3, delay = 20}},
		{exhausts, "dropship_vertical_exhaust",  {id = "smallExhaustJets", repeatEffect = true, width = 30, length = 150}},
		{exhaustlarge, "dropship_vertical_exhaust",  {id = "largeExhaustJet", repeatEffect = true, width = 190, length = 250}},
	},
	[2] = {
		--{1, "engine_sound"},
	},
	[3] = {
		{"remove", "largeExhaustJet"},
		{"remove", "smallExhaustJets"},
	},
	[4] = {
		{"remove", "smallExhaustJets"},
		{1, "valve_release", {pos = { 80,100, 80}, emitVector = { 1,0, 1}} },
		{1, "valve_release", {pos = {-80,100, 80}, emitVector = {-1,0, 1}} },
		{1, "valve_release", {pos = { 80,100,-80}, emitVector = { 1,0,-1}} },
		{1, "valve_release", {pos = {-80,100,-80}, emitVector = {-1,0,-1}} },
		{1, "valve_sound"},
		{1, "land_sound"},
		{1, "exhaust_ground_winds", {pos = {0,0,0}, repeatEffect = false}},
		{1, "exhaust_ground_winds", {pos = {0,0,0}, repeatEffect = false, delay = 80}},
	},
	[5] = {
		{1, "exhaust_ground_winds", {pos = {0,0,0}, repeatEffect = false}},
		{1, "exhaust_ground_winds", {pos = {0,0,0}, repeatEffect = false, delay = 80}},
		--{exhaustlarge, "plume", {worldpos=true}},
		--{exhaustlarge, "plume", {worldpos=true}},
		--{exhaustlarge, "plume", {worldpos=true}},
		--{exhaustlarge, "plume", {worldpos=true}},
		--{exhaustlarge, "plume", {worldpos=true}},
	},
}


local function fx()
	-- Free fall
	if stage == 1 then
		GG.EmitLupsSfxArray(unitID, fxStages[stage])
	end
	while stage == 1 do
		Sleep(32)
	end
	-- Rocket Burn
	if stage == 2 then
		GG.EmitLupsSfxArray(unitID, fxStages[stage])
		local time = 114
		for t = 0, (time/3) do
			local i = t / (time/3)
			for _, exhaust in ipairs(exhausts) do
				if (i == 1) then
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "smallExhaustJets", repeatEffect = true, delay = t*3, width = 110, length = 350})
				elseif (i > 0.33) then
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "smallExhaustJets", life = 2, delay = t*3, width = i * 110, length = i * 350})
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "smallExhaustJets", life = 1, delay = t*3+2, width = i * 100, length = i * 300})
				else
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "smallExhaustJets", life = 1, delay = t*3,   width = i * 110, length = i * 350})
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "smallExhaustJets", life = 2, delay = t*3+1, width = i * 80, length = i * 190})
				end
			end
		end
	end
	while stage == 2 do
		if up then
			EmitSfx(exhaustlarge, CEG + 1)
			EmitSfx(exhaustlarge, CEG + 3)
		end
		Sleep(32)
	end
	-- Final descent
	if stage == 3 then
		GG.EmitLupsSfxArray(unitID, fxStages[stage])
		for _, exhaust in ipairs(exhausts) do
			GG.BlendJet(99, unitID, exhaust, "smallExhaustJets")
		end
	end
	while stage == 3 do
		Sleep(32)
	end
	if stage == 4 then
		GG.EmitLupsSfxArray(unitID, fxStages[stage])

		local REST = 10
		local RETURN = 6
		Move(hull, y_axis, -REST, 2 * REST)
		for i = 1, 4 do
			Move(gears[i].joint, y_axis, REST, 2 * REST)
		end
		WaitForMove(gears[4].joint, y_axis)
		Move(hull, y_axis, -RETURN, RETURN)
		for i = 1, 4 do
			Move(gears[i].joint, y_axis, RETURN, RETURN)
		end
		WaitForMove(gears[4].joint, y_axis)
		StartThread(UnloadCargo)
	end
	if stage == 5 then -- blast off
		GG.EmitLupsSfxArray(unitID, fxStages[stage])
		for _, exhaust in ipairs(exhausts) do
			GG.BlendJet(33, unitID, exhaust, "smallExhaustJets", 20, 30)
		end

		GG.RemoveGrassCircle(X, Z, 230)
		GG.SpawnDecal("decal_drop", X, GY + 1, Z, teamID, false, 30 * 2, 30 * 120)
		up = true
	end
	while stage == 5 do
		EmitSfx(exhaustlarge, CEG + 2)
		EmitSfx(exhaustlarge, CEG + 3)
		Sleep(32)
	end
end

local function LandingGearDown()
	SPEED = math.rad(40)
	for i = 1, 4 do -- Doors open
		Turn(gears[i].door, x_axis, math.rad(60), SPEED * 5)
	end
	WaitForTurn(gears[4].door, x_axis)
	Spring.MoveCtrl.SetGravity(unitID, -4 * GRAVITY) -- -3.72
	Sleep(2500)
	for i = 1, 4 do -- feet into deploy position
		Turn(gears[i].joint, x_axis, math.rad(5), SPEED)
	end
	WaitForTurn(gears[4].joint, x_axis)
	for i = 1, 4 do -- joint and feet rotate out
		Turn(gears[i].joint, x_axis, math.rad(-80), SPEED)
		Turn(gears[i].gear, x_axis, math.rad(50), SPEED)
	end
	WaitForTurn(gears[4].joint, x_axis)
	for i = 1, 4 do -- joint raises and locks into position
		Move(gears[i].joint, y_axis, 0, 15)
		Turn(gears[i].joint, x_axis, math.rad(-115), SPEED)
		Turn(gears[i].gear, x_axis, math.rad(85), SPEED)
	end
	WaitForTurn(gears[4].gear, x_axis)
	Turn(piece("missile_doors"), y_axis, math.rad(16), math.rad(4))
	feetDown = true
end

local function LandingGearUp()
	Turn(piece("missile_doors"), y_axis, 0, math.rad(4))
	feetDown = false
	SPEED = math.rad(40)

	for i = 1, 4 do -- joint lowers and unlocks
		Move(gears[i].joint, y_axis, -13, 15)
		Turn(gears[i].joint, x_axis, math.rad(-80), SPEED)
		Turn(gears[i].gear, x_axis, math.rad(50), SPEED)
	end
	WaitForTurn(gears[4].gear, x_axis)
	for i = 1, 4 do -- joint and feet rotate in
		Turn(gears[i].joint, x_axis, math.rad(5), SPEED)
		Turn(gears[i].gear, x_axis, 0, SPEED)
	end
	WaitForTurn(gears[4].joint, x_axis)
	for i = 1, 4 do -- feet into stowed position
		Turn(gears[i].joint, x_axis, math.rad(80), SPEED)
	end	
	for i = 1, 4 do -- Doors close
		Turn(gears[i].door, x_axis, 0, SPEED)
	end
	WaitForTurn(gears[4].door, x_axis)
	
	Spring.MoveCtrl.SetGravity(unitID, -4 * GRAVITY)
end

local function Drop()
	Spring.SetTeamRulesParam(Spring.GetUnitTeam(unitID), "DROPSHIP_COOLDOWN", -1)
	Spring.SetUnitNoSelect(unitID, true)

	Spring.MoveCtrl.Enable(unitID)
	Spring.MoveCtrl.SetPosition(unitID, X, GY + DROP_HEIGHT, Z)
	Spring.MoveCtrl.SetHeading(unitID, HEADING)
	--Spring.SetUnitDirection(unitID, 0, facing * math.rad(90 + math.random(-10, 10)), 0)
	Spring.MoveCtrl.SetVelocity(unitID, 0, -55, 0)
	Spring.MoveCtrl.SetGravity(unitID, -0.4 * GRAVITY)
	
	local SPEED = 0

	stage = 1
	StartThread(fx)
	
	local _, y, _ = Spring.GetUnitPosition(unitID)
	while y - GY > 3500 do
		Sleep(30)
		_, y, _ = Spring.GetUnitPosition(unitID)
	end
	stage = 2
	--Spring.Echo("ROCKET FULL BURN NOW!")


	StartThread(LandingGearDown)
	while y - GY > 925 do
		Sleep(30)
		_, y, _ = Spring.GetUnitPosition(unitID)
	end
	stage = 3
	Spring.MoveCtrl.SetGravity(unitID, -0.02 * GRAVITY)
	Spring.MoveCtrl.SetCollideStop(unitID, true)
	Spring.MoveCtrl.SetTrackGround(unitID, true)
end

-- CARGO CODE
local link, pad, main_door, hanger_door, vtol_pad = piece ("link", "pad", "main_door", "hanger_door", "vtol_pad")

local WAIT_TIME = 10000
local DOOR_SPEED = math.rad(20)
local x, _ ,z = Spring.GetUnitPosition(unitID)
--local dx, _, dz = Spring.GetUnitDirection(unitID)
local dirAngle = HEADING / 2^16 * 2 * math.pi
local dx = math.sin(dirAngle)
local dz = math.cos(dirAngle)
local UNLOAD_X = x + 300 * dx
local UNLOAD_Z = z + 300 * dz
		
local cargo = {}
local numCargo = 0
function LoadCargo(cargoID, callerID)
	--Spring.Echo("Loading", outpostID, "of type", UnitDefs[Spring.GetUnitDefID(outpostID)].name)
	Spring.UnitScript.AttachUnit(-1, cargoID)
	numCargo = numCargo + 1
	cargo[numCargo] = cargoID
end

function UnloadCargo()
	Turn(main_door, x_axis, math.rad(110), DOOR_SPEED)
	Turn(hanger_door, y_axis, math.rad(90), DOOR_SPEED * 0.5)
	Turn(link, x_axis, math.rad(35), DOOR_SPEED * 10)
	Turn(vtol_pad, y_axis, math.rad(90), DOOR_SPEED * 10)
	WaitForTurn(main_door, x_axis)
	
	for i, cargoID in ipairs(cargo) do
		Move(link, z_axis, 0)
		Move(pad, z_axis, 0)
		Turn(pad, x_axis, math.rad(-35))
		Move(vtol_pad, x_axis, 0)

		WaitForMove(link, z_axis)
		WaitForMove(pad, z_axis)
		
		-- start cargo moving anim
		env = Spring.UnitScript.GetScriptEnv(cargoID)
		if env and env.script and env.script.StartMoving then -- TODO: shouldn't be required, maybe if cargo died?
			Spring.UnitScript.CallAsUnit(cargoID, env.script.StartMoving, false)
		end
		
		-- attach and move
		local currUnitDef = UnitDefs[Spring.GetUnitDefID(cargoID)]
		local buildTime = currUnitDef.buildTime

		if currUnitDef.canFly then
			Spring.UnitScript.AttachUnit(vtol_pad, cargoID)
			Move(vtol_pad, x_axis, 128, 64)
			WaitForMove(vtol_pad, x_axis)
			Spring.SetUnitVelocity(cargoID, 8, 4, 0)
		else
			Spring.UnitScript.AttachUnit(pad, cargoID)
			local moveSpeed = currUnitDef.speed * 0.5
			Move(link, z_axis, 73, moveSpeed)
			WaitForMove(link, z_axis)
			if currUnitDef.customParams.unittype == "vehicle" then
				Turn(pad, x_axis, 0, DOOR_SPEED) -- vehicles should follow the slope
				WaitForTurn(pad, x_axis)
				Sleep(250)
			end
			Move(pad, z_axis, 100, moveSpeed)
			WaitForMove(pad, z_axis)
		end
		Spring.UnitScript.DropUnit(cargoID)
		Spring.SetUnitBlocking(cargoID, true, true, true, true, true, true, true)
		if currUnitDef.canFly then
			Spring.GiveOrderToUnit(cargoID, CMD.MOVE, {X + 256, 0, Z}, {})
		else
			Spring.SetUnitMoveGoal(cargoID, UNLOAD_X +  math.random(-100, 100), 0, UNLOAD_Z +  math.random(-100, 100), 25) -- bug out over here
		end
		Sleep(2000)
	end
	Turn(main_door, x_axis, 0, DOOR_SPEED)
	Turn(hanger_door, y_axis, 0, DOOR_SPEED)
	WaitForTurn(hanger_door, y_axis)
	WaitForTurn(main_door, x_axis)
	Sleep(WAIT_TIME)
	stage = 5 --3
	StartThread(fx)
	Spring.MoveCtrl.Enable(unitID)
	Spring.MoveCtrl.SetGravity(unitID, -1 * GRAVITY)
	Sleep(2500)
	stage = 2
	StartThread(fx) -- need to restart here as we're going back up a step
	StartThread(LandingGearUp)
	Sleep(10000)
	-- We're out of the atmosphere, bye bye!
	GG.DropshipLeft(Spring.GetUnitTeam(unitID)) -- let the world know
	Spring.DestroyUnit(unitID, false, true)
end

-- WEAPON CONTROL
info = GG.lusHelper[unitDefID]

-- localised API functions
local GetUnitSeparation 		= Spring.GetUnitSeparation
local GetUnitCommands   		= Spring.GetUnitCommands
-- localised GG functions
local GetUnitDistanceToPoint = GG.GetUnitDistanceToPoint
local GetUnitUnderJammer = GG.GetUnitUnderJammer
local IsUnitNARCed = GG.IsUnitNARCed
local IsUnitTAGed = GG.IsUnitTAGed

-- Info from lusHelper gadget
local missileWeaponIDs = info.missileWeaponIDs
local flareOnShots = info.flareOnShots
local jammableIDs = info.jammableIDs
local launcherIDs = info.launcherIDs
local barrelRecoils = info.barrelRecoilDist
local burstLengths = info.burstLengths
local minRanges = info.minRanges
local amsID = info.amsID
local turretIDs = info.turretIDs

local TURRET_SPEED = math.rad(30)

-- weapons pieces
local trackEmitters = {}
for i = 1, 7, 2 do -- TODO: setup a table in lus_helper
	trackEmitters[i] = piece("laser_emitter_" .. i)
	trackEmitters[i+1] = trackEmitters[i]
end

local turrets = {}
for i, valid in pairs(turretIDs) do
	if valid then
		turrets[i] = piece("turret_" .. i)
	end
end

local flares = {}
--local turrets = info.turrets

local mantlets = {}
local barrels = {}
local launchers = {}
local launchPoints = {}
local currPoints = {}
local spinPieces = {}
local spinPiecesState = {}

local missileSignals = {}
local amsSignal = {}

for weaponID = 1, info.numWeapons do
	if missileWeaponIDs[weaponID] then
		if launcherIDs[weaponID] then
			launchers[weaponID] = piece("launcher_" .. weaponID)
		end
		missileSignals[weaponID] = {}
		--[[launchPoints[weaponID] = {}
		currPoints[weaponID] = 1
		for i = 1, burstLengths[weaponID] do
			launchPoints[weaponID][i] = piece("launchpoint_" .. weaponID .. "_" .. i)
		end	]]
	elseif weaponID then
		flares[weaponID] = piece ("flare_" .. weaponID)
	end
	--[[if info.turretIDs[weaponID] then
		turrets[weaponID] = piece("turret_" .. weaponID)
	end]]
	if info.mantletIDs[weaponID] then
		mantlets[weaponID] = piece("mantlet_" .. weaponID)
	end
	if info.barrelIDs[weaponID] then
		barrels[weaponID] = piece("barrel_" .. weaponID)
	end
end

function script.Create()
	-- Put pieces into starting pos
	Turn(exhaustlarge, x_axis, math.rad(90), 0)
	--Spin(exhaustlarge, y_axis, math.rad(360))
	for i = 1, 4 do
		Turn(dusts[i], x_axis, math.rad(90), 0)
		--Spin(dusts[i], y_axis, math.rad(360))
		Turn(exhausts[i], x_axis, math.rad(90), 0)
		Spin(exhausts[i], y_axis, math.rad(360))
	end
	-- Legs Setup
	for i = 1,4 do
		local angle = (i == 2 or i == 3) and rad(45) or rad(225)
		local angleDir = i % 2 == 0 and angle or -angle
		local angle2 = rad(80)
		Turn(gears[i].door, y_axis, angleDir)
		Turn(gears[i].joint, y_axis, angleDir)
		Turn(gears[i].joint, x_axis, angle2)
		Move(gears[i].joint, y_axis, -13)
	end
	-- weapon pieces too
	for id, turret in pairs(turrets) do
		Turn(dusts[(id - 15)/2], y_axis, math.rad(-45 * id))
		Turn(turret, y_axis, math.rad(-45 * id))
	end
	-- 1, 3, 5, 7 -> 2n - 1, .'. (id + 1)/2
	for id, trackEmitter in pairs(trackEmitters) do
		if id % 2 == 1 then -- only the first time for each pair
			Turn(trackEmitter, y_axis, math.rad(90 * ((id + 1)/2 - 1)))
		end
	end
	-- Start dropping
	Drop()
end


function script.AimWeapon(weaponID, heading, pitch)
	if weaponID < 25 then
		Signal(2 ^ (weaponID - 1))
		SetSignalMask(2 ^ (weaponID - 1))
	elseif missileWeaponIDs[weaponID] then -- can only use 24 weapons in this way, sor LRM are seperate
		Signal(missileSignals[weaponID])
		SetSignalMask(missileSignals[weaponID])
	else -- LAMS
		Signal(amsSignal)
		SetSignalMask(amsSignal)
	end
	if trackEmitters[weaponID] then -- LBLs
		if weaponID % 2 == 1 then -- only first in each pair
			Turn(trackEmitters[weaponID], y_axis, heading, TURRET_SPEED) -- + math.rad(90 * (weaponID - 1)/2), TURRET_SPEED)
			WaitForTurn(trackEmitters[weaponID], y_axis)
		end
	elseif turrets[weaponID] then -- PPCs
		Turn(turrets[weaponID], y_axis, heading, TURRET_SPEED)
		Turn(turrets[weaponID], x_axis, -pitch, TURRET_SPEED)
		WaitForTurn(turrets[weaponID], y_axis)
		WaitForTurn(turrets[weaponID], x_axis)
		return true
	elseif missileWeaponIDs[weaponID] then
		if launchers[weaponID] then
			Turn(launchers[weaponID], x_axis, -pitch, ELEVATION_SPEED)
		--[[else
			for i = 1, burstLengths[weaponID] do
				Turn(launchPoints[weaponID][i] or launchPoints[weaponID][1], x_axis, -pitch, ELEVATION_SPEED)
			end]]
		end
		return stage == 4 -- only allow when on the ground
	elseif flares[weaponID] then -- ERMBLs
		Turn(flares[weaponID], y_axis, heading)
	end
	Turn(flares[weaponID], x_axis, -pitch)
	--Sleep(100 * weaponID) -- desync barrels to fire independently
	return true
end

function script.BlockShot(weaponID, targetID, userTarget)
	if weaponID == amsID then return false end
	local jammable = jammableIDs[weaponID]
	if jammable then
		if targetID then
			local jammed = GetUnitUnderJammer(targetID) and (not IsUnitNARCed(targetID)) and (not IsUnitTAGed(targetID))
			if jammed then
				--Spring.Echo("Can't fire weapon " .. weaponID .. " as target is jammed")
				return true 
			end
		end
	end
	local minRange = minRanges[weaponID]
	if minRange then
		local distance
		if targetID then
			distance = GetUnitSeparation(unitID, targetID, true)
		elseif userTarget then
			local cmd = GetUnitCommands(unitID, 1)[1]
			if cmd.id == CMD.ATTACK then
				local tx,ty,tz = unpack(cmd.params)
				distance = GetUnitDistanceToPoint(unitID, tx, ty, tz, false)
			end
		end
		if distance < minRange then return true end
	end
	return false
end

function script.Shot(weaponID)
	if missileWeaponIDs[weaponID] then
		EmitSfx(launchers[weaponID], SFX.CEG + weaponID)
		--EmitSfx(launchPoints[weaponID][currPoints[weaponID]] or launchPoints[weaponID][1], SFX.CEG + weaponID)
        --[[currPoints[weaponID] = currPoints[weaponID] + 1
        if currPoints[weaponID] > burstLengths[weaponID] then 
			currPoints[weaponID] = 1
        end]]
	elseif flares[weaponID] then
		EmitSfx(flares[weaponID], SFX.CEG + weaponID)
	end
end

function script.AimFromWeapon(weaponID) 
	return trackEmitters[weaponID] or turrets[weaponID] or launchers[weaponID] or flares[weaponID] or hull
end

function script.QueryWeapon(weaponID)
	if missileWeaponIDs[weaponID] then
		return launchers[weaponID] --launchPoints[weaponID][currPoints[weaponID]] or launchPoints[weaponID][1]
	else
		return flares[weaponID]
	end
end 