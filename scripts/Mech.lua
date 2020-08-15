-- Test Mech Script
-- useful global stuff
info = GG.lusHelper[unitDefID]
-- the following have to be non-local for the walkscript include to find them
rad = math.rad

SIG_ANIMATE = {}
moving = false
jumping = false
speedMod = (GG.modOptions and GG.modOptions.speed) or 1.0

-- localised API functions
local SetUnitRulesParam 		= Spring.SetUnitRulesParam
local GetUnitSeparation 		= Spring.GetUnitSeparation
local GetUnitCommands   		= Spring.GetUnitCommands
local GetUnitLastAttackedPiece 	= Spring.GetUnitLastAttackedPiece
local GetUnitPosition 			= Spring.GetUnitPosition
local SpawnCEG 					= Spring.SpawnCEG
-- localised GG functions
local GetUnitDistanceToPoint = GG.GetUnitDistanceToPoint
local GetUnitUnderJammer = GG.GetUnitUnderJammer
local IsUnitNARCed = GG.IsUnitNARCed
local IsUnitTAGed = GG.IsUnitTAGed

-- includes
include "smokeunit.lua"
include ("anims/" .. unitDef.name:sub(4, (unitDef.name:find("_", 4) or 0) - 1) .. ".lua")

-- Info from lusHelper gadget
-- non-local so perks can change them (flagrant lack of encapsulation!)
heatLimit = info.heatLimit
baseCoolRate = info.coolRate
mascHeatRate = 0.1
firingHeats = info.firingHeats
numWeapons = info.numWeapons - 1 -- remove sight
TORSO_SPEED = info.torsoTurnSpeed -- AES mod
ELEVATION_SPEED = info.elevationSpeed -- AES mod

local coolRate = baseCoolRate
local inWater = false
local activated = true
local mascActive = false

local missileWeaponIDs = info.missileWeaponIDs
local flareOnShots = info.flareOnShots
local jammableIDs = info.jammableIDs
local launcherIDs = info.launcherIDs
local barrelRecoils = info.barrelRecoilDist
local burstLengths = info.burstLengths
local ammoTypes = info.ammoTypes
local minRanges = info.minRanges
local spinSpeeds = info.spinSpeeds
local maxAmmo = info.maxAmmo
local currAmmo = {} -- copy maxAmmo table into currAmmo
for k,v in pairs(maxAmmo) do 
	currAmmo[k] = v 
	SetUnitRulesParam(unitID, "ammo_" .. k, 100)
end
local leftArmIDs = info.leftArmIDs
local rightArmIDs = info.rightArmIDs
local leftArmMasterID = info.leftArmMasterID
local rightArmMasterID = info.rightArmMasterID
local amsIDs = info.amsIDs
local limbHPs = {}
for limb,limbHP in pairs(info.limbHPs) do -- copy table from defaults
	limbHPs[limb] = limbHP
	SetUnitRulesParam(unitID, "limb_hp_" .. limb, 100)
end

--Turning/Movement Locals
local BARREL_SPEED = info.barrelRecoilSpeed
local RESTORE_DELAY = Spring.UnitScript.GetLongestReloadTime(unitID) * 2
local CMD_JUMP = GG.CustomCommands.GetCmdID("CMD_JUMP")

local currLaunchPoint = 1
local currHeatLevel = 0
local excessHeat = 0
SetUnitRulesParam(unitID, "heat", 0)
SetUnitRulesParam(unitID, "excess_heat", 0)
local jumpHeat = 2
local SlowDownRate = 2

--piece defines
local pelvis, torso, cockpit, rlowerleg, llowerleg = piece ("pelvis", "torso", "cockpit", "rlowerleg", "llowerleg")

rupperarm = piece("rupperarm")
lupperarm = piece("lupperarm")

local jets = {}
if info.jumpjets then
	for i = 1, info.jumpjets do
		jets[i] = piece("jet" .. i)
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
for weaponID = 1, info.numWeapons - 1 do
	if missileWeaponIDs[weaponID] then
		if launcherIDs[weaponID] then
			launchers[weaponID] = piece("launcher_" .. weaponID)
		end
		launchPoints[weaponID] = {}
		currPoints[weaponID] = 1
		for i = 1, burstLengths[weaponID] do
			launchPoints[weaponID][i] = piece("launchpoint_" .. weaponID .. "_" .. i)
		end	
	else
		flares[weaponID] = piece("flare_" .. weaponID)
		if info.mantletIDs[weaponID] then
			mantlets[weaponID] = piece("mantlet_" .. weaponID)
		end
		if info.turretIDs[weaponID] then
			turrets[weaponID] = piece("turret_" .. weaponID)
		end
		if spinSpeeds[weaponID] then
			spinPieces[weaponID] = piece("barrels_" .. weaponID)
			spinPiecesState[weaponID] = 0
		elseif info.barrelIDs[weaponID] then
			barrels[weaponID] = piece("barrel_" .. weaponID)
		end
	end
	playerDisabled[weaponID] = false
	SetUnitRulesParam(unitID, "weapon_" .. weaponID, "active")
