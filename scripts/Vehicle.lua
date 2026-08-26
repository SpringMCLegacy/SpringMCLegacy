-- Vehicle Script
-- useful global stuff
info = GG.lusHelper[unitDefID]

moving = false

-- localised API functions
local SetUnitRulesParam = Spring.SetUnitRulesParam
local GetUnitSeparation = Spring.GetUnitSeparation
local GetUnitCommands   = Spring.GetUnitCommands
local GetUnitLastAttackedPiece = Spring.GetUnitLastAttackedPiece
-- localised GG functions
local GetUnitDistanceToPoint = GG.GetUnitDistanceToPoint
local GetUnitUnderJammer = GG.GetUnitUnderJammer
local IsUnitNARCed = GG.IsUnitNARCed
local IsUnitTAGed = GG.IsUnitTAGed

function PlaySound(sound, volume, channel)
	GG.PlaySoundAtUnit(unitID, sound, volume, channel)
end

-- includes
include "smokeunit.lua"

-- Info from lusHelper gadget
numWeapons = info.numWeapons
heatLimit = info.heatLimit
baseCoolRate = info.coolRate
local coolRate = baseCoolRate
local inWater = false
local activated = true
local lastFiredWeapon = 0

local missileWeaponIDs = info.missileWeaponIDs
local flareOnShots = info.flareOnShots
local jammableIDs = info.jammableIDs
local launcherIDs = info.launcherIDs
local barrelRecoils = info.barrelRecoilDist
local burstLengths = info.burstLengths
local firingHeats = info.firingHeats
local ammoTypes = info.ammoTypes
local minRanges = info.minRanges
local spinSpeeds = info.spinSpeeds
local maxAmmo = info.maxAmmo
local currAmmo = {} -- copy maxAmmo table into currAmmo
for k,v in pairs(maxAmmo) do 
	currAmmo[k] = v 
	SetUnitRulesParam(unitID, "ammo_" .. k, 100)
end
local amsIDs = info.amsIDs
local hover = info.hover
local wheeled = unitDef.customParams.wheels
local vtol = info.vtol
local aero = info.aero
local mainTurretIDs = info.mainTurretIDs
local turretOnTurretIDs = info.turretOnTurretIDs
local turretOnTurretSides = info.turretOnTurretSides

local weaponProgenitors = info.weaponProgenitors
local limbHPs = {}
local wheelsRemaining = {}
local steerWheels = {[1] = true, [info.numWheels/2+1] = true}
wheelsRemaining["l"] = info.numWheels / 2
wheelsRemaining["r"] = info.numWheels / 2
for limb,limbHP in pairs(info.limbHPs) do -- copy table from defaults
	limbHPs[limb] = limbHP
	SetUnitRulesParam(unitID, "limb_hp_" .. limb, 100)
end

--Turning/Movement Locals
local TURRET_SPEED = info.turretTurnSpeed
local TURRET_2_SPEED = info.turret2TurnSpeed
local ELEVATION_SPEED = info.elevationSpeed
local BARREL_SPEED = info.barrelRecoilSpeed
local SPIN_WAIT_MULT = 5 -- how many times spinSpeed to wait
local WHEEL_SPEED = info.wheelSpeed
local WHEEL_ACCEL = info.wheelAccel
local RESTORE_DELAY = Spring.UnitScript.GetLongestReloadTime(unitID) * 2

local currLaunchPoint = 1
local currHeatLevel = 0
local excessHeat = 0
SetUnitRulesParam(unitID, "heat", 0)
SetUnitRulesParam(unitID, "excess_heat", 0)

--piece defines
local body, turret = piece ("body", "turret")

local wheels = {}
local trackr, trackl, wakepoint, rotor
if hover then
	wakepoint = piece ("wakepoint")
elseif vtol then
	-- no op
elseif aero then
	-- no op
else
	trackr, trackl = piece ("trackr", "trackl")
	for i = 1, info.numWheels do
		wheels[i] = piece ("wheel"..i)
	end
end

local wakepoint = piece ("wakepoint")

local flares = {}
local turrets = {}
local mantlets = {}
local barrels = {}
local launchers = {}
local launchPoints = {}
local currPoints = {}
local spinners = {}
local playerDisabled = {}
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
	if info.turretIDs[weaponID] then
		turrets[weaponID] = piece("turret_" .. weaponID)
	end
	if info.mantletIDs[weaponID] then
		mantlets[weaponID] = piece("mantlet_" .. weaponID)
	end
	if spinSpeeds[weaponID] then
		spinners[weaponID] = {
			pieceNum = piece("barrels_" .. weaponID),
			state = 0,
			wait = math.deg(spinSpeeds[weaponID]) * SPIN_WAIT_MULT,
		}
	elseif info.barrelIDs[weaponID] then
		barrels[weaponID] = piece("barrel_" .. weaponID)
	end
	playerDisabled[weaponID] = false
	SetUnitRulesParam(unitID, "weapon_" .. weaponID, "active")
end

local function RestoreAfterDelay()
	Spring.SetUnitRulesParam(unitID, "fighting", 1)
	Sleep(RESTORE_DELAY)
	if turret then
		Turn(turret, y_axis, 0, TURRET_SPEED)
	end
	for id in pairs(mantlets) do
		Turn(mantlets[id], x_axis, 0, ELEVATION_SPEED)
	end
	for id in pairs(launchers) do
		Turn(launchers[id], x_axis, 0, ELEVATION_SPEED)
	end
	Spring.SetUnitRulesParam(unitID, "fighting", 0)
	GG.Embark(unitID)
	--Spring.Echo(unitID, "RestoreAfterDelay called GG.Embark")
end

-- non-local function called by gadgets/game_ammo.lua
function ChangeAmmo(ammoType, amount) 
	local newAmmoLevel = currAmmo[ammoType] + amount -- amount is a -ve to deduct
	if newAmmoLevel <= maxAmmo[ammoType] then
		currAmmo[ammoType] = newAmmoLevel
		SetUnitRulesParam(unitID, "ammo_" .. ammoType, 100 * newAmmoLevel / maxAmmo[ammoType])
		return true -- Ammo was changed
	end
	return false -- Ammo was not changed
end

