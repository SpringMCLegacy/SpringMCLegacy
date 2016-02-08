-- useful global stuff
local weapons = unitDef.weapons
info = GG.lusHelper[unitDefID]

-- Localisations
local SpawnCEG = Spring.SpawnCEG
local GetUnitDistanceToPoint = GG.GetUnitDistanceToPoint
deg, rad = math.deg, math.rad


--piece defines

-- Landing Gear Pieces
gears = {}
for i = 1, info.numGears do
	gears[i] = {
		door  = piece("gear" .. i .. "_door"),
		joint = piece("gear" .. i .. "_joint"),
		gear  = piece("gear" .. i)
	}
end
-- Exhaust Pieces
vExhaustLarges = {}
for i = 1,info.numVExhaustLarges do
	vExhaustLarges[i] = piece("vexhaustlarge" .. i)
end
vExhausts = {}
for i = 1,info.numVExhausts do
	vExhausts[i] = piece("vexhaust" .. i)
end
hExhaustLarges = {}
for i = 1,info.numHExhaustLarges do
	hExhaustLarges[i] = piece("hexhaustlarge" .. i)
end
hExhausts = {}
for i = 1,info.numHExhausts do
	hExhausts[i] = piece("hexhaust" .. i)
end
-- loading booms
local booms = {}
for i = 1,info.numBooms do
	dusts[i] = piece("boom" .. i)
end
-- cargo points
local cargoPieces = {}
for i = 1,info.numCargoPieces do
	cargoPieces[i] = piece("cargopiece" .. i) or -1
end

include ("anims/dropships/" .. unitDef.name:sub(4, (unitDef.name:find("_", 4) or 0) - 1) .. ".lua")

-- Constants
-- non local for anim access
GRAVITY = 120 / Game.gravity
CEG = SFX.CEG + #weapons

local HOVER_HEIGHT = unitDef.customParams.hoverheight or 0
local DROP_HEIGHT = 10000 + HOVER_HEIGHT

local TX, TY, TZ = Spring.GetUnitPosition(unitID)
local GY = Spring.GetGroundHeight(TX, TZ)
local RADIAL_DIST = unitDef.customParams.radialdist or 0

-- Variables
-- non local for anim access
stage = 0
cargo = {}

local touchDown = false
local up = false
local beaconID
local numCargo = 0

function LoadCargo(cargoID, callerID)
	--Spring.Echo("Loading", outpostID, "of type", UnitDefs[Spring.GetUnitDefID(outpostID)].name)
	beaconID = callerID
	numCargo = numCargo + 1
	cargo[numCargo] = cargoID
	Spring.UnitScript.AttachUnit(cargoPieces[numCargo], cargoID)
end


function script.Create()
	Spring.SetUnitAlwaysVisible(unitID, true)
	Spring.SetUnitNoSelect(unitID, true)
	Setup()
	--StartThread(fx)
	Drop()
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- UNION
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local currUnitDef

local CEG = SFX.CEG + #weapons

local HALF_MAP_X = Game.mapSizeX/2
local HALF_MAP_Z = Game.mapSizeZ/2
local facing = math.abs(HALF_MAP_X - X) > math.abs(HALF_MAP_Z - Z)
			and ((X > HALF_MAP_X) and 3 or 1)
			or ((Z > HALF_MAP_Z) and 2 or 0)
			
local HEADING = facing * 16384 + math.random(-1820, 1820)

-- LANDING CODE
-- Variables

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
	GG.DropshipLeft(teamID) -- let the world know
	Spring.DestroyUnit(unitID, false, true)
end

-- WEAPON CONTROL
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

function Setup()
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

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- AVENGER
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--pieces
local body = piece ("body")
local cargo = piece ("cargo")
local cargoDoor1, cargoDoor2 = piece("cargodoor1", "cargodoor2")
local attachment = piece("attachment")
-- FX pieces


-- Constants
local ANGLE = math.floor(unitID / 100)
local UX = math.cos(ANGLE) * RADIAL_DIST
local UZ = math.sin(ANGLE) * RADIAL_DIST