end

local function RestoreAfterDelay(unitID)
	Sleep(RESTORE_DELAY)
	Turn(torso, y_axis, 0, TORSO_SPEED)
	for id in pairs(mantlets) do
		Turn(mantlets[id], x_axis, 0, ELEVATION_SPEED)
	end
	if lupperarm then
		Turn(lupperarm, x_axis, 0, ELEVATION_SPEED)
	end
	if rupperarm then
		Turn(rupperarm, x_axis, 0, ELEVATION_SPEED)
	end
end

-- non-local function called by gadgets/game_ammo.lua
function ChangeAmmo(ammoType, amount) 
	local newAmmoLevel = (currAmmo[ammoType] or 0) + (amount or 0) -- amount is a -ve to deduct
	if not amount then -- whut?
		Spring.Echo("ChangeAmmo amount was nil", ammoType, unitDef.name)
		amount = 0
	end
	if amount > 0 then -- restocking, reset the indicator
		SetUnitRulesParam(unitID, "outofammo", 0)
	end
	if newAmmoLevel <= maxAmmo[ammoType] then -- TODO: somehow one of these can be wrong type / nil?
		currAmmo[ammoType] = newAmmoLevel
		SetUnitRulesParam(unitID, "ammo_" .. ammoType, 100 * newAmmoLevel / maxAmmo[ammoType])
		return true -- Ammo was changed
	end
	return false -- Ammo was not changed
end

local function SpinBarrels(weaponID, start)
	Signal(spinSpeeds)
	SetSignalMask(spinSpeeds)
	if start then
		spinPiecesState[weaponID] = 1
		for weaponID, spinPiece in pairs(spinPieces) do
			Spin(spinPiece, z_axis, spinSpeeds[weaponID], spinSpeeds[weaponID] / 5)
		end
		Sleep(2500) -- spin up wait
		spinPiecesState[weaponID] = 2
	else
		Sleep(2500) -- spin down wait
		for weaponID, spinPiece in pairs(spinPieces) do
			StopSpin(spinPiece, z_axis, spinSpeeds[weaponID]/10)
		end
		spinPiecesState[weaponID] = 0
	end
end

function ChangeHeat(amount)
	currHeatLevel = currHeatLevel + amount
	if currHeatLevel > heatLimit then
		excessHeat = excessHeat + currHeatLevel - heatLimit
		currHeatLevel = heatLimit
		if excessHeat >= heatLimit * 2 then
			Spring.DestroyUnit(unitID, true)
		end
	elseif currHeatLevel < 0 then
		currHeatLevel = 0
	end
	SetUnitRulesParam(unitID, "heat", math.ceil(100 * currHeatLevel / heatLimit))
	SetUnitRulesParam(unitID, "excess_heat", math.ceil(100 * excessHeat / (2 * heatLimit)))
end

local function MASCHeat()
	while moving and mascActive do
		ChangeHeat(mascHeatRate)
		if excessHeat > 0 then
			--Spring.Echo("Overheating! Terminate MASC!")
			-- SIG_ANIMATE is just an empty table, don't create a new one just for empty command options
			Spring.GiveOrderToUnit(unitID, GG.CustomCommands.GetCmdID("CMD_MASC"), {0}, SIG_ANIMATE) 
			return
		end
		Sleep(100)
	end
end

function SpeedChangeCheck()
	while jumping do -- don't trigger speed change until jump is finished
		Sleep(500)
	end
	GG.SpeedChange(unitID, unitDefID, speedMod)
end

function MASC(activated)
	if activated then
		speedMod = speedMod * 1.3
		mascActive = true
		StartThread(SpeedChangeCheck)
		StartThread(MASCHeat)
	else
		speedMod = speedMod / 1.3
		mascActive = false
		StartThread(SpeedChangeCheck)
		StartThread(MASCHeat)
	end
end