local function SpinBarrels(weaponID, start)
	local spinfo = spinners[weaponID]
	Signal(spinfo)
	SetSignalMask(spinfo)
	if start and spinfo.state == 0 then
		spinfo.state = 1
		Spin(spinfo.pieceNum, z_axis, spinSpeeds[weaponID], spinSpeeds[weaponID] / SPIN_WAIT_MULT)
		Sleep(spinfo.wait) -- spin up wait
		spinfo.state = 2
	elseif not start and spinfo.state > 0 then
		Sleep(spinfo.wait) -- spin down wait
		StopSpin(spinfo.pieceNum, z_axis, spinSpeeds[weaponID]/10)
		spinfo.state = 0
	end
end

function ChangeHeat(amount)
	currHeatLevel = currHeatLevel + amount
	if currHeatLevel > heatLimit then
		excessHeat = excessHeat + currHeatLevel - heatLimit
		currHeatLevel = heatLimit
		if excessHeat >= heatLimit then
			Spring.DestroyUnit(unitID, true)
		end
	elseif currHeatLevel < 0 then
		currHeatLevel = 0
	end
	SetUnitRulesParam(unitID, "heat", math.floor(100 * currHeatLevel / heatLimit))
	SetUnitRulesParam(unitID, "excess_heat", math.floor(100 * excessHeat / heatLimit))
end

local function CoolOff()
	local min = math.min
	-- localised API functions
	local AddUnitSeismicPing = Spring.AddUnitSeismicPing
	local GetGameFrame = Spring.GetGameFrame
	local GetGroundHeight = Spring.GetGroundHeight
	local GetUnitBasePosition = Spring.GetUnitBasePosition
	local SetUnitWeaponState = Spring.SetUnitWeaponState
	-- lusHelper info
	local reloadTimes = info.reloadTimes
	local numWeapons = info.numWeapons
	local waterCoolRate = info.waterCoolRate
	local hasEcm = info.hasEcm
	-- variables	
	local heatElevated = false
	local heatCritical = false
	while true do
		local heatElevatedLimit = 0.5 * heatLimit
		local heatCriticalLimit = 0.9 * heatLimit
		coolRate = baseCoolRate -- reset coolRate in case of perk
		if inWater then
			local x, _, z = GetUnitBasePosition(unitID)
			local depth = min(4, GetGroundHeight(x, z) / -10)
			coolRate = baseCoolRate * waterCoolRate * depth
		end
		if currHeatLevel > heatCriticalLimit then 
			if not heatCritical then -- either elevated->critical or normal->critical
				heatElevated = false
				heatCritical = true
				-- halt weapon fire here
				for weaponID = 1, numWeapons do
					SetUnitWeaponState(unitID, weaponID, {reloadTime = 99999, reloadFrame = 99999})
				end
			end
		elseif currHeatLevel > heatElevatedLimit then
			if heatCritical and not heatElevated then -- critical -> elevated
				heatElevated = true
				excessHeat = excessHeat / 2
			elseif not heatElevated then -- normal -> elevated
				heatElevated = true
				-- reduce weapon rate here
				for weaponID = 1, numWeapons do
					local reload = reloadTimes[weaponID] * 2
					SetUnitWeaponState(unitID, weaponID, {reloadTime = reload})
				end
			end
		else
			if heatCritical then -- critical->elevated->normal
				-- reset weapon rate here
				for weaponID = 1, numWeapons do
					local currFrame = GetGameFrame()
					SetUnitWeaponState(unitID, weaponID, {reloadTime = reloadTimes[weaponID], reloadFrame = currFrame + reloadTimes[weaponID] * 30})
				end
			elseif heatElevated then -- elevated->normal
				-- reset weapon rate here
				for weaponID = 1, numWeapons do
					SetUnitWeaponState(unitID, weaponID, {reloadTime = reloadTimes[weaponID]})
				end
			end
			heatCritical = false
			heatElevated = false
			excessHeat = 0 -- if we managed to return to normal heat, remove all excess
		end
		ChangeHeat(-coolRate)
		if hasEcm and not moving then
			AddUnitSeismicPing(unitID, 20)
		end
		Sleep(1000) -- cools once per second
	end
end

local SIG_WAKE = 2 ^ (info.numWeapons + 1)
local function HoverWake(water)
	Signal(SIG_WAKE)
	SetSignalMask(SIG_WAKE)

	while true do
		GG.EmitSfxName(unitID, wakepoint, "hover_dust")
		Sleep(100)
	end
end

function script.setSFXoccupy(terrainType)
	if vtol or aero then return end
	if terrainType == 2 or terrainType == 1 then -- water
		inWater = true
	else
		inWater = false
		coolRate = baseCoolRate
	end
	if wakepoint then
		StartThread(HoverWake, inWater)
	end
end

function ToggleWeapon(weaponID, code)
	-- codes are: 1: destroyed, 2: repaired, nil implies player toggle
	if not code then
		playerDisabled[weaponID] = not playerDisabled[weaponID]
		SetUnitRulesParam(unitID, "weapon_" .. weaponID, playerDisabled[weaponID] and "disabled" or "active")
	elseif code == 1 then
		SetUnitRulesParam(unitID, "weapon_" .. weaponID, "destroyed")
	elseif code == 2 then
		-- restore to previous setting
		SetUnitRulesParam(unitID, "weapon_" .. weaponID, playerDisabled[weaponID] and "disabled" or "active")
	end
end

function SmokeLimb(limb, piece)
	local maxHealth = info.limbHPs[limb] / 100
	while not limb:find("wheel") do -- only smoke if it is not a wheel
		local health = limbHPs[limb]/maxHealth
		if (health <= 66) then -- only smoke if less then 2/3rd limb maxhealth left
			EmitSfx(piece, SFX.CEG + info.numWeapons + 2)
			EmitSfx(piece, SFX.CEG + info.numWeapons + 3)
		end
		Sleep(20*health + 150)
	end
end

function FallOver(dir, angle)
	Spring.MoveCtrl.Enable(unitID)
	local dir = (dir == "l") and -1 or 1
	Turn(body, z_axis, dir * math.rad(angle))
end

local function CheckWheels(side)
	wheelsRemaining[side] = wheelsRemaining[side] - 1
	if wheelsRemaining[side] == 0 then
		StartThread(FallOver, side, 30)
	end
end

