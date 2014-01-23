-- Test Mech Script
-- useful global stuff
local ud = UnitDefs[Spring.GetUnitDefID(unitID)] -- unitID is available automatically to all LUS
local weapons = ud.weapons
local deg, rad = math.deg, math.rad
local currUnitDef
local BUILD_FACING = Spring.GetUnitBuildFacing(unitID)

--piece defines

local hull = piece("hull")
-- Landing Gear Pieces
local gear1_door = piece("gear1_door")
local gear2_door = piece("gear2_door")
local gear3_door = piece("gear3_door")
local gear4_door = piece("gear4_door")

local gear1_joint = piece("gear1_joint")
local gear2_joint = piece("gear2_joint")
local gear3_joint = piece("gear3_joint")
local gear4_joint = piece("gear4_joint")

local gear1 = piece("gear1")
local gear2 = piece("gear2")
local gear3 = piece("gear3")
local gear4 = piece("gear4")

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

-- LANDING CODE
-- Variables
local stage = 0
local feetDown = false

function TouchDown()
	stage = 4
	for i = 1, 4 do
		EmitSfx(dusts[i], CEG + 5)
	end
end

local function fx()
	-- Free fall
	while stage == 1 do
		-- Some reentry glow here?
		EmitSfx(dustlarge, CEG + 5) --1032)
		Sleep(32)
	end
	-- Rocket Burn
	while stage == 2 do
		EmitSfx(exhaustlarge, CEG + 1) --1027)
		EmitSfx(exhaustlarge, CEG + 3) --1030)
		for i = 1, 4 do
			EmitSfx(exhausts[i], CEG + 4)--1031)
		end
		Sleep(32)
	end
	-- Final descent
	while stage == 3 do
		-- Dust clouds and continue rocket burn? (reduced?)
		-- EmitSfx(exhaustlarge, SOME_SMALLER_BIGASS_ROCKET)
		--EmitSfx(dustlarge, 1029)
		SpawnCEG("dropship_heavy_dust", X, GY, Z) -- Use SpawnCEG for ground FX :)
		EmitSfx(exhaustlarge, CEG + 2) --1028)
		EmitSfx(exhaustlarge, CEG + 3)--1030)
		for i = 1, 4 do
			EmitSfx(exhausts[i], CEG + 4)--1031)
			if feetDown then
				EmitSfx(dusts[i], CEG + 4)--1031)
			end
			--EmitSfx(dusts[i], SMALLER_DUST)
		end		
		Sleep(32)
	end
	if stage == 4 then
		local REST = 10
		local RETURN = 6
		Move(hull, y_axis, -REST, 2 * REST)
		Move(gear1_joint, y_axis, REST, 2 * REST)
		Move(gear2_joint, y_axis, REST, 2 * REST)
		Move(gear3_joint, y_axis, REST, 2 * REST)
		Move(gear4_joint, y_axis, REST, 2 * REST)
		WaitForMove(gear4_joint, y_axis)
		Move(hull, y_axis, -RETURN, RETURN)
		Move(gear1_joint, y_axis, RETURN, RETURN)
		Move(gear2_joint, y_axis, RETURN, RETURN)
		Move(gear3_joint, y_axis, RETURN, RETURN)
		Move(gear4_joint, y_axis, RETURN, RETURN)
		WaitForMove(gear4_joint, y_axis)
		StartThread(UnloadCargo)
	end
end

local function LandingGearDown()
	SPEED = math.rad(15)
	-- Landing--
	--Open Landing Gear Doors--
	--Spring.Echo("GEAR DEPLOYING...")
	Turn(gear1_door, x_axis, rad(-50), SPEED)
	Turn(gear2_door, x_axis, rad(50), SPEED)
	Turn(gear3_door, x_axis, rad(50), SPEED)
	Turn(gear4_door, x_axis, rad(-50), SPEED)
	SPEED = math.rad(25)
	--Legs Come Out--
	Turn(gear1_joint, x_axis, rad(125), SPEED)
	Turn(gear1, x_axis, rad(-155), SPEED)
	Turn(gear2_joint, x_axis, rad(-125), SPEED)
	Turn(gear2, x_axis, rad(155), SPEED)
	Turn(gear3_joint, x_axis, rad(-125), SPEED)
	Turn(gear3, x_axis, rad(155), SPEED)
	Turn(gear4_joint, x_axis, rad(125), SPEED)
	Turn(gear4, x_axis, rad(-155), SPEED)
	
	WaitForTurn(gear4, x_axis)
	feetDown = true
	--Spring.Echo("GEAR DEPLOYED.")