function FlushCoolant()
	if currAmmo.coolant > 0 then
		GG.EmitSfxName(unitID, torso, "greengoo")
		ChangeHeat(-10)
		ChangeAmmo("coolant", -20)
		return true
	else
		return false
	end
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
				if GG.autoCoolantUnits[unitID] then
					FlushCoolant()
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
		--[[if hasEcm and not moving then
			AddUnitSeismicPing(unitID, 20)
		end]]
		Sleep(1000) -- cools once per second
	end
end

function script.setSFXoccupy(terrainType)
	if terrainType == 2 or terrainType == 1 then -- water
		inWater = true
	else
		inWater = false
		coolRate = baseCoolRate
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

function SmokeLimb(limb, hitPiece)
	local maxHealth = info.limbHPs[limb] / 100
	while true do
		local health = limbHPs[limb]/maxHealth
		if (health <= 66) then -- only smoke if less then 2/3rd limb maxhealth left
			EmitSfx(piece(hitPiece), SFX.CEG + numWeapons + 2)
			EmitSfx(piece(hitPiece), SFX.CEG + numWeapons + 3)
		end
		Sleep(20*health + 150)
	end
end

local lostLegs = 0
function hideLimbPieces(limb, hide)
	local rootPiece
	local limbWeapons
	if limb == "left_arm" then
		rootPiece = lupperarm
		limbWeapons = leftArmIDs
	elseif limb == "right_arm" then
		rootPiece = rupperarm
		limbWeapons = rightArmIDs
	end
	if rootPiece then
		RecursiveHide(rootPiece, hide)
	else -- legs
		if hide then
			local side = limb == "left_leg" and llowerleg or rlowerleg
			Explode(side, SFX.FIRE + SFX.SHATTER + SFX.RECURSIVE)
			lostLegs = lostLegs + 1
			--Spring.Echo("Lost a leg! halving move speed")
			speedMod = speedMod / 2
			-- disable jumpjets
			if info.jumpjets > 0 then
				Spring.EditUnitCmdDesc(unitID, Spring.FindUnitCmdDesc(unitID, CMD_JUMP), {disabled = true})
			end
		else -- leg is restored
			lostLegs = lostLegs - 1
			--Spring.Echo("Regained a leg! doubling move speed")
			speedMod = speedMod * 2
			if lostLegs == 0 and info.jumpjets > 0 then -- enable jumpjets
				Spring.EditUnitCmdDesc(unitID, Spring.FindUnitCmdDesc(unitID, CMD_JUMP), {disabled = false})
			end
		end
		SetUnitRulesParam(unitID, "lostlegs", lostLegs)
		StartThread(SpeedChangeCheck)
		return
	end
	if hide then
		EmitSfx(rootPiece, SFX.CEG + numWeapons + 1)
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

local limbsLost = 0
function limbHPControl(limb, damage, piece)
	local currHP = limbHPs[limb]
	if currHP > 0 or (damage or 0) < 0 then
		local newHP = math.min(limbHPs[limb] - damage, info.limbHPs[limb]) -- don't allow HP above max
		--Spring.Echo(unitDef.name, limb, "newHP", newHP, "currHP", currHP)
		if newHP < 0 then 
			hideLimbPieces(limb, true)
			newHP = 0
			limbsLost = limbsLost + 1
			SetUnitRulesParam(unitID, "limblost", limbsLost)
		elseif currHP == 0 then -- can only get here if damage < 0 i.e. repairing
			hideLimbPieces(limb, false)
			limbsLost = limbsLost - 1
			SetUnitRulesParam(unitID, "limblost", limbsLost)
		else
			if (newHP/info.limbHPs[limb] * 100) <= 66 and (currHP/info.limbHPs[limb] * 100) > 66 and piece then
				StartThread(SmokeLimb, limb, piece)
			end
		end
		limbHPs[limb] = newHP
		SetUnitRulesParam(unitID, "limb_hp_" .. limb, newHP/info.limbHPs[limb]*100)
	end
	return currHP
end
GG.limbHPControl = limbHPControl

function SetLimbMaxHP(mult)
	for limb,limbHP in pairs(info.limbHPs) do -- copy table from defaults
		info.limbHPs[limb] = limbHP * mult
		limbHPs[limb] = limbHP * mult -- set to new max
		SetUnitRulesParam(unitID, "limb_hp_" .. limb, 100)
		-- run through LimbHPControl to ensure visibility etc
		limbHPControl(limb, -1)
	end
end

