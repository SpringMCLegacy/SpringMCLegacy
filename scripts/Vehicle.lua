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
heatLimit = info.heatLimit
baseCoolRate = info.coolRate
local coolRate = baseCoolRate
local inWater = false
local activated = true

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

local flares = {}
local turrets = {}
local mantlets = {}
local barrels = {}
local launchers = {}
local launchPoints = {}
local currPoints = {}
local spinPieces = {}
local spinPiecesState = {}

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
		spinPieces[weaponID] = piece("barrels_" .. weaponID)
		spinPiecesState[weaponID] = false
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
	Signal(spinSpeeds)
	SetSignalMask(spinSpeeds)
	if start  then
		Spin(spinPieces[weaponID], z_axis, spinSpeeds[weaponID], spinSpeeds[weaponID] / 5)
	else
		Sleep(2500)
		StopSpin(spinPieces[weaponID], z_axis, spinSpeeds[weaponID]/10)
	end
	spinPiecesState[weaponID] = start -- must come after the Sleep
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
		if water then
			GG.EmitSfxName(unitID, wakepoint, "hover_water")
			EmitSfx(SFX.WAKE, wakepoint)
		else
			GG.EmitSfxName(unitID, wakepoint, "hover_dust")
		end
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
	local mult = 1
	if module == "body" then 
		return damage
	elseif wheeled and hitPiece:find("wheel") then
		mult = 0.1 -- apply only 10% damage
	elseif hitPiece:find("track") then
		mult = 0.1 -- apply only 10% damage
	else -- turret, wing or rotor
		mult = 0.5 -- still apply 50% of the damage to main unit too
	end
	limbHPControl(module, damage)
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
	local ROCK_SPEED = math.rad(1.0)
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

function script.Create()
	if hover then
		local fxStages = { {1, "hovercraft", EMPTY}, }
		GG.EmitLupsSfxArray(unitID, fxStages)
		StartThread(Wobble)
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

function script.StartMoving()
	for i = 1, #wheels do
		Spin(wheels[i], x_axis, WHEEL_SPEED, WHEEL_ACCEL)
	end
	moving = true
end

function script.StopMoving()
	for i = 1, #wheels do
		StopSpin(wheels[i], x_axis, WHEEL_ACCEL)
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
	if playerDisabled[weaponID] then
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
		if spinSpeeds[weaponID] and not spinPiecesState[weaponID] then
			StartThread(SpinBarrels, weaponID, true)
		end
		Sleep(info.chainFireDelays[weaponID])
		return true
	end
end
		
function script.AimWeapon(weaponID, heading, pitch)
	Signal(2 ^ weaponID) -- 2 'to the power of' weapon ID
	SetSignalMask(2 ^ weaponID)
	if amsIDs[weaponID] then 
		Turn(flares[weaponID], y_axis, heading, TURRET_SPEED * 10)
		Turn(flares[weaponID], x_axis, -pitch, ELEVATION_SPEED * 50)
		WaitForTurn(flares[weaponID], y_axis)
		return WeaponCanFire(weaponID)
	end
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
		end
		local x, _, z = Spring.GetUnitPiecePosDir(unitID, turrets[weaponID])
		local angle = (math.rad(90) - math.atan(math.abs(tx - x), math.abs(tz - z))) * (turretOnTurretSides[weaponID] * 25)
		--Spring.Echo(weaponID, tx - x, tz - z, math.deg(angle))
		Turn(turrets[weaponID], y_axis, angle, TURRET_2_SPEED * 5)
		WaitForTurn(turrets[weaponID], y_axis)
	elseif turrets[weaponID] then
		Turn(turrets[weaponID], y_axis, heading, TURRET_2_SPEED)
	elseif mainTurretIDs[weaponID] then -- otherwise use main
		Turn(turret, y_axis, heading, TURRET_SPEED)
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
	else
		return flares[weaponID] or turret or piece("bomb")
	end
end

if unitDef.isBuilder then -- BRVS
	Spring.SetUnitNanoPieces(unitID, {piece("cranewrist3")})

	local CRANE_Y = math.rad(30)
	
	function script.StartBuilding(heading, pitch)
		--Spring.Echo("StartBuilding!")
		-- TODO: unfold anim and waits
		Turn(piece("craneturret"), y_axis, heading - math.rad(90), CRANE_Y)
		Turn(piece("cranemid"), z_axis, math.rad(180), CRANE_Y)
		Turn(piece("cranearm"), z_axis, math.rad(180), CRANE_Y)
		WaitForTurn(piece("craneturret"), y_axis)
		WaitForTurn(piece("cranemid"), z_axis)
		WaitForTurn(piece("cranearm"), z_axis)
		SetUnitValue(COB.INBUILDSTANCE, 1)
	end
	
	function script.StopBuilding()
		SetUnitValue(COB.INBUILDSTANCE, 0)
		-- TODO: fold up anim
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
	return 1
end