local function fx()
	Signal(fx)
	SetSignalMask(fx)

	if stage == 0 then
		GG.EmitLupsSfx(unitID, "dropship_hull_heat", body, {repeatEffect = 3})
		GG.EmitLupsSfx(unitID, "dropship_hull_heat", body, {repeatEffect = 3, delay = 10})
		GG.EmitLupsSfx(unitID, "dropship_hull_heat", body, {repeatEffect = 2, delay = 20})
		for _, exhaust in ipairs(hExhausts) do
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_strong", exhaust)
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_strong", exhaust, {delay = 20})
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_strong", exhaust, {delay = 40})
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust",  exhaust, {id = "hExhaustsJets", repeatEffect = true, width = 30, length = 150})
		end
		for _, exhaust in ipairs(vExhaustLarges) do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "vExhaustsLargesJets", width = 65, length = 115})
		end
		for _, exhaust in ipairs(vExhausts) do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "vExhaustsJets", width = 50, length = 95})
		end
	end
	while stage == 0 do
		Sleep(30)
	end
	if stage == 1 then
		GG.RemoveLupsSfx(unitID, "vExhaustsJets")
		GG.RemoveLupsSfx(unitID, "vExhaustsLargesJets")
		for _, exhaust in ipairs(hExhausts) do
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_weak", exhaust)
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_weak", exhaust, {delay = 20})
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_weak", exhaust, {delay = 40})
		end
		for _, exhaust in ipairs(vExhaustLarges) do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "vExhaustsLargesJets", replace = true, width = 40, length = 90})
		end
		for _, exhaust in ipairs(vExhausts) do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "vExhaustsJets", width = 25, length = 70})
		end
	end
	while stage == 1 do
		Sleep(30)
	end
	if stage == 2 then
		GG.RemoveLupsSfx(unitID, "hExhaustsJets")
		for _, exhaust in ipairs(hExhausts) do
			GG.BlendJet(99, unitID, exhaust, "hExhaustsJets")
		end
	end
	while stage == 2 do
		Sleep(30)
	end
	if stage == 3 then
		GG.RemoveLupsSfx(unitID, "vExhaustsJets")
		GG.RemoveLupsSfx(unitID, "vExhaustsLargesJets")
		for _, exhaust in ipairs(vExhausts) do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "vExhaustsJets"})
		end
		GG.EmitLupsSfx(unitID, "exhaust_ground_winds", body, {repeatEffect = 4, delay = 125})
		GG.EmitLupsSfx(unitID, "exhaust_ground_winds", body, {repeatEffect = 4, delay = 125 + 80})
	end
	while stage == 3 do
		--SpawnCEG("dropship_heavy_dust", TX, TY, TZ)
		Sleep(30)
	end
	if stage == 4 then
		GG.RemoveLupsSfx(unitID, "hExhaustsJets")
		GG.RemoveLupsSfx(unitID, "vExhaustsJets")
		GG.RemoveLupsSfx(unitID, "vExhaustsLargeJets")
		for _, exhaust in ipairs(hExhausts) do
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_strong", exhaust)
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_strong", exhaust, {delay = 20})
			GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_strong", exhaust, {delay = 40})
		end
		local time = 114
		for t = 0, (time/3) do
			local i = t / (time/3)
			for _, exhaust in ipairs(hExhausts) do
				if (i == 1) then
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "hExhaustsJets", repeatEffect = true, delay = t*3, width = 110, length = 350})
				elseif (i > 0.33) then
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "hExhaustsJets", life = 2, delay = t*3, width = i * 110, length = i * 350})
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "hExhaustsJets", life = 1, delay = t*3+2, width = i * 100, length = i * 300})
				else
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "hExhaustsJets", life = 1, delay = t*3,   width = i * 110, length = i * 350})
					GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "hExhaustsJets", life = 2, delay = t*3+1, width = i * 80, length = i * 190})
				end
			end
		end
		for _, exhaust in ipairs(vExhaustLarges) do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "vExhaustsLargesJets", length = 80, width = 45})
		end
		for i, exhaust in ipairs(vExhausts) do
			if (i % 2 == 1) then
				GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "vExhaustsJets", length = 85, width = 55})
			else
				GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhaust, {id = "vExhaustsJets"})
			end
		end
	end
	while stage == 4 do
		Sleep(30)
	end
	if stage == 5 then
		GG.RemoveLupsSfx(unitID, "vExhaustsLargesJets")
		GG.RemoveLupsSfx(unitID, "vExhaustsJets")
	end
	while stage == 5 do
		for _, exhaust in ipairs(hExhausts) do
			EmitSfx(exhaust, SFX.CEG + 2)
			EmitSfx(exhaust, SFX.CEG + 3)
		end
		Sleep(30)
	end
end

function Setup()
	-- setup fx pieces
	for _, exhaust in ipairs(vExhaustLarges) do
		Turn(exhaust, x_axis, math.rad(89))
	end	
	for _, exhaust in ipairs(vExhausts) do
		Turn(exhaust, x_axis, math.rad(89))
	end	
	for _, exhaust in ipairs(hExhausts) do
		Turn(exhaust, y_axis, math.rad(180))
	end	
end