end

local function LandingGearUp()
	feetDown = false
	SPEED = math.rad(50)
	--Legs Go In--
	Turn(gear1_joint, x_axis, 0, SPEED)
	Turn(gear1, x_axis, 0, SPEED)
	Turn(gear2_joint, x_axis, 0, SPEED)
	Turn(gear2, x_axis, 0, SPEED)
	Turn(gear3_joint, x_axis, 0, SPEED)
	Turn(gear3, x_axis, 0, SPEED)
	Turn(gear4_joint, x_axis, 0, SPEED)
	Turn(gear4, x_axis, 0, SPEED)	
	WaitForTurn(gear4, x_axis)
	--SPEED = math.rad(30)
	--Close Landing Gear Doors--
	Turn(gear1_door, x_axis, 0, SPEED)
	Turn(gear2_door, x_axis, 0, SPEED)
	Turn(gear3_door, x_axis, 0, SPEED)
	Turn(gear4_door, x_axis, 0, SPEED)
	WaitForTurn(gear4_door, x_axis)
	Spring.MoveCtrl.SetGravity(unitID, -4 * GRAVITY)
end

function script.Create()
	Spring.SetTeamRulesParam(Spring.GetUnitTeam(unitID), "DROPSHIP_COOLDOWN", -1)
	Spring.SetUnitNoSelect(unitID, true)
	Turn(exhaustlarge, x_axis, math.rad(90), 0)
	Spin(exhaustlarge, y_axis, math.rad(360))
	for i = 1, 4 do
		Turn(dusts[i], x_axis, math.rad(90), 0)
		Spin(dusts[i], y_axis, math.rad(360))
		Turn(exhausts[i], x_axis, math.rad(90), 0)
		Spin(exhausts[i], y_axis, math.rad(360))
	end
	Spring.MoveCtrl.Enable(unitID)
	Spring.MoveCtrl.SetPosition(unitID, X, GY + DROP_HEIGHT, Z)
	--Spring.MoveCtrl.SetVelocity(unitID, 0, -100, 0)
	Spring.MoveCtrl.SetVelocity(unitID, 0, -50, 0)
	--Spring.MoveCtrl.SetGravity(unitID, -0.5 * GRAVITY)
	
	local SPEED = 0
	--Setups: Quickly do this before the dropship appears)
	--Legs Setup--
	Turn(gear1_door, y_axis, rad(-45), SPEED)
	Turn(gear1_joint, y_axis, rad(-45), SPEED)
	Turn(gear2_door, y_axis, rad(45), SPEED)
	Turn(gear2_joint, y_axis, rad(45), SPEED)
	Turn(gear3_door, y_axis, rad(-45), SPEED)
	Turn(gear3_joint, y_axis, rad(-45), SPEED)
	Turn(gear4_door, y_axis, rad(45), SPEED)
	Turn(gear4_joint, y_axis, rad(45), SPEED)
	
	--Spring.MoveCtrl.SetGravity(unitID, GRAVITY)
	stage = 1
	StartThread(fx)
	
	local _, y, _ = Spring.GetUnitPosition(unitID)
	while y - GY > 3500 do
		Sleep(120)
		_, y, _ = Spring.GetUnitPosition(unitID)
	end
	stage = 2
	--Spring.Echo("ROCKET FULL BURN NOW!")
	Spring.MoveCtrl.SetGravity(unitID, -3.72 * GRAVITY)
	
	StartThread(LandingGearDown)
	while y - GY > 925 do
		Sleep(120)
		_, y, _ = Spring.GetUnitPosition(unitID)
	end
	stage = 3
	GG.SpawnDecal("decal_drop", X, GY + 1, Z, Spring.GetUnitTeam(unitID), 30 * 2.5, 30 * 120)
	Spring.MoveCtrl.SetGravity(unitID, -0.02 * GRAVITY)
	Spring.MoveCtrl.SetCollideStop(unitID, true)
	Spring.MoveCtrl.SetTrackGround(unitID, true)
end

-- CARGO CODE
local link, pad, main_door, hanger_door, vtol_pad = piece ("link", "pad", "main_door", "hanger_door", "vtol_pad")