function hideLimbPieces(limb, hide)
	local limbWeapons = EMPTY -- can safely use EMPTY here as will be replaced, not modified
	local rootPiece = piece(limb)
	if limb == "turret" then
		limbWeapons = mainTurretIDs
		Spring.SetUnitMidAndAimPos(unitID, 0, 0, 0, 0, -1, 0, true)
	elseif limb:find("wheel") then -- slow?
		local wheelNum = limb:sub(6,-1)
		local side = "r"
		if tonumber(wheelNum) > (info.numWheels/2) then -- left
			side = "l"
		end
		CheckWheels(side)
	elseif limb:find("track") then
		local side = limb:sub(6,-1)
		StartThread(FallOver, side, 2.5)
		RecursiveHide(rootPiece, hide) -- hide track first
		local wheelNum = math.random(info.numWheels/2 + ((side == "l" and info.numWheels/2) or 0))
		rootPiece = wheels[wheelNum]
	else  -- assume limb is a wing or rotor
		if hide then
			SetUnitValue(COB.CRASHING, 1)
		end
	end
	RecursiveHide(rootPiece, hide)
	if hide then
		EmitSfx(rootPiece, SFX.CEG + info.numWeapons + 1)
		Explode(rootPiece, SFX.FIRE + SFX.SMOKE + SFX.RECURSIVE)
		for id, valid in pairs(limbWeapons) do
			if valid then
				local weapDef = WeaponDefs[unitDef.weapons[id].weaponDef]
				--Spring.Echo(unitDef.humanName .. ": " .. weapDef.name .. " destroyed!")
				ToggleWeapon(id, 1)
			end
		end
	else
		for id, valid in pairs(limbWeapons) do
			if valid then
				local weapDef = WeaponDefs[unitDef.weapons[id].weaponDef]
				ToggleWeapon(id, 2)
			end
		end		
	end
end

function limbHPControl(limb, damage)
	local currHP = limbHPs[limb]
	--Spring.Echo(limb, currHP, damage)
	if currHP and currHP > 0 or damage < 0 then
		local newHP = math.min(limbHPs[limb] - damage, info.limbHPs[limb]) -- don't allow HP above max
		if newHP < 0 then 
			hideLimbPieces(limb, true)
			newHP = 0
		elseif currHP == 0 then -- can only get here if damage < 0 i.e. repairing
			hideLimbPieces(limb, false)
		end
		limbHPs[limb] = newHP
		SetUnitRulesParam(unitID, "limb_hp_" .. limb, newHP/info.limbHPs[limb]*100)
	end
	return currHP
end

function script.HitByWeapon(x, z, weaponID, damage)
	local wd = WeaponDefs[weaponID]
	if not wd then return damage end
	local heatDamage = wd.customParams.heatdamage or 0
	--Spring.Echo(wd.customParams.heatdamage)
	ChangeHeat(heatDamage)
	local hitPiece = GetUnitLastAttackedPiece(unitID) or ""
	local module = info.progenitorMap[hitPiece] or "body"
	local limbMult = (weaponID == GG.lusHelper.MG_WDID) and 40 or 1
	local mult = 1
	if module == "body" then 
		return damage
	elseif module == "turret" then
		mult = 0.5 -- still apply 50% of the damage to main unit too
		limbHPControl(module, damage) -- MG does not get bonus vs turret
		return damage * mult
	elseif wheeled and hitPiece:find("wheel") then
		mult = 0.1 -- apply only 10% damage
	elseif hitPiece:find("track") then
		mult = 0.1 -- apply only 10% damage
	else -- turret, wing or rotor
		mult = 0.5 -- still apply 50% of the damage to main unit too
	end
	limbHPControl(module, damage * limbMult)
	return damage * mult
end

local cargo = {}
local link = piece("link")
--[[local function Unload(targetID)
	Spring.GiveOrderToUnit(unitID, CMD.STOP, {}, {})
	for i = 1, #cargo do
		local cargoID = cargo[i]
		Spring.UnitScript.AttachUnit(link, cargoID)
		Sleep(60)
		Spring.UnitScript.DropUnit(cargoID)
		Spring.GiveOrderToUnit(cargoID, CMD.ATTACK, {targetID}, {})
		cargo[i] = nil
	end
end]]