function script.HitByWeapon(x, z, weaponID, damage, piece)
	local wd = WeaponDefs[weaponID]
	--local heatDamage = wd and wd.customParams.heatdamage or 0
	--ChangeHeat(heatDamage)
	local hitPiece = piece or GetUnitLastAttackedPiece(unitID) or ""
	if hitPiece == "torso" or hitPiece == "pelvis" or hitPiece == "" then 
		return damage
	elseif hitPiece == "lupperleg" or hitPiece == "llowerleg" then
		--deduct Left Leg HP
		local hp = limbHPControl("left_leg", damage, hitPiece)
		if hp == 0 then return damage end
	elseif hitPiece == "rupperleg" or hitPiece == "rlowerleg" then
		--deduct Right Leg HP
		local hp = limbHPControl("right_leg", damage, hitPiece)
		if hp == 0 then return damage end
	elseif hitPiece == "lupperarm" or hitPiece == "llowerarm" then
		--deduct Left Arm HP
		limbHPControl("left_arm", damage, hitPiece)
	elseif hitPiece == "rupperarm" or hitPiece == "rlowerarm" then
		--deduct Right Arm HP
		limbHPControl("right_arm", damage, hitPiece)
	end
	--Spring.Echo(weaponID, wd.name, wd.customParams.heatdamage)
	--Spring.Echo("HIT PIECE?", hitPiece, damage, heatDamage)
	return 0
end

function PreJump(delay, turn, lineDist)
	StartThread(anim_PreJump)
end

function StartJump()
	jumping = true
	currHeatLevel = currHeatLevel + jumpHeat
	StartThread(anim_StartJump)
	local x,y,z = GetUnitPosition(unitID)
	SpawnCEG("mech_jump_dust", x,y,z)
end

function Jumping()-- Gets called throughout by gadget
	if not GG.unitMechanicalJumps[unitID] then
		for i = 1, info.jumpjets do -- emit JumpJetTrail
			EmitSfx(jets[i], SFX.CEG)
		end
	end
end

function HalfJump()
	StartThread(anim_HalfJump)
end

function StopJump()
	jumping = false
	local x,y,z = GetUnitPosition(unitID)
	SpawnCEG("mech_jump_dust", x,y,z)
	Spring.SpawnExplosion(x,y,z, 0,0,0, {weaponDef = WeaponDefNames["dfa"].id, owner = unitID,  damageAreaOfEffect = unitDef.customParams.tonnage, explosionSpeed = 100})
	StartThread(anim_StopJump)
end

function StartTurn(clockwise)
	StartThread(anim_Turn, clockwise)
end

function StopTurn()
	StartThread(anim_Reset)
end

function script.StartMoving(reversing)
	--Spring.Echo("Reversing?", reversing)
	StartThread(anim_Walk)
	moving = true
	if mascActive then
		StartThread(DrainMASC)
	end
end

function script.StopMoving()
	StartThread(anim_Reset)
	moving = false
end

function script.Create()
	local x,y,z = Spring.GetUnitPiecePosition(unitID, torso)
	Spring.SetUnitMidAndAimPos(unitID, x,y,z, x,y,z, true)
	if info.builderID then script.StartMoving() end -- walk down ramp
	--StartThread(SmokeUnit, {pelvis, torso})
	--[[StartThread(SmokeLimb, "left_arm", lupperarm)
	StartThread(SmokeLimb, "right_arm", rupperarm)
	StartThread(SmokeLimb, "left_leg", llowerleg)
	StartThread(SmokeLimb, "right_leg", rlowerleg)]]
	StartThread(CoolOff)
end

function script.Activate()
	Spring.SetUnitStealth(unitID, false)
	activated = true
end

function script.Deactivate()
	Spring.SetUnitStealth(unitID, true)
	activated = false
end

function WeaponCanFire(weaponID)
	if playerDisabled[weaponID] or weaponID == numWeapons + 1 then
		return false
	end
	if leftArmIDs[weaponID] and limbHPs["left_arm"] <= 0 then
		return false
	elseif rightArmIDs[weaponID] and limbHPs["right_arm"] <= 0 then
		return false
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
	elseif spinSpeeds[weaponID] then 
		if spinPiecesState[weaponID] < 1 then
			StartThread(SpinBarrels, weaponID, true)
			return false -- can't fire until spun up
		else
			return spinPiecesState[weaponID] == 2
		end
	else
		--Spring.Echo(unitID, weaponID, "Weapon is allowed to fire by WeaponCanFire")
		return true
	end
end
GG.WeaponCanFire = WeaponCanFire