function Drop()
	-- Move us up to the drop position
	Spring.MoveCtrl.Enable(unitID)
	Spring.MoveCtrl.SetPosition(unitID, TX + UX, TY + DROP_HEIGHT, TZ + UZ)
	local newAngle = math.atan2(UX, UZ)
	Spring.MoveCtrl.SetRotation(unitID, 0, newAngle + math.pi, 0)
	Turn(body, x_axis, math.rad(-50))
	-- Begin the drop
	GG.PlaySoundForTeam(teamID, "BB_Dropship_Inbound", 1)
	Turn(body, x_axis, math.rad(-10), math.rad(5))
	Spring.MoveCtrl.SetVelocity(unitID, 0, -100, 0)
	Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, 10)
	Spring.MoveCtrl.SetGravity(unitID, -3.78 * GRAVITY)
	local x, y, z = Spring.GetUnitPosition(unitID)
	while y - TY > 150 + HOVER_HEIGHT do
		x, y, z = Spring.GetUnitPosition(unitID)
		local newAngle = math.atan2(x - TX, z - TZ)
		Spring.MoveCtrl.SetRotation(unitID, 0, newAngle + math.pi, 0)
		if (y - TY) < 4 * HOVER_HEIGHT and stage == 0 then
			stage = 1
			StartThread(fx)
		elseif (y - TY) < 3 * HOVER_HEIGHT and stage == 1 then
			stage = 2
		end
		Sleep(100)
	end
	-- Descent complete, move over the target
	Turn(body, x_axis, 0, math.rad(3.5))
	Spring.MoveCtrl.SetVelocity(unitID, 0, 0, 0)
	Spring.MoveCtrl.SetGravity(unitID, 0)
	local dist = GetUnitDistanceToPoint(unitID, TX, 0, TZ, false)
	while dist > 1 do
		dist = GetUnitDistanceToPoint(unitID, TX, 0, TZ, false)
		--Spring.Echo("dist", dist)
		Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, math.max(dist/50, 2))
		Sleep(30)
	end
	-- only proceed if the beacon is still ours and is secure
	if Spring.GetUnitTeam(beaconID) == Spring.GetUnitTeam(unitID) and Spring.GetUnitRulesParam(beaconID, "secure") == 1 then
		-- We're over the target area, reduce height!
		stage = 3
		local DOOR_SPEED = math.rad(60)
		Turn(cargoDoor1, z_axis, math.rad(-90), DOOR_SPEED)
		Turn(cargoDoor2, z_axis, math.rad(90), DOOR_SPEED)
		local vertSpeed = 4
		local wantedHeight = select(2, Spring.GetUnitPosition(unitID)) - HOVER_HEIGHT
		local dist = select(2, Spring.GetUnitPosition(unitID)) - wantedHeight
		while (dist > 0) do
			Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, -math.max(0.33, vertSpeed * (dist/HOVER_HEIGHT)), 0)
			Sleep(10)
			dist = select(2, Spring.GetUnitPosition(unitID)) - wantedHeight
		end
		-- We're in place. Halt and lower the cargo!
		Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, 0)
		_, y, _ = Spring.GetUnitPosition(unitID)
		local BOOM_LENGTH = y - TY - 56
		local BOOM_SPEED = 15
		Move(attachment, y_axis, -56, BOOM_SPEED)
		--WaitForMove(attachment, y_axis)
		for i = 2, 3 do
			Move(booms[i], y_axis, -BOOM_LENGTH / 2, BOOM_SPEED)
		end
		WaitForMove(booms[3], y_axis)
		Sleep(1500)
		if Spring.ValidUnitID(cargoID) and not Spring.GetUnitIsDead(cargoID) then -- might be empty on /give testing
			Spring.UnitScript.DropUnit(cargoID)
			Spring.SetUnitBlocking(cargoID, true, true, true, true, true, true, true)
			-- Let the cargo know it is unloaded
			env = Spring.UnitScript.GetScriptEnv(cargoID)
			Spring.UnitScript.CallAsUnit(cargoID, env.Unloaded)
			-- Let the beacon know upgrade is ready
			env = Spring.UnitScript.GetScriptEnv(beaconID)
			Spring.UnitScript.CallAsUnit(beaconID, env.ChangeType, true)
		end
		-- Cargo is down, close the doors!
		for i = 2, 3 do
			Move(booms[i], y_axis, 0, BOOM_SPEED * 2)
		end
		WaitForMove(booms[3], y_axis)
		Turn(cargoDoor1, z_axis, 0, DOOR_SPEED)
		Turn(cargoDoor2, z_axis, 0, DOOR_SPEED)
		WaitForTurn(cargoDoor2, z_axis)
	else -- bugging out, refund
		Spring.AddTeamResource(teamID, "metal", UnitDefs[Spring.GetUnitDefID(cargoID)].metalCost)
	end
	-- Take off!
	stage = 4
	--Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, 5)
	Spring.MoveCtrl.SetRelativeVelocity(unitID, 0, 0, 5)
	Spring.MoveCtrl.SetGravity(unitID, -0.75 * GRAVITY)
	Turn(body, x_axis, math.rad(-30), math.rad(10))
	WaitForTurn(body, x_axis)
	Turn(body, x_axis, math.rad(-70), math.rad(15))
	WaitForTurn(body, x_axis)
	Turn(body, x_axis, math.rad(-80), math.rad(5))
	WaitForTurn(body, x_axis)
	Spring.MoveCtrl.SetGravity(unitID, -4 * GRAVITY)
	stage = 5
	Sleep(1500)
	Spin(body, z_axis, math.rad(180), math.rad(45))
	Sleep(2000)
	StopSpin(body, z_axis, math.rad(45))
	Sleep(2000)
	-- We're out of the atmosphere, bye bye!
	Spring.DestroyUnit(unitID, false, true)
end

function script.Killed(recentDamage, maxHealth)
end