function script.TransportPickup(cargoID)
	cargo[#cargo + 1] = cargoID
	Spring.UnitScript.AttachUnit(-1, cargoID)
end

local closeRange = unitDef.losRadius --WeaponDefs[unitDef.weapons[1].weaponDef].range * 0.9
local function Wobble()
	local angleX, angleZ
	local ROCK_ANGLE = 4
	local ROCK_SPEED = math.rad(2.0)
	while true do
		angleX = math.rad(math.random(-ROCK_ANGLE, ROCK_ANGLE))
		angleZ = math.rad(math.random(-ROCK_ANGLE, ROCK_ANGLE))
		
    	Turn(body, x_axis, angleX, ROCK_SPEED)
    	Turn(body, z_axis, angleZ, ROCK_SPEED)
    	WaitForTurn(body, x_axis)
    	WaitForTurn(body, z_axis)
    	Turn(body, x_axis, 0, ROCK_SPEED / 2)
    	Turn(body, z_axis, 0, ROCK_SPEED / 2)
		
    	Sleep(50)
	end
end

local deployed = false
	
function Load(passengerID)
	Spring.UnitAttach(unitID, passengerID, -1)
	--cargo[#cargo + 1] = passengerID
	cargo[passengerID] = true
	deployed = false
end

local function UnLoad(targetID)
	deployed = true
	-- TODO: Animation
	local count = 0
	--Spring.Echo("Target ID is", targetID)
	for passengerID in pairs(cargo) do
		Spring.SetUnitRulesParam(passengerID, "APC", unitID, {["public"] = true})
		Spring.SetUnitLoadingTransport(passengerID, unitID)
		Spring.UnitDetach(passengerID)
		count = count + 1
		Sleep(500)
	end
	GG.DisEmbark(unitID, cargo, targetID, count)
	--cargo = nil -- reset cargo container, so we get a clean roster when they re-embark (perhaps some died :()
end

if unitDef.name == "brv" then
	local STRETCH_SPEED = TURRET_SPEED * 2
	
	local turret, pitchRef = piece("turret", "pitchref")
	local lArm = {}
	local rArm = {}
	local lHand, rHand = piece("lhand", "rhand")
	for i = 1, 4 do
		lArm[i] = piece("larm" .. i)
		rArm[i] = piece("rarm" .. i)
	end
	local lFinger = {}
	local rFinger = {}
	for i = 1, 4 do
		lFinger[i] = piece("lfinger" .. i)
		rFinger[i] = piece("rfinger" .. i)
	end
	local link = piece("link")
	local bed, lBedWall, rBedWall = piece("bed", "lbedwall", "rbedwall")
	
	function SetupArms(reset, sleepDelay)
		Sleep(sleepDelay or 1)
		--TURRET_SPEED = info.turretTurnSpeed
		--ELEVATION_SPEED = info.elevationSpeed
		-- TODO: setup the customparams
--		STRETCH_SPEED = TURRET_SPEED * 2
		--TURRET_SPEED = TURRET_SPEED / 4
		--ELEVATION_SPEED = ELEVATION_SPEED / 4
		
		Turn(turret, y_axis, math.pi, reset and TURRET_SPEED)
		Turn(bed, y_axis, math.pi) -- for correct rotation when attached
		Turn(lArm[1], x_axis, -math.rad(65), reset and ELEVATION_SPEED)
		Turn(rArm[1], x_axis, -math.rad(65), reset and ELEVATION_SPEED)
		Turn(lArm[2], x_axis, math.rad(25+65), reset and ELEVATION_SPEED)
		Turn(rArm[2], x_axis, math.rad(25+65), reset and ELEVATION_SPEED)
		for i = 1, 4 do
			Turn(lFinger[i], x_axis, 0, ELEVATION_SPEED)
			Turn(rFinger[i], x_axis, 0, ELEVATION_SPEED)
		end
		Turn(lBedWall, z_axis, 0, ELEVATION_SPEED)
		Turn(rBedWall, z_axis, 0, ELEVATION_SPEED)
	end

	local function GrabIt(featureID)	
		local fMass = FeatureDefs[Spring.GetFeatureDefID(featureID)].mass
		local slowDown = 2000/fMass
		local pelvis = Spring.GetFeaturePieceMap(featureID).pelvis
		local fx, fy, fz = Spring.GetFeaturePiecePosDir(featureID, pelvis)
		fy = fy + 10
		
		local x,y,z = Spring.GetUnitPiecePosDir(unitID, turret)
		local brvHeading = GG.Vector.HeadingToRadians(Spring.GetUnitHeading(unitID))
		local heading = math.atan2(fx-x, fz-z) - brvHeading
		
		-- get arm into position
		Turn(turret, y_axis, heading, TURRET_SPEED)
		WaitForTurn(turret, y_axis)
		for i = 1, 4 do
			Turn(lFinger[i], x_axis, math.rad(35) * (-1)^i, ELEVATION_SPEED)
			Turn(rFinger[i], x_axis, math.rad(35) * (-1)^i, ELEVATION_SPEED)
		end
		Turn(lArm[1], x_axis, 0, ELEVATION_SPEED)
		Turn(rArm[1], x_axis, 0, ELEVATION_SPEED)
		Turn(lArm[2], x_axis, math.rad(25), ELEVATION_SPEED)
		Turn(rArm[2], x_axis, math.rad(25), ELEVATION_SPEED)
		WaitForTurn(rArm[2], x_axis)
		
		x,y,z = Spring.GetUnitPiecePosDir(unitID, pitchRef)
		local dist = GG.Vector.DistanceBetween(x,y,z,fx,fy,fz)
		local pitch = math.asin((y-fy)/dist)
		--Spring.Echo("heading", math.deg(heading), "pitch", math.deg(pitch), "distance", dist)

		Turn(lArm[2], x_axis, pitch, ELEVATION_SPEED*2)
		Turn(rArm[2], x_axis, pitch, ELEVATION_SPEED*2)
		WaitForTurn(rArm[2], x_axis)
		for i = 3, 4 do
			Move(lArm[i], z_axis, (dist-30) / 3, STRETCH_SPEED)
			Move(rArm[i], z_axis, (dist-30) / 3, STRETCH_SPEED)
		end
		WaitForMove(rArm[4], z_axis)
		for i = 1, 4 do
			Turn(lFinger[i], x_axis, 0, ELEVATION_SPEED)
			Turn(rFinger[i], x_axis, 0, ELEVATION_SPEED)
		end
		WaitForTurn(rFinger[4], x_axis)
		GG.FeatureAttach(unitID, link, featureID)
		
		-- picked up, move over bed
		Turn(lBedWall, z_axis, -math.rad(90), ELEVATION_SPEED)
		Turn(rBedWall, z_axis, math.rad(90), ELEVATION_SPEED)
		Turn(lArm[1], x_axis, -math.rad(65), ELEVATION_SPEED * slowDown)
		Turn(rArm[1], x_axis, -math.rad(65), ELEVATION_SPEED * slowDown)
		Turn(lArm[2], x_axis, math.rad(65), ELEVATION_SPEED * slowDown)
		Turn(rArm[2], x_axis, math.rad(65), ELEVATION_SPEED * slowDown)
		WaitForTurn(rArm[2], x_axis)
		for i = 3, 4 do
			Move(lArm[i], z_axis, 2, STRETCH_SPEED * slowDown)
			Move(rArm[i], z_axis, 2, STRETCH_SPEED * slowDown)
		end
		WaitForMove(rArm[4], z_axis)
		Turn(turret, y_axis, math.pi, TURRET_SPEED * slowDown)
		WaitForTurn(turret, y_axis)
		-- lower to bed
		--[[Turn(lHand, x_axis, -math.rad(25), ELEVATION_SPEED * slowDown)
		Turn(rHand, x_axis, -math.rad(25), ELEVATION_SPEED * slowDown)
		Turn(rArm[2], x_axis, math.rad(25), ELEVATION_SPEED * slowDown)
		Turn(lArm[2], x_axis, math.rad(25), ELEVATION_SPEED * slowDown)
		WaitForTurn(rArm[2], x_axis)]]
		Turn(rArm[1], x_axis, 0, ELEVATION_SPEED * slowDown)
		Turn(lArm[1], x_axis, 0, ELEVATION_SPEED * slowDown)
		Turn(lHand, x_axis, 0, ELEVATION_SPEED * slowDown)
		Turn(rHand, x_axis, 0, ELEVATION_SPEED * slowDown)
		--WaitForTurn(rHand, x_axis)
		Turn(rArm[2], x_axis, 0, ELEVATION_SPEED * slowDown)
		Turn(lArm[2], x_axis, 0, ELEVATION_SPEED * slowDown)
		WaitForTurn(rArm[2], x_axis)
		--[[for i = 1, 4 do
			Turn(lFinger[i], x_axis, math.rad(35) * (-1)^i, ELEVATION_SPEED)
			Turn(rFinger[i], x_axis, math.rad(35) * (-1)^i, ELEVATION_SPEED)
		end
		WaitForTurn(rFinger[4], x_axis)]]
		GG.FeatureAttach(unitID, piece("bed"), featureID)
		-- allow to drive off with speed based on weight
		GG.SpeedChange(unitID, unitDefID, (12000 - fMass)/10000)
		for i = 3, 4 do
			Move(lArm[i], z_axis, 0, STRETCH_SPEED * slowDown)
			Move(rArm[i], z_axis, 0, STRETCH_SPEED * slowDown)
		end
	end
	
	function UnloadFeature(featureID)
		GG.SpeedChange(unitID, unitDefID, 1)
		StartThread(SetupArms, true)
	end
	
	function RecoverFeature(featureID)
		GG.SpeedChange(unitID, unitDefID, 0.0001)
		StartThread(GrabIt, featureID)
	end
end

function script.Create()
	if wakepoint then
		local fxStages = { {1, "hovercraft", EMPTY}, }
		GG.EmitLupsSfxArray(unitID, fxStages)
		StartThread(Wobble)
	end
	if unitDef.name == "brv" then
		Turn(turret, y_axis, math.pi)
	end
	
	-- set engagement range to weapon 1 range
	Spring.SetUnitMaxRange(unitID, closeRange)
	StartThread(SmokeUnit, {body})
	for limb in pairs(limbHPs) do
		StartThread(SmokeLimb, limb, piece(limb) or body)
	end
	StartThread(CoolOff)
	if vtol then
		for i = 1, info.numRotors.x do
			local dir = i % 2 == 1 and 1 or -1
			Spin(piece("rotorx" .. i), x_axis, 20 * dir * WHEEL_SPEED, WHEEL_ACCEL)
		end
		for i = 1, info.numRotors.y do
			local dir = i % 2 == 1 and 1 or -1
			Spin(piece("rotory" .. i), y_axis, 20 * dir * WHEEL_SPEED, WHEEL_ACCEL)
		end
		for i = 1, info.numRotors.z do
			local dir = i % 2 == 1 and 1 or -1
			Spin(piece("rotorz" .. i), z_axis, 20 * dir * WHEEL_SPEED, WHEEL_ACCEL)
		end
		StartThread(Wobble)
	end
end

local SIG_SOUNDS = 2^15
function VehicleSFX()
	Signal(SIG_SOUNDS)
	SetSignalMask(SIG_SOUNDS)
	while moving do
		PlaySound("vehicle_moving")
		Sleep(2003) -- file is 2s 3ms
	end
end

local THRESHOLD = math.rad(0.5)
local HITCH_MAX_Y = info.hitchMaxY
local GetUnitHeading = Spring.GetUnitHeading
function SteerCheck()
	local currHeading = GetUnitHeading(unitID, true)
	local hitch = piece("hitch")
	local steerL = piece("steerl") -- TODO: generalise this
	local steerR = piece("steerr")
	while moving do
		local newHeading = GetUnitHeading(unitID, true)
		local delta = newHeading - currHeading
		if math.abs(delta) > THRESHOLD then
			--Spring.Echo("Turning!")
			if steerL and steerR then
				Turn(steerL, y_axis, delta * HITCH_MAX_Y/4, WHEEL_SPEED/5)
				Turn(steerR, y_axis, delta * HITCH_MAX_Y/4, WHEEL_SPEED/5)
			else
				for wheelNum in pairs (steerWheels) do
					--Spring.Echo("Turn wheel", wheelNum, "to", math.deg(delta))
					Turn(wheels[wheelNum], y_axis, delta * HITCH_MAX_Y/4, WHEEL_SPEED/5)
				end
			end
			if hitch then
				Turn(hitch, y_axis, -delta * HITCH_MAX_Y, WHEEL_SPEED/10)
			end
		else
			if steerL and steerR then
				Turn(steerL, y_axis, 0, WHEEL_SPEED/2.5)
				Turn(steerR, y_axis, 0, WHEEL_SPEED/2.5)
			else
				for wheelNum in pairs (steerWheels) do
					Turn(wheels[wheelNum], y_axis, 0, WHEEL_SPEED/2.5)
				end			
			end
			if hitch then
				local _, goal, _ = Spring.UnitScript.GetPieceRotation(hitch)
				if goal > math.pi then goal = goal - math.pi end
				Turn(hitch, y_axis, goal * 0.9, WHEEL_SPEED/5)
			end
		end
		currHeading = newHeading
		Sleep(30) -- every game frame
	end
end

function script.StartMoving()
	for i = 1, #wheels do
		Spin(wheels[i], x_axis, WHEEL_SPEED, WHEEL_ACCEL)
	end
	moving = true
	if not vtol and not aero then
		StartThread(VehicleSFX)
		if wheeled or piece("steerl") then -- TODO: this is gross
			StartThread(SteerCheck)
		end
	end
end

function script.StopMoving()
	Signal(SIG_SOUNDS)
	for i = 1, #wheels do
		StopSpin(wheels[i], x_axis, WHEEL_ACCEL * 10)
	end
	moving = false
end

function script.Activate()
	Spring.SetUnitStealth(unitID, false)
	activated = true
end

function script.Deactivate()
	Spring.SetUnitStealth(unitID, true)
	activated = false
end

local function WeaponCanFire(weaponID)
	if playerDisabled[weaponID] or weaponID == numWeapons + 1 then
		return false
	end
	if mainTurretIDs[weaponID] and limbHPs["turret"] <= 0 then
		return false
	end
	if amsIDs[weaponID] then -- check AMS after limbs
		return true
	end
	if jammableIDs[weaponID] and not activated then
		return false
	end
	local ammoType = ammoTypes[weaponID]
	if ammoType and (currAmmo[ammoType] or 0) < (burstLengths[weaponID] or 0) then
		if spinSpeeds[weaponID] then
			StartThread(SpinBarrels, weaponID, false)
		end
		SetUnitRulesParam(unitID, "outofammo", 1)
		return false
	else
		if spinSpeeds[weaponID] then
			local spinState = spinners[weaponID].state
			if spinState < 1 then
				StartThread(SpinBarrels, weaponID, true)
				return false -- can't fire until spun up
			else
				return spinState == 2
			end
		end
		Sleep(info.chainFireDelays[weaponID])
		return true
	end
end
		
function script.AimWeapon(weaponID, heading, pitch)
	Signal(2 ^ weaponID) -- 2 'to the power of' weapon ID
	SetSignalMask(2 ^ weaponID)
	-- use a weapon-specific turret if it exists
	if turretOnTurretIDs[weaponID] then
		WaitForTurn(turret, y_axis)
		local targetType, user, info = Spring.GetUnitWeaponTarget(unitID, weaponID)
		local tx, tz
		if targetType == 1 then -- unit
			tx, _, tz = Spring.GetUnitPosition(info)
		elseif targetType == 2 then
			tx = info[1]
			tz = info[3]
		elseif targetType == 3 then -- a projectile
			tx, _, tz = Spring.GetProjectilePosition(info)
		end
		if not tx then return false end -- somehow can still end up here
		local x, _, z = Spring.GetUnitPiecePosDir(unitID, turrets[weaponID])
		local angle = (math.rad(90) - math.atan(math.abs(tx - x), math.abs(tz - z))) * (turretOnTurretSides[weaponID] * 25)
		--Spring.Echo(weaponID, tx - x, tz - z, math.deg(angle))
		Turn(turrets[weaponID], y_axis, angle, TURRET_2_SPEED * 5)
		WaitForTurn(turrets[weaponID], y_axis)
	elseif turrets[weaponID] then
		Turn(turrets[weaponID], y_axis, heading, TURRET_2_SPEED)
	elseif mainTurretIDs[weaponID] then -- otherwise use main
		Turn(turret, y_axis, heading, TURRET_SPEED)
	elseif amsIDs[weaponID] then 
		Turn(flares[weaponID], y_axis, heading, TURRET_SPEED * 10)
		Turn(flares[weaponID], x_axis, -pitch, ELEVATION_SPEED * 50)
		WaitForTurn(flares[weaponID], y_axis)
		return WeaponCanFire(weaponID)
	end
	if mantlets[weaponID] then
		Turn(mantlets[weaponID], x_axis, -pitch, ELEVATION_SPEED)
	elseif missileWeaponIDs[weaponID] then -- yeah it happens if, in this case, launchpoint_1_# are attached to launcher_1 but launchpoint_2_# and 3 are attached to launcher_1 as well
		if launchers[weaponID] then
			Turn(launchers[weaponID], x_axis, -pitch, ELEVATION_SPEED)
		elseif weaponID > 1 and launchers[1] then
			Turn(launchers[1], x_axis, -pitch, ELEVATION_SPEED)
		else
			for i = 1, burstLengths[weaponID] do
				Turn(launchPoints[weaponID][i], x_axis, -pitch, ELEVATION_SPEED)
			end
		end
	elseif flares[weaponID] then -- TODO: 'else' should be sufficient here
		Turn(flares[weaponID], x_axis, -pitch, ELEVATION_SPEED)
	end
	if piece(weaponProgenitors[weaponID]) then -- ick
		WaitForTurn(piece(weaponProgenitors[weaponID]), y_axis)
	end
	if mantlets[weaponID] then
		WaitForTurn(mantlets[weaponID], x_axis)
	end
	StartThread(RestoreAfterDelay)
	return WeaponCanFire(weaponID)
end

local ROCK_SPEED = math.rad(5000/info.tonnage) -- heavier units should rock less
local RESTORE_SPEED = math.rad(20)

function script.RockUnit(x,z)
	if barrelRecoils[lastFiredWeapon] then
		local base = body -- TODO:
		Turn(base, x_axis,  0.048 * z, ROCK_SPEED)
		Turn(base, z_axis, 0.048 * x, ROCK_SPEED)

		WaitForTurn(base, z_axis)
		WaitForTurn(base, x_axis)

		Turn(base, z_axis, 0, RESTORE_SPEED)
		Turn(base, x_axis, 0, RESTORE_SPEED)
	end
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
	local targetType, user, targetID = Spring.GetUnitWeaponTarget(unitID, weaponID)
	if targetType == 1 then
		if unitDef.transportCapacity > 0 then -- apc
			if not deployed then
				StartThread(UnLoad, targetID)
			end
			--[[if not (Spring.GetUnitRulesParam(unitID, "dronesout") == 1) then
				GG.LaunchDroneAsWeapon(unitID, teamID, targetID, "cl_elemental_prime", 5, body, 0, 90)
			end]]
		else
			local dist = Spring.GetUnitSeparation(unitID, targetID)
			--Spring.Echo("Distance to target is", dist)
			if dist > closeRange then -- we need to get closer
				--Spring.Echo("Mooooooooove closerrrrrr")
				local x,y,z = Spring.GetUnitPosition(targetID)
				Spring.SetUnitMoveGoal(unitID, x, y, z, closeRange)
			end
		end
	end
	ChangeHeat(firingHeats[weaponID])
	if barrels[weaponID] and barrelRecoils[weaponID] then
		Move(barrels[weaponID], z_axis, -barrelRecoils[weaponID], BARREL_SPEED)
		WaitForMove(barrels[weaponID], z_axis)
		Move(barrels[weaponID], z_axis, 0, 10)
	end
	local ammoType = ammoTypes[weaponID]
	if ammoType then
		ChangeAmmo(ammoType, -burstLengths[weaponID])
	end
	if not missileWeaponIDs[weaponID] and not flareOnShots[weaponID] and flares[weaponID] then
		EmitSfx(flares[weaponID], SFX.CEG + weaponID)
	end
	lastFiredWeapon = weaponID
end

function script.Shot(weaponID)
	if missileWeaponIDs[weaponID] then
		EmitSfx(launchPoints[weaponID][currPoints[weaponID]], SFX.CEG + weaponID)
        currPoints[weaponID] = currPoints[weaponID] + 1
        if currPoints[weaponID] > burstLengths[weaponID] then 
			currPoints[weaponID] = 1
        end
	elseif flareOnShots[weaponID] then
		if not flares[weaponID] then Spring.Echo(unitDef.name, "sonofabitch") end
		EmitSfx(flares[weaponID], SFX.CEG + weaponID)
	end
	if spinSpeeds[weaponID] then
		ChangeHeat(firingHeats[weaponID])
	end
end

function script.EndBurst(weaponID)
	if spinSpeeds[weaponID] then
		StartThread(SpinBarrels, weaponID, false)
	end
end

function script.AimFromWeapon(weaponID) 
	return turret or body
end

function script.QueryWeapon(weaponID) 
	if missileWeaponIDs[weaponID] then
		return launchPoints[weaponID][currPoints[weaponID]]
	elseif weaponID == numWeapons + 1 then -- Sight
		return 1 --cockpit
	else
		return flares[weaponID] or turret or piece("bomb")
	end
end

if unitDef.customParams.support then -- TODO: mech/outpost style includes?
	
	local ammoLeft = 6
	
	-- Shared support anims
	local crateID
	function EnCrate()
		local crateLink = piece("cratelink") or 1
		local x,y,z = Spring.GetUnitBasePosition(unitID)
		crateID = Spring.CreateUnit(cp.cratetype or "crate", x,y,z, 0, teamID, false, false)
		Spring.UnitAttach(unitID, crateID, crateLink, true)
	end
	
	function Unloaded(ry, callerID)
		GG.Delay.DelayCall(Spring.MoveCtrl.Enable, {unitID}, 5) -- don't allow moving until crate is unfolded
		GG.Delay.DelayCall(Spring.MoveCtrl.Disable, {unitID}, 5 * 30)
		GG.AssociateSupport(callerID, teamID, unitID)
		if crateID then
			env = Spring.UnitScript.GetScriptEnv(crateID)
			Spring.UnitScript.CallAsUnit(crateID, env.Unloaded)
			Spring.UnitDetach(crateID)
		end
		if unitDef.name == "brv" then
			StartThread(SetupArms, true, 5000)
		end
	end
	
	
	-- Savior & J-27

	local passengerDefID
	local passengerInfo
	local passengerEnv
	
	local function DeployAnim()
		if unitDef.name == "savior" then
			local bed, bedL, bedR = piece("bed", "bedl", "bedr")
			local flapL1, flapL2, flapR1, flapR2 = piece("flapl1", "flapl2", "flapr1", "flapr2")
			Turn(bed, x_axis, math.rad(-90), ELEVATION_SPEED/2)
			WaitForTurn(bed, x_axis)
			Turn(bedL, z_axis, math.rad(-60), ELEVATION_SPEED/2)
			Turn(bedR, z_axis, math.rad(60), ELEVATION_SPEED/2)
			WaitForTurn(bedR, z_axis)
			Turn(flapL1, z_axis, math.rad(179), ELEVATION_SPEED)
			Turn(flapL2, z_axis, math.rad(179), ELEVATION_SPEED)
			Turn(flapR1, z_axis, math.rad(-179), ELEVATION_SPEED)
			Turn(flapR2, z_axis, math.rad(-179), ELEVATION_SPEED)
			WaitForTurn(flapR2, z_axis)
			Turn(flapL1, z_axis, math.rad(230), ELEVATION_SPEED)
			Turn(flapL2, z_axis, math.rad(230), ELEVATION_SPEED)
			Turn(flapR1, z_axis, math.rad(-230), ELEVATION_SPEED)
			Turn(flapR2, z_axis, math.rad(-230), ELEVATION_SPEED)
			WaitForTurn(flapR2, z_axis)
		end
	end
	
	function Deploy()
		GG.SpeedChange(unitID, unitDefID, 0)
		Spring.MoveCtrl.Enable(unitID)
		StartThread(DeployAnim)
	end
	
	local CMD_DEPOSIT = GG.CustomCommands.GetCmdID("CMD_DEPOSIT")
	local function UnDeployAnim()
		if unitDef.name == "savior" then
			local bed, bedL, bedR = piece("bed", "bedl", "bedr")
			local flapL1, flapL2, flapR1, flapR2 = piece("flapl1", "flapl2", "flapr1", "flapr2")
			Turn(flapL1, z_axis, math.rad(179), ELEVATION_SPEED)
			Turn(flapL2, z_axis, math.rad(179), ELEVATION_SPEED)
			Turn(flapR1, z_axis, math.rad(-179), ELEVATION_SPEED)
			Turn(flapR2, z_axis, math.rad(-179), ELEVATION_SPEED)
			WaitForTurn(flapR2, z_axis)
			Turn(flapL1, z_axis, math.rad(0), ELEVATION_SPEED)
			Turn(flapL2, z_axis, math.rad(0), ELEVATION_SPEED)
			Turn(flapR1, z_axis, math.rad(0), ELEVATION_SPEED)
			Turn(flapR2, z_axis, math.rad(0), ELEVATION_SPEED)
			WaitForTurn(flapR2, z_axis)
			Turn(bedL, z_axis, math.rad(0), ELEVATION_SPEED/2)
			Turn(bedR, z_axis, math.rad(0), ELEVATION_SPEED/2)
			WaitForTurn(bedR, z_axis)
			Turn(bed, x_axis, math.rad(0), ELEVATION_SPEED/2)
			WaitForTurn(bed, x_axis)
		elseif unitDef.name == "j27" then
			Hide(piece("ammo" .. ammoLeft)) -- TODO: cache in a table
			ammoLeft = ammoLeft - 1
			--Spring.Echo("I've got", ammoLeft, "left, base is", GG.GetSupportBase(unitID))
			GG.supportStatus = 0
			if ammoLeft == 0 then
				GG.supportStatus = 2
				-- TODO: go home and pick up some more
				--Spring.Echo("Awwww gees, I'm all out, best RTB!", GG.GetSupportBase(unitID))
				--Spring.Echo("UnDeployAnim giving CMD_DEPOSIT")
				Spring.GiveOrderToUnit(unitID, CMD_DEPOSIT, {GG.GetSupportBase(unitID)}, {})
			end
		end
		Spring.MoveCtrl.Disable(unitID)
		GG.SpeedChange(unitID, unitDefID, 1)
	end
	
	local REPAIR_RATE = 0.05
	function Repair(passengerID)
		SetSignalMask(1024)
		--StartThread(MechBayRepair)
		local curHP, maxHP = Spring.GetUnitHealth(passengerID)
		while curHP ~= maxHP do
			local newHP = math.min(curHP + maxHP * REPAIR_RATE, maxHP)
			Spring.SetUnitHealth(passengerID, newHP)
			--curHP, maxHP = GetUnitHealth(passengerID)
			curHP, maxHP = Spring.GetUnitHealth(passengerID)
			Sleep(1000)
		end
		Sleep(5000) -- always wait 5 seconds before shoving the mech out
		script.TransportDrop(passengerID)
	end
	
	local function RefillAmmoAnim()
		while ammoLeft < 6 do
			Sleep(1000)
			ammoLeft = ammoLeft + 1
			Show(piece("ammo" .. ammoLeft)) -- TODO: cache in a table
		end
		GG.supportStatus = 0 -- ready to go out and resupply again
	end
	
	function RefillAmmoCrates()
		StartThread(RefillAmmoAnim)
	end
	
	local suppliedAmmos = {}
	
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
		SetSignalMask(1024)
		local ammoTypes = passengerInfo.ammoTypes
		if passengerEnv.ChangeAmmo then
			for weaponNum, ammoType in pairs(ammoTypes) do
				StartThread(ResupplyAmmoType, passengerID, weaponNum, ammoType)
			end
		end
		local resupplied = false
		while not resupplied do
			local allDone = true
			for ammoType, done in pairs(suppliedAmmos) do
				allDone = allDone and done
			end
			resupplied = allDone
			Sleep(1000)
		end
		Sleep(1000) -- always wait 1 second before shoving the mech out
		--Spring.Echo("Resupply is all done!")
		script.TransportDrop(passengerID)
	end

	function script.TransportPickup (passengerID)
		script.StopMoving()
		-- stop movement again here in case of CMD_LOAD_ONTO being used
		GG.SpeedChange(unitID, unitDefID, 0)
		Spring.MoveCtrl.Enable(unitID)
		passengerDefID = Spring.GetUnitDefID(passengerID)
		passengerInfo = GG.lusHelper[passengerDefID]
		passengerEnv = Spring.UnitScript.GetScriptEnv(passengerID)
		--Spring.Echo("script.TransportPickup", passengerID, passengerDefID, passengerInfo, passengerEnv)
		if passengerEnv then
			Spring.UnitScript.CallAsUnit(passengerID, passengerEnv.script.StopMoving)
		end
		-- TODO: pickup animation
		Spring.UnitScript.AttachUnit(piece("mechlink"), passengerID)
		if unitDef.name == "savior" then
			StartThread(Repair, passengerID)
		elseif unitDef.name == "j27" then
			StartThread(Resupply, passengerID)
		end
	end


	function script.TransportDrop (passengerID, x, y, z)
		local isTransporting = Spring.GetUnitIsTransporting(unitID)
		if isTransporting and #isTransporting > 0 then
			Signal(1024) -- kill repair anim & threads
			passengerID = passengerID or isTransporting[1]
			if passengerID and Spring.ValidUnitID(passengerID) and not Spring.GetUnitIsDead(passengerID) then
				Spring.UnitScript.DropUnit(passengerID)
				--Spring.SetUnitMoveGoal(passengerID, UNLOAD_X, 0, UNLOAD_Z, 50) -- bug out over here
			end
			StartThread(UnDeployAnim)
		end
	end

	-- Salvager
	local CRANE_Y = math.rad(30)
	Spring.SetUnitNanoPieces(unitID, {piece("crane_wrist2")})
	if unitDef.isBuilder then
	function script.StartBuilding(heading, pitch)
		--Spring.Echo("StartBuilding!")
		-- TODO: unfold anim and waits
		Turn(piece("crane_turret"), y_axis, heading, CRANE_Y * 3)
		Turn(piece("crane_base"), x_axis, math.rad(80), CRANE_Y)
		Turn(piece("crane_arm1"), x_axis, math.rad(-95), CRANE_Y * 3)
		WaitForTurn(piece("crane_turret"), y_axis)
		WaitForTurn(piece("crane_arm1"), x_axis)
		--WaitForTurn(piece("crane_sleeve"), x_axis)
		Turn(piece("crane_sleeve"), x_axis, math.rad(130), CRANE_Y * 3)
		WaitForTurn(piece("crane_sleeve"), x_axis)
		Turn(piece("crane_sleeve"), x_axis, math.rad(240), CRANE_Y * 6)
		WaitForTurn(piece("crane_sleeve"), x_axis)
		Move(piece("crane_arm2"), z_axis, -10, CRANE_Y * 30)
		Turn(piece("crane_wrist2"), z_axis, math.rad(90), CRANE_Y * 3)
		Turn(piece("crane_claw1"), x_axis, math.rad(45), CRANE_Y)
		Turn(piece("crane_claw2"), x_axis, math.rad(-45), CRANE_Y)
		WaitForTurn(piece("crane_wrist2"), z_axis)
		SetUnitValue(COB.INBUILDSTANCE, 1)
	end
	
	function script.StopBuilding()
		--Spring.Echo("StopBuilding!")
		SetUnitValue(COB.INBUILDSTANCE, 0)
		-- TODO: fold up anim
		Turn(piece("crane_claw2"), x_axis, 0, CRANE_Y)
		Turn(piece("crane_claw1"), x_axis, 0, CRANE_Y)
		Turn(piece("crane_wrist2"), z_axis, 0, CRANE_Y * 3)
		Move(piece("crane_arm2"), z_axis, 0, CRANE_Y * 30)
		WaitForTurn(piece("crane_wrist2"), z_axis)
		Turn(piece("crane_sleeve"), x_axis, math.rad(130), CRANE_Y * 3)
		WaitForTurn(piece("crane_sleeve"), x_axis)
		Turn(piece("crane_sleeve"), x_axis, 0, CRANE_Y * 3)
		WaitForTurn(piece("crane_sleeve"), x_axis)
		Turn(piece("crane_turret"), y_axis, 0, CRANE_Y * 3)
		Turn(piece("crane_base"), x_axis, 0, CRANE_Y)
		Turn(piece("crane_arm1"), x_axis, 0, CRANE_Y * 3)
		WaitForTurn(piece("crane_turret"), y_axis)
		WaitForTurn(piece("crane_arm1"), x_axis)
	end
	
	function GenSalvage(amount)
		for i = 1, amount do
			Explode(piece("crane_base"), SFX.FIRE + SFX.SMOKE)
		end
	end
	end
end


function script.Killed(recentDamage, maxHealth)
	if excessHeat >= heatLimit then
		--Spring.Echo("NUUUUUUUUUUUKKKKKE")
	end
	if turret and limbHPs["turret"] > 0 then -- still have a turret, blow it off to leave a beautiful corpse
		limbHPControl("turret", maxHealth * 100)
	end
	--local severity = recentDamage / maxHealth * 100
	--if severity <= 25 then
	--	Explode(body, math.bit_or({SFX.BITMAPONLY, SFX.BITMAP1}))
	--	return 1
	--elseif severity <= 50 then
	--	Explode(body, math.bit_or({SFX.FALL, SFX.BITMAP1}))
	--	return 2
	--else
	--	Explode(body, math.bit_or({SFX.FALL, SFX.SMOKE, SFX.FIRE, SFX.EXPLODE_ON_HIT, SFX.BITMAP1}))
	--	return 3
	--end
	if unitDef.isBuilder then
		local attackerID = Spring.GetUnitLastAttacker(unitID)
		local numSalvage = math.floor(Spring.GetUnitHarvestStorage(unitID) / 100) * GG.PinataLevel(attackerID) + 1 -- always produce at least 1
		GenSalvage(numSalvage)
	end
	
	return 1
end
