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
for i = 1,info.numGears do
	gears[i] = {
		door  = piece("gear" .. i .. "_door"),
		joint = piece("gear" .. i .. "_joint"),
		gear  = piece("gear" .. i)
	}
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


-- localised functions
-- SyncedCtrl
local SpawnCEG = Spring.SpawnCEG
-- Constants
DROP_HEIGHT = 10000
GRAVITY = 120/Game.gravity
X, _, Z = Spring.GetUnitPosition(unitID)
GY = Spring.GetGroundHeight(X, Z)
CEG = SFX.CEG + #weapons

local HALF_MAP_X = Game.mapSizeX/2
local HALF_MAP_Z = Game.mapSizeZ/2
local facing = math.abs(HALF_MAP_X - X) > math.abs(HALF_MAP_Z - Z)
			and ((X > HALF_MAP_X) and 3 or 1)
			or ((Z > HALF_MAP_Z) and 2 or 0)
			
HEADING = facing * 16384 + math.random(-1820, 1820)

-- LANDING CODE
-- Variables
stage = 0
up = false
cargo = {}

local beaconID
local numCargo = 0

function LoadCargo(cargoID, callerID)
	--Spring.Echo("Loading", cargoID, "of type", UnitDefs[Spring.GetUnitDefID(outpostID)].name)
	beaconID = callerID
	numCargo = numCargo + 1
	cargo[numCargo] = cargoID
	Spring.UnitScript.AttachUnit(cargoPieces[numCargo] or -1, cargoID)
end

include ("anims/dropships/union.lua")

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
trackEmitters = {}
for i = 1, 7, 2 do -- TODO: setup a table in lus_helper
	trackEmitters[i] = piece("laser_emitter_" .. i)
	trackEmitters[i+1] = trackEmitters[i]
end

turrets = {}
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
	Spring.SetUnitAlwaysVisible(unitID, true)
	Spring.SetUnitNoSelect(unitID, true)
	Setup()
	StartThread(fx)
	Drop()
end


function script.AimWeapon(weaponID, heading, pitch)
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
	return trackEmitters[weaponID] or turrets[weaponID] or launchers[weaponID] or flares[weaponID] or 1
end

function script.QueryWeapon(weaponID)
	if missileWeaponIDs[weaponID] then
		return launchers[weaponID] --launchPoints[weaponID][currPoints[weaponID]] or launchPoints[weaponID][1]
	else
		return flares[weaponID]
	end
end 