function script.AimWeapon(weaponID, heading, pitch)
	Signal(2 ^ weaponID) -- 2 'to the power of' weapon ID
	SetSignalMask(2 ^ weaponID)

	if weaponID == leftArmMasterID or weaponID == rightArmMasterID then
		if weaponID == leftArmMasterID then
			Turn(lupperarm, x_axis, -pitch, ELEVATION_SPEED)
		elseif weaponID == rightArmMasterID then
			Turn(rupperarm, x_axis, -pitch, ELEVATION_SPEED)
		end
	elseif missileWeaponIDs[weaponID] then
		if launchers[weaponID] then
			Turn(launchers[weaponID], x_axis, -pitch, ELEVATION_SPEED)
		else
			for i = 1, burstLengths[weaponID] do
				Turn(launchPoints[weaponID][i] or launchPoints[weaponID][1], x_axis, -pitch, ELEVATION_SPEED)
			end
		end
	elseif flares[weaponID] then
		if amsIDs[weaponID] then 
			Turn(turrets[weaponID], y_axis, heading, TORSO_SPEED * 10)
			WaitForTurn(turrets[weaponID], y_axis)
			Turn(flares[weaponID], x_axis, -pitch, ELEVATION_SPEED * 10)
			return true 
		elseif mantlets[weaponID] then
			Turn(mantlets[weaponID], x_axis, -pitch, ELEVATION_SPEED)
		else
			Turn(flares[weaponID], x_axis, -pitch, ELEVATION_SPEED)
		end
	end

	Turn(torso, y_axis, heading, TORSO_SPEED)
	WaitForTurn(torso, y_axis)
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
		if distance < minRange then 
			--Spring.Echo("Can't fire weapon " .. weaponID .. " as target is within minimum range")
			return true 
		end
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
	--Spring.Echo(unitID, weaponID, "Weapon is allowed to fire by BlockShot")
	return false
end

function script.FireWeapon(weaponID)
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
	if not missileWeaponIDs[weaponID] and not flareOnShots[weaponID] then
		EmitSfx(flares[weaponID], SFX.CEG + weaponID) -- TODO: something can be nil here too, maybe a unit lacks a flare piece?
	end
end

function script.Shot(weaponID)
	if missileWeaponIDs[weaponID] then
		EmitSfx(launchPoints[weaponID][currPoints[weaponID]] or launchPoints[weaponID][1], SFX.CEG + weaponID)
        currPoints[weaponID] = currPoints[weaponID] + 1
        if currPoints[weaponID] > burstLengths[weaponID] then 
			currPoints[weaponID] = 1
        end
	elseif flareOnShots[weaponID] and flares[weaponID] then
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
	return weaponID == numWeapons + 1 and cockpit or torso
end

function script.QueryWeapon(weaponID) 
	if missileWeaponIDs[weaponID] then
		return launchPoints[weaponID][currPoints[weaponID]] or launchPoints[weaponID][1]
	elseif weaponID == numWeapons + 1 then -- Sight
		return cockpit
	else
		return flares[weaponID] or torso
	end
end

function GenSalvage(amount)
	for i = 1, amount do
		Explode(pelvis, SFX.FIRE + SFX.SMOKE)
	end
end

function script.Killed(recentDamage, maxHealth)
	if excessHeat >= heatLimit * 2 then
		--Spring.Echo("NUUUUUUUUUUUKKKKKE")
		local x,y,z = Spring.GetUnitPosition(unitID)
		-- This is a really awful hack , built on top of another hack. 
		-- There's some issue with alwaysVisible not working (http://springrts.com/mantis/view.php?id=4483)
		-- So instead make the owner the decal unit spawned by the teams starting beacon, as it can never die
		--local ownerID = Spring.GetTeamUnitsByDefs(teamID, UnitDefNames["decal_beacon"].id)[1] or unitID
		local nukeID = Spring.SpawnProjectile(WeaponDefNames["meltdown"].id, {pos = {x,y,z}, owner = unitID, team = teamID, ttl = 20})
		Spring.SetProjectileAlwaysVisible(nukeID, true)
		-- reward the attacker for the HP destroyed
		local attackerID = Spring.GetUnitLastAttacker(unitID)
		if attackerID then
			local attackerTeam = Spring.GetUnitTeam(attackerID)
			local hp = Spring.GetUnitHealth(unitID)
			local payout = hp * Spring.GetGameRulesParam("damage_reward_mult")
			Spring.AddTeamResource(attackerTeam, "metal", payout)
		end
	else
		local attackerID = Spring.GetUnitLastAttacker(unitID)
		local numSalvage = GG.PinataLevel(attackerID) + 1 -- always produce at least 1
		GenSalvage(numSalvage)
	end
	GG.PlaySoundForTeam(Spring.GetUnitTeam(unitID), "BB_BattleMech_destroyed", 1)
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