local WAIT_TIME = 10000
local DOOR_SPEED = math.rad(20)
local x, _ ,z = Spring.GetUnitPosition(unitID)
local dx, _, dz = Spring.GetUnitDirection(unitID)
local UNLOAD_X = x + 300 * dx
local UNLOAD_Z = z + 300 * dz
		
local cargo = {}
local numCargo = 0
function LoadCargo(cargoID, callerID)
	--Spring.Echo("Loading", outpostID, "of type", UnitDefs[Spring.GetUnitDefID(outpostID)].name)
	Spring.UnitScript.AttachUnit(hull, cargoID)
	numCargo = numCargo + 1
	cargo[numCargo] = cargoID
end

function UnloadCargo()
	Turn(main_door, x_axis, math.rad(110), DOOR_SPEED)
	Turn(hanger_door, y_axis, math.rad(90), DOOR_SPEED)
	Turn(link, x_axis, math.rad(35), DOOR_SPEED * 10)
	Turn(vtol_pad, y_axis, math.rad(90), DOOR_SPEED * 10)
	WaitForTurn(main_door, x_axis)
	
	for i, cargoID in ipairs(cargo) do
		Move(link, z_axis, 0, 100)
		Move(pad, z_axis, 0, 100)
		Turn(pad, x_axis, math.rad(-35))
		--Move(vtol_pad, z_axis, 0)
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
			local moveSpeed = currUnitDef.speed * 0.5 --256 / buildTime
			Move(vtol_pad, x_axis, 256, moveSpeed)
			WaitForMove(vtol_pad, x_axis)
			--Spring.SetUnitRelativeVelocity(cargoID, 0, 0, moveSpeed / 30)
		else
			Spring.UnitScript.AttachUnit(pad, cargoID)
			local moveSpeed = currUnitDef.speed * 0.5 --173 / buildTime
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
		Spring.SetUnitMoveGoal(cargoID, UNLOAD_X +  math.random(-100, 100), 0, UNLOAD_Z +  math.random(-100, 100), 25) -- bug out over here
		Sleep(2000)
	end
	Turn(main_door, x_axis, 0, DOOR_SPEED)
	Turn(hanger_door, y_axis, 0, DOOR_SPEED)
	WaitForTurn(hanger_door, y_axis)
	WaitForTurn(main_door, x_axis)
	Sleep(WAIT_TIME)
	stage = 3
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

for weaponID = 1, info.numWeapons do
	if missileWeaponIDs[weaponID] then
		if launcherIDs[weaponID] then
			launchers[weaponID] = piece("launcher_" .. weaponID)
		end
		launchPoints[weaponID] = {}
		currPoints[weaponID] = 1
		for i = 1, burstLengths[weaponID] do
			launchPoints[weaponID][i] = piece("launchpoint_" .. weaponID .. "_" .. i)
		end	
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

function script.AimWeapon(weaponID, heading, pitch)
	Signal(2 ^ (weaponID - 1))
	SetSignalMask(2 ^ (weaponID - 1))
	if trackEmitters[weaponID] then -- LBLs
		if weaponID % 2 == 1 then -- only first in each pair
			Turn(trackEmitters[weaponID], y_axis, heading + math.rad(90 * (weaponID - 1)/2), TURRET_SPEED)
			WaitForTurn(trackEmitters[weaponID], y_axis)
		end
	elseif turrets[weaponID] then -- PPCs
		Turn(turrets[weaponID], y_axis, heading, TURRET_SPEED)
		Turn(turrets[weaponID], x_axis, -pitch, TURRET_SPEED)
		WaitForTurn(turrets[weaponID], y_axis)
		WaitForTurn(turrets[weaponID], x_axis)
		return true
	elseif flares[weaponID] then -- ERMBLs
		Turn(flares[weaponID], y_axis, heading)
	end
	Turn(flares[weaponID], x_axis, -pitch)
	--Sleep(100 * weaponID) -- desync barrels to fire independently
	return true
end

function script.Shot(weaponID)
	EmitSfx(flares[weaponID], SFX.CEG + weaponID)
end

function script.AimFromWeapon(weaponID) 
	return trackEmitters[weaponID] or turrets[weaponID] or flares[weaponID] or hull
end

function script.QueryWeapon(weaponID)
	return flares[weaponID]
end 