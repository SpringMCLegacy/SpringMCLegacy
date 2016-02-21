-- useful global stuff
weapons = unitDef.weapons
info = GG.lusHelper[unitDefID]

-- Localisations
SpawnCEG = Spring.SpawnCEG
GetUnitDistanceToPoint = GG.GetUnitDistanceToPoint
deg, rad = math.deg, math.rad

--piece defines

-- Landing Gear Pieces
gears = {}
for i = 1,info.numGears do
	gears[i] = {
		door  = piece("gear" .. i .. "_door"),
		joint = piece("gear" .. i .. "_joint"),
		gear  = piece("gear" .. i)
	}
end

-- loading booms
booms = {}
for i = 1,info.numBooms do
	booms[i] = piece("boom" .. i)
end
cargoPieces = {}
for i = 1,info.numCargoPieces do
	cargoPieces[i] = piece("cargopiece" .. i)
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

-- Constants
HOVER_HEIGHT = unitDef.customParams.hoverheight or 0
DROP_HEIGHT = 10000 + HOVER_HEIGHT
GRAVITY = 120/Game.gravity
TX, TY, TZ = Spring.GetUnitPosition(unitID)
GY = Spring.GetGroundHeight(TX, TZ)
CEG = SFX.CEG + #weapons

-- use HEADING if you want the unit to face towards map centre
local HALF_MAP_X = Game.mapSizeX/2
local HALF_MAP_Z = Game.mapSizeZ/2
local facing = math.abs(HALF_MAP_X - TX) > math.abs(HALF_MAP_Z - TZ)
			and ((TX > HALF_MAP_X) and 3 or 1)
			or ((TZ > HALF_MAP_Z) and 2 or 0)
			
HEADING = facing * 16384 + math.random(-1820, 1820)

-- use ANGLE if you want the unit to fly in at a random angle
RADIAL_DIST = unitDef.customParams.radialdist or 0
ANGLE = math.rad(math.random(360)) --math.floor(unitID / 100)
UX = math.cos(ANGLE) * RADIAL_DIST
UZ = math.sin(ANGLE) * RADIAL_DIST

-- Variables
stage = 0
noFiring = false
up = false
touchDown = false
beaconID = nil
cargo = {}
numCargo = 0

function LoadCargo(cargoID, callerID)
	--Spring.Echo("Loading", cargoID, "of type", UnitDefs[Spring.GetUnitDefID(outpostID)].name)
	beaconID = callerID
	numCargo = numCargo + 1
	cargo[numCargo] = cargoID
	Spring.UnitScript.AttachUnit(cargoPieces[numCargo] or -1, cargoID)
	GG.SetSquad(cargoID, teamID) -- will ignore non-vehicles
end

include ("anims/dropships/" .. unitDef.name:sub(unitDef.name:match("^.*()_") + 1, -1) .. ".lua")

-- WEAPON CONTROL

-- localised API functions
local GetUnitSeparation 		= Spring.GetUnitSeparation
local GetUnitCommands   		= Spring.GetUnitCommands
-- localised GG functions
local GetUnitUnderJammer = GG.GetUnitUnderJammer
local IsUnitNARCed = GG.IsUnitNARCed
local IsUnitTAGed = GG.IsUnitTAGed

-- Info from lusHelper gadget
missileWeaponIDs = info.missileWeaponIDs
local flareOnShots = info.flareOnShots
local jammableIDs = info.jammableIDs
local missileWeaponIDs = info.missileWeaponIDs
local flareOnShots = info.flareOnShots
local jammableIDs = info.jammableIDs
local launcherIDs = info.launcherIDs
local barrelRecoils = info.barrelRecoilDist
local burstLengths = info.burstLengths
local minRanges = info.minRanges
local amsIDs = info.amsIDs
local mainTurretIDs = info.mainTurretIDs
local weaponProgenitors = info.weaponProgenitors

TURRET_SPEED = math.rad(30)
ELEVATION_SPEED = math.rad(60)

-- weapons pieces
trackEmitters = {}
for i = 1, 7, 2 do -- TODO: setup a table in lus_helper
	trackEmitters[i] = piece("laser_emitter_" .. i)
	trackEmitters[i+1] = trackEmitters[i]
end

turrets = {}
local flares = {}
--local turrets = info.turrets

local mantlets = {}
local barrels = {}
local launchers = {}
local launchPoints = {}
local currPoints = {}
local missileSignals = {}
local amsSignal = {}

for weaponID = 1, info.numWeapons do
	if missileWeaponIDs[weaponID] then
		if launcherIDs[weaponID] then
			launchers[weaponID] = piece("launcher_" .. weaponID)
		end
		missileSignals[weaponID] = {}
		if piece("launchpoint_" .. weaponID .. "_1") then -- launchpoints exist, use them
			launchPoints[weaponID] = {}
			currPoints[weaponID] = 1
			for i = 1, burstLengths[weaponID] do
				launchPoints[weaponID][i] = piece("launchpoint_" .. weaponID .. "_" .. i)
			end	
		end
	elseif weaponID then
		flares[weaponID] = piece ("flare_" .. weaponID)
	end
	if info.turretIDs[weaponID] then
		turrets[weaponID] = piece("turret_" .. weaponID)
	end
	if info.mantletIDs[weaponID] then
		mantlets[weaponID] = piece("mantlet_" .. weaponID)
	end
	if info.barrelIDs[weaponID] then
		barrels[weaponID] = piece("barrel_" .. weaponID)
	end
end

function script.Create()
	Spring.SetUnitAlwaysVisible(unitID, true)
	--Spring.SetUnitNoSelect(unitID, true)
	Setup()
	StartThread(fx)
	StartThread(Drop)
end


function script.AimWeapon(weaponID, heading, pitch)
	if noFiring then return false end
	if weaponID < 25 then
		Signal(2 ^ (weaponID - 1))
		SetSignalMask(2 ^ (weaponID - 1))
	elseif missileWeaponIDs[weaponID] then -- can only use 24 weapons in this way, so LRM are seperate
		Signal(missileSignals[weaponID])
		SetSignalMask(missileSignals[weaponID])
	else -- LAMS
		Signal(amsSignal)
		SetSignalMask(amsSignal)
	end
	if amsIDs[weaponID] then 
		return true
	end
	-- use a weapon-specific turret if it exists
	if trackEmitters[weaponID] then -- LBLs
		if weaponID % 2 == 1 then -- only first in each pair
			Turn(trackEmitters[weaponID], y_axis, heading, TURRET_SPEED) -- + math.rad(90 * (weaponID - 1)/2), TURRET_SPEED)
			WaitForTurn(trackEmitters[weaponID], y_axis)
		end
	elseif turrets[weaponID] then
		Turn(turrets[weaponID], y_axis, heading, TURRET_SPEED)
	elseif mainTurretIDs[weaponID] then -- otherwise use main
		Turn(turret, y_axis, heading, TURRET_SPEED)
	elseif flares[weaponID] then
		Turn(flares[weaponID], y_axis, heading)
	end
	if mantlets[weaponID] then
		Turn(mantlets[weaponID], x_axis, -pitch, ELEVATION_SPEED)
	elseif missileWeaponIDs[weaponID] then -- yeah it happens if, in this case, launchpoint_1_# are attached to launcher_1 but launchpoint_2_# and 3 are attached to launcher_1 as well
		if launchers[weaponID] then
			Turn(launchers[weaponID], x_axis, -pitch, ELEVATION_SPEED)
		elseif weaponID > 1 and launchers[1] then
			Turn(launchers[1], x_axis, -pitch, ELEVATION_SPEED)
		elseif launchPoints[weaponID] then
			for i = 1, burstLengths[weaponID] do
				Turn(launchPoints[weaponID][i], x_axis, -pitch, ELEVATION_SPEED)
			end
		end
	elseif flares[weaponID] then
		Turn(flares[weaponID], x_axis, -pitch)
	end
	if weaponProgenitors[weaponID] then
		WaitForTurn(piece(weaponProgenitors[weaponID]), y_axis)
	end
	if mantlets[weaponID] then
		WaitForTurn(mantlets[weaponID], x_axis)
	end
	return WeaponCanFire(weaponID)
end

function script.BlockShot(weaponID, targetID, userTarget)
	if amsIDs[weaponID] then return false end
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
	local jammable = jammableIDs[weaponID]
	if jammable then
		if targetID then
			local jammed = GetUnitUnderJammer(targetID) and (not IsUnitNARCed(targetID)) and (not IsUnitTAGed(targetID))
			if jammed then
				--Spring.Echo("Can't fire weapon " .. weaponID .. " as target is jammed")
				Spring.SetUnitRulesParam(unitID, "MISSILE_TARGET_JAMMED", Spring.GetGameFrame(), {inlos = true})
				return true 
			else
				Spring.SetUnitRulesParam(targetID, "ENEMY_MISSILE_LOCK", Spring.GetGameFrame(), {inlos = true})
			end
		end
	end
	--if #cargo > 0 then StartThread(Unload, targetID) end
	return false
end

function script.FireWeapon(weaponID)
	if barrels[weaponID] and barrelRecoils[weaponID] then
		Move(barrels[weaponID], z_axis, -barrelRecoils[weaponID], BARREL_SPEED)
		WaitForMove(barrels[weaponID], z_axis)
		Move(barrels[weaponID], z_axis, 0, 10)
	end
	if not missileWeaponIDs[weaponID] and not flareOnShots[weaponID] then
		EmitSfx(flares[weaponID], SFX.CEG + weaponID)
	end
end

function script.Shot(weaponID)
	if missileWeaponIDs[weaponID] and launchPoints[weaponID] then
		EmitSfx(launchPoints[weaponID][currPoints[weaponID]], SFX.CEG + weaponID)
        currPoints[weaponID] = currPoints[weaponID] + 1
        if currPoints[weaponID] > burstLengths[weaponID] then 
			currPoints[weaponID] = 1
        end
	elseif 	missileWeaponIDs[weaponID] then
		EmitSfx(launchers[weaponID], SFX.CEG + weaponID)
	elseif flareOnShots[weaponID] then
		EmitSfx(flares[weaponID], SFX.CEG + weaponID)
	end
end

function script.AimFromWeapon(weaponID) 
	return trackEmitters[weaponID] or turrets[weaponID] or launchers[weaponID] or flares[weaponID] or 1
end

function script.QueryWeapon(weaponID) 
	if missileWeaponIDs[weaponID] then
		return launchPoints[weaponID] and launchPoints[weaponID][currPoints[weaponID]] or launchers[weaponID]
	else
		return flares[weaponID]
	end
end

local dead = false
function script.HitByWeapon(x, z, weaponID, damage)
	if damage > Spring.GetUnitHealth(unitID) then
		if not dead then
			dead = true
			for i, cargoID in ipairs(cargo) do
				Spring.DestroyUnit(cargoID, false, true)
			end
			Signal(1)
			Signal(fx)
			Spring.MoveCtrl.SetGravity(unitID, 0.75 * GRAVITY)	
			Spring.MoveCtrl.SetCollideStop(unitID, true)
			Spring.MoveCtrl.SetTrackGround(unitID, true)
		end
		return 0
	end
end