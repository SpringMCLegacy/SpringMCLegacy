-- Test Mech Script
-- useful global stuff
info = GG.lusHelper[unitDefID]
-- the following have to be non-local for the walkscript include to find them
rad = math.rad
local teamID = Spring.GetUnitTeam(unitID)

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
local GetUnitUnderECCM = GG.GetUnitUnderECCM
local IsUnitNARCed = GG.IsUnitNARCed
local IsUnitTAGed = GG.IsUnitTAGed

-- includes
include "smokeunit.lua"
include ("anims/mechs/" .. unitDef.name:sub(4, (unitDef.name:find("_", 4) or 0) - 1) .. ".lua")

-- Info from lusHelper gadget
-- non-local so perks can change them (flagrant lack of encapsulation!)
numWeapons = info.numWeapons
heatLimit = info.heatLimit
baseCoolRate = info.coolRate
runHeat = math.sqrt(unitDef.customParams.tonnage) * 0.02
firingHeats = {}
table.copy(info.firingHeats, firingHeats) -- fire discipline perk, PPC capacitor mod need to modify this so copy don't reference
TORSO_SPEED = info.torsoTurnSpeed -- AES mod
ELEVATION_SPEED = info.elevationSpeed -- AES mod
maxAmmo = {} -- Extended Range LRM mod
table.copy(info.maxAmmo, maxAmmo) -- need our own local copy or the lus helper one is overriden
currAmmo = {}  -- Extended Range LRM mod
inhibitors = {} -- PPC inhibitor mod
case = false -- CASE mod
expandedBins = false -- Expanded Ammo Bins mod

local coolRate = baseCoolRate
local inWater = false
local activated = true
local running = false
local mascActive = false
local mascDamage = 2
local superCharger = false
local superChargerHeat = 0.1
local superChargerDamage = 5
local tsmActive = false
local lostLegs = 0

local missileWeaponIDs = info.missileWeaponIDs
local flareOnShots = info.flareOnShots
local jammableIDs = info.jammableIDs
local launcherIDs = info.launcherIDs
local barrelRecoils = info.barrelRecoilDist
local burstLengths = info.burstLengths
local ammoTypes = info.ammoTypes
local minRanges = info.minRanges
local spinSpeeds = info.spinSpeeds
-- copy maxAmmo table into currAmmo
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
local SPIN_WAIT_MULT = 5 -- how many times spinSpeed to wait
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
local spinners = {}

local playerDisabled = {}
for weaponID = 1, numWeapons do
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
			spinners[weaponID] = {
				pieceNum = piece("barrels_" .. weaponID),
				state = 0,
				wait = math.deg(spinSpeeds[weaponID]) * SPIN_WAIT_MULT,
			}
		elseif info.barrelIDs[weaponID] then
			barrels[weaponID] = piece("barrel_" .. weaponID)
		end
	end
	playerDisabled[weaponID] = false
	SetUnitRulesParam(unitID, "weapon_" .. weaponID, "active")
end

local function RestoreAfterDelay(delay)
	Sleep(delay)
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

-- non-local function called by gadgets/game_ammo.lua & Expanded Ammo Bins mod
function ChangeAmmo(ammoType, amount, maxAmmoMult) 
	if not currAmmo[ammoType] then return false end -- don't have this kind of ammo
	local newAmmoLevel = (currAmmo[ammoType] or 0) + (amount or 0) -- amount is a -ve to deduct
	if not amount then -- whut?
		Spring.Echo("ChangeAmmo amount was nil", ammoType, unitDef.name)
		amount = 0
	end
	if amount > 0 then -- restocking, reset the indicator
		SetUnitRulesParam(unitID, "outofammo", 0)
	end
	if maxAmmoMult then
		maxAmmo[ammoType] = math.floor(maxAmmo[ammoType] * maxAmmoMult)
		currAmmo[ammoType] = math.min(currAmmo[ammoType], maxAmmo[ammoType])
	end
	if not newAmmoLevel and maxAmmo[ammoType] then -- ERROR: somehow one of these can be wrong type / nil?
		Spring.Echo("BUGREPORT: Mech.lua L168:", newAmmoLevel, maxAmmo[ammoType])
	elseif newAmmoLevel <= maxAmmo[ammoType] then 
		currAmmo[ammoType] = math.max(newAmmoLevel, 0)
		SetUnitRulesParam(unitID, "ammo_" .. ammoType, 100 * newAmmoLevel / maxAmmo[ammoType])
		return true -- Ammo was changed
	end
	return false -- Ammo was not changed
end

local SPIN_WAIT_MULT = 5 -- how many times spinSpeed to wait

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
		if excessHeat >= heatLimit * 2 then
			--Spring.DestroyUnit(unitID, true)
			if not shutdownRunning then
				StartThread(ShutDown)
			end
		end
	elseif currHeatLevel < 0 then
		currHeatLevel = 0
	end
	SetUnitRulesParam(unitID, "heat", math.ceil(100 * currHeatLevel / heatLimit))
	SetUnitRulesParam(unitID, "excess_heat", math.ceil(100 * excessHeat / (2 * heatLimit)))
end

local lastCoolant = 0
local COOLANT_TIME = 10 * 30 -- 10 seconds
function FlushCoolant()
	--if currAmmo.coolant > 0 then
	if Spring.GetGameFrame() >= lastCoolant + COOLANT_TIME then
		GG.EmitSfxName(unitID, torso, "greengoo")
		ChangeHeat(-10)
		--ChangeAmmo("coolant", -20)
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
		if GG.stealthActive[unitID] then coolRate = coolRate * 0.75 end
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
		--Spring.Echo("CoolOff() loop", currHeatLevel, heatLimit, currHeatLevel/heatLimit, tsmActive, lostLegs)
		if lostLegs == 0 and tsmActive and (currHeatLevel/heatLimit > 0.33) then
			speedMod = (running and 1.5 * 1.3 or 1.2) * (superCharger and 1.25 or 1)
			--Spring.Echo("heat is more than 33%, tsmActive", speedMod)
			SpeedChangeCheck()
		end
		ChangeHeat(-coolRate)
		--[[if hasEcm and not moving then
			AddUnitSeismicPing(unitID, 20)
		end]]
		Sleep(1000) -- cools once per second
	end
end

local shutdownRunning = false
function ShutDown()
	Signal() -- kill everything
	StartThread(CoolOff) -- restart cooling
	shutdownRunning = true
	SetUnitRulesParam(unitID, "shutdown", 1)
	-- weapons are dealt with in main CoolOff loop
	-- turn off radar
	Spring.UnitScript.SetUnitValue(COB.ACTIVATION, false)
	-- prevent all movement
	Spring.MoveCtrl.Enable(unitID)
	while excessHeat > 0 do
		GG.EmitLupsSfx(unitID, "dropship_horizontal_jitter_strong", torso, {repeatEffect = 2, emitVector = {0,1,0}})
		Sleep(300)
	end
	-- reboot
	Spring.UnitScript.SetUnitValue(COB.ACTIVATION, true)
	Spring.MoveCtrl.Disable(unitID)
	shutdownRunning = false
	SetUnitRulesParam(unitID, "shutdown", 0)
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
	Signal(hitPiece)
	SetSignalMask(hitPiece)
	local maxHealth = info.limbHPs[limb] / 100
	local health = limbHPs[limb]/maxHealth
	while health <= 66 do
		health = limbHPs[limb]/maxHealth
		EmitSfx(piece(hitPiece), SFX.CEG + numWeapons + 2)
		EmitSfx(piece(hitPiece), SFX.CEG + numWeapons + 3)
		Sleep(20*health + 150)
		--Spring.Echo("SmokeLimb", hitPiece)
	end
end


function hideLimbPieces(limb, hide, silent)
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
			if not silent then
				Explode(side, SFX.FIRE + SFX.SHATTER + SFX.RECURSIVE)
			end
			lostLegs = lostLegs + 1
			--Spring.Echo("Lost a leg! halving move speed")
			speedMod = 1 / (2^lostLegs)
			StartThread(SpeedChangeCheck)
			-- disable jumpjets
			if GG.unitMechanicalJumps[unitID] and info.jumpjets > 0 then
				Spring.EditUnitCmdDesc(unitID, Spring.FindUnitCmdDesc(unitID, CMD_JUMP), {disabled = true})
			end
		else -- leg is restored
			lostLegs = lostLegs - 1
			--Spring.Echo("Regained a leg! doubling move speed")
			speedMod = 1 / (2^lostLegs)
			StartThread(SpeedChangeCheck)
			if GG.unitMechanicalJumps[unitID] and lostLegs == 0 and info.jumpjets > 0 then -- enable jumpjets
				Spring.EditUnitCmdDesc(unitID, Spring.FindUnitCmdDesc(unitID, CMD_JUMP), {disabled = false})
			end
		end
		SetUnitRulesParam(unitID, "lostlegs", lostLegs)
		StartThread(SpeedChangeCheck)
		return
	end
	if hide then
		if not silent then
			EmitSfx(rootPiece, SFX.CEG + numWeapons + 1)
			Explode(rootPiece, SFX.FIRE + SFX.SMOKE + SFX.RECURSIVE)
		end
		local cookoffDamage = 0
		for id, valid in pairs(limbWeapons) do
			local damage = 0
			if id and valid then
				--local weapDef = WeaponDefs[unitDef.weapons[id].weaponDef]
				--Spring.Echo(unitDef.humanName .. ": " .. weapDef.name .. " destroyed!")
				ToggleWeapon(id, 1)
				local weapDef = WeaponDefs[unitDef.weapons[id].weaponDef]
				local ammoType = ammoTypes[id]
				--Spring.Echo("Destroyed weapon", weapDef.name, "had ammo type", ammoType, "was 1 of", info.ammoTypeWeapCounts[ammoType], "mech had", currAmmo[ammoType], "/", maxAmmo[ammoType])
				if ammoType and not silent then
					local ammoPCentLost = case and 0.25 or 0.5
					local ammoLost = math.floor(currAmmo[ammoType] / info.ammoTypeWeapCounts[ammoType] * ammoPCentLost)
					ChangeAmmo(ammoType, -ammoLost)
					cookoffDamage = cookoffDamage + 1000
				end
			end
		end
		cookoffDamage = cookoffDamage * ((case or silent) and 0 or expandedBins and 2 or 1)
		if cookoffDamage > 0 then Spring.AddUnitDamage(unitID, cookoffDamage, nil, nil, -314) end
	else
		for id, valid in pairs(limbWeapons) do
			if valid then
				--local weapDef = WeaponDefs[unitDef.weapons[id].weaponDef]
				ToggleWeapon(id, 2)
			end
		end		
	end
end

local limbsLost = 0
function limbHPControl(limb, damage, piece, silent, hpNotDamage)
	local currHP = limbHPs[limb]
	if currHP > 0 or (damage or 0) < 0 then
		local newHP = hpNotDamage and damage or math.min(limbHPs[limb] - damage, info.limbHPs[limb]) -- don't allow HP above max
		--Spring.Echo(unitDef.name, limb, "newHP", newHP, "currHP", currHP)
		if newHP < 0 then 
			hideLimbPieces(limb, true, silent)
			newHP = 0
			limbsLost = limbsLost + 1
			SetUnitRulesParam(unitID, "limblost", limbsLost)
			Script.LuaRules.MechNeedsBay(unitID, teamID) -- let AI know
		elseif currHP == 0 then -- can only get here if damage < 0 i.e. repairing
			hideLimbPieces(limb, false)
			limbsLost = limbsLost - 1
			SetUnitRulesParam(unitID, "limblost", limbsLost)
		else
			if (newHP/info.limbHPs[limb] * 100) <= 66 and piece then --and (currHP/info.limbHPs[limb] * 100) > 66 and piece then
				if limb == "left_arm" then
					piece = "lupperarm"
				elseif limb == "right_arm" then
					piece = "rupperarm"
				end
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
	if weaponID == -314 then return end -- avoid infinite recursion in ammo cookoff
	local wd = WeaponDefs[weaponID]
	local hitPiece = piece or GetUnitLastAttackedPiece(unitID) or ""
	--Spring.Echo("HIT PIECE?", hitPiece, damage, heatDamage)
	if weaponID == GG.lusHelper.MINE_WDID then
		--Spring.Echo("MOIN! MOIN! MOIN!")
		limbHPControl("left_leg", damage/2, "llowerleg")
		limbHPControl("right_leg", damage/2, "rlowerleg")
	end -- hitPiece will be "" for mines so the next bit deals normal torso damage too
	if hitPiece == "torso" or hitPiece == "pelvis" or hitPiece == "" then 
		return damage
	end
	local limbMult = (weaponID == GG.lusHelper.MG_WDID) and 40 or 1
	if hitPiece == "lupperleg" or hitPiece == "llowerleg" then
		--deduct Left Leg HP
		local hp = limbHPControl("left_leg", damage * limbMult, hitPiece)
		if hp == 0 then return damage end
	elseif hitPiece == "rupperleg" or hitPiece == "rlowerleg" then
		--deduct Right Leg HP
		local hp = limbHPControl("right_leg", damage * limbMult, hitPiece)
		if hp == 0 then return damage end
	elseif hitPiece == "lupperarm" or hitPiece == "llowerarm" then
		--deduct Left Arm HP
		limbHPControl("left_arm", damage * limbMult, hitPiece)
	elseif hitPiece == "rupperarm" or hitPiece == "rlowerarm" then
		--deduct Right Arm HP
		limbHPControl("right_arm", damage * limbMult, hitPiece)
	end
	return 0
end

local SIG_RUN = maxAmmo


local function RunDamage()
	Signal(SIG_RUN)
	SetSignalMask(SIG_RUN)
	while moving and running do
		if mascActive then
			--Spring.Echo("In mascActive damage loop")
			limbHPControl("left_leg", mascDamage, "llowerleg")
			limbHPControl("right_leg", mascDamage, "rlowerleg")
			if lostLegs > 0 then
				--Spring.Echo("Owww, my hammy")
				-- SIG_ANIMATE is just an empty table, don't create a new one just for empty command options
				Spring.GiveOrderToUnit(unitID, GG.CustomCommands.GetCmdID("CMD_MASC"), {0}, SIG_ANIMATE) 
				Run(false)
				return
			end
		end
		if superCharger then
			--Spring.Echo("In superCharger damage loop")
			Spring.AddUnitDamage(unitID, superChargerDamage)
			local health, maxHealth = Spring.GetUnitHealth(unitID)
			if health/maxHealth < 0.25 then
				Run(false)
				return
			end
		end
		local heat = superCharger and superChargerHeat or runHeat
		ChangeHeat(heat)
		if excessHeat > 0 then
			--Spring.Echo("Overheating! Slow down")
			-- SIG_ANIMATE is just an empty table, don't create a new one just for empty command options
			--Spring.GiveOrderToUnit(unitID, GG.CustomCommands.GetCmdID("CMD_MASC"), {0}, SIG_ANIMATE) 
			Run(false)
			return
		end
		Sleep(100)
	end
end


function SpeedChangeCheck()
	if shutdownRunning then return false end
	while jumping do -- don't trigger speed change until jump is finished
		Sleep(100)
	end
	GG.SpeedChange(unitID, unitDefID, speedMod)
end

function Run(activate)
	if shutdownRunning then return false end
	if lostLegs > 0 then
		return -- do not allow running at all if you have a damaged leg
	end
	if not activate then -- not running, return to normal
		speedMod = (tsmActive and (currHeatLevel/heatLimit > 0.33) and 1.2) or 1
		Spring.SetUnitRulesParam(unitID, "running", 0)
	else -- running
		Spring.SetUnitRulesParam(unitID, "running", 1)
		if mascActive then
			speedMod = 2
		elseif tsmActive then -- extra 30% increase at >1/3rd heat
			speedMod = (currHeatLevel/heatLimit > 0.33) and 1.3 * 1.5 or 1.5
		else
			speedMod = 1.5
		end
		if superCharger then -- supercharger stacks so separate if
			speedMod = speedMod * 1.25
		end
	end
	--Spring.Echo("Run", activate, speedMod, "mascActive", mascActive, "tsmActive", tsmActive, "superCharger", superCharger)
	speedMod = speedMod * (GG.modOptions and GG.modOptions.speed or 1.0) -- respect modoption
	running = activate
	StartThread(SpeedChangeCheck)
	if activate then 
		StartThread(RestoreAfterDelay, 1)
		StartThread(RunDamage)
	end
end

function EnableMASC(enable)
	mascActive = enable
	Run(running)
end

function EnableSuperCharger(enable)
	superCharger = enable
	Run(running)
end

function EnableTSM(enable)
	tsmActive = enable
	Run(running)
end
function PreJump(delay, turn, lineDist)
	StartThread(anim_PreJump)
end

function StartJump()
	jumping = true
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
	if reversing then Run(false) end
	--Spring.Echo("Reversing?", reversing)
	StartThread(anim_Walk)
	moving = true
end

function script.StopMoving()
	Spring.SetUnitRulesParam(unitID, "running", 0)
	StartThread(anim_Reset)
	moving = false
	running = false
end

function script.Create()
	Spring.SetUnitMaxRange(unitID, unitDef.customParams.maxrange)
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
		Script.LuaRules.MechNeedsBay(unitID, teamID, weaponID == tonumber(unitDef.customParams.maxrangeid) and unitDef.customParams.maxrange or nil) -- let AI know
		return false
	elseif spinSpeeds[weaponID] then 
		local spinState = spinners[weaponID].state
		if spinState < 1 then
			StartThread(SpinBarrels, weaponID, true)
			return false -- can't fire until spun up
		else
			return spinState == 2
		end
	elseif missileWeaponIDs[weaponID] then
	
		if nearby then
			
		end
	end
	-- check we are not inside a mechbay
	local nearby = Spring.GetUnitNearestAlly(unitID, 50) or -1
	--Spring.Echo(unitID, weaponID, "Weapon is allowed to fire by WeaponCanFire")
	return not GG.mechBays[nearby]
end
GG.WeaponCanFire = WeaponCanFire

function script.AimWeapon(weaponID, heading, pitch)
	if running or playerDisabled[weaponID] or shutdownRunning then return false end
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
	StartThread(RestoreAfterDelay, RESTORE_DELAY)
	return WeaponCanFire(weaponID)
end

local weaponsToReset = {}
function script.BlockShot(weaponID, targetID, userTarget)
	if amsIDs[weaponID] then return false end
	local minRange = minRanges[weaponID]
	local weapDef = WeaponDefs[unitDef.weapons[weaponID].weaponDef]
	local targetDef = targetID and UnitDefs[Spring.GetUnitDefID(targetID)]
	if minRange then
		local distance
		if targetID then
			distance = GetUnitSeparation(unitID, targetID, true)
		elseif userTarget then
			local cmd = GetUnitCommands(unitID, 1)[1]
			if cmd and cmd.id == CMD.ATTACK then
				local tx,ty,tz = unpack(cmd.params)
				distance = GetUnitDistanceToPoint(unitID, tx, ty, tz, false)
			end
		end
		if distance and distance < minRange then
			--Spring.Echo("Can't fire weapon " .. weaponID .. " as target is within minimum range")
			if not inhibitors[weaponID] then
				return true 
			else
				GG.ApplyPPC(unitID, unitDefID)
				return false
			end
		end
	end
	local jammable = jammableIDs[weaponID]
	if jammable then
		if targetID then
			if not activated then return true end
			local jammed = (GetUnitUnderECCM(unitID) or GetUnitUnderJammer(targetID) -- under the effects of (E)ECM
				or GG.stealthActive[targetID]) -- OR stealth armour
				and (not IsUnitNARCed(targetID)) and (not IsUnitTAGed(targetID)) -- AND not TAGed or NARCed
			local weaponClass = weapDef.customParams.weaponclass
			local ARAD = GG.unitSpecialAmmos[unitID][weaponClass] == "arad" 
			if ARAD and GG.jammerCache[targetID] then return false end
			if jammed then
				--Spring.Echo("Can't fire weapon " .. weaponID .. " as target is jammed")
				Spring.SetUnitRulesParam(unitID, "MISSILE_TARGET_JAMMED", Spring.GetGameFrame(), {inlos = true})
				return true 
			else
				Spring.SetUnitRulesParam(targetID, "ENEMY_MISSILE_LOCK", Spring.GetGameFrame(), {inlos = true})
			end
		end
	end
	if targetID and GG.stealthActive[targetID] then
		Spring.SetUnitWeaponState(unitID, weaponID, "accuracy", weapDef.accuracy * 1.25)
		weaponsToReset[weaponID] = true
	end
	--Spring.Echo(unitID, weaponID, "Weapon is allowed to fire by BlockShot")
	return false
end

--[[function script.TargetWeight(weaponID, targetID)
	local setTarget = Spring.GetUnitRulesParam(unitID, "targetID")
	--Spring.Echo("Karen says I've reached my TargetWeight", weaponID, targetID, "setTarget", setTarget)
	if setTarget and setTarget ~= "" and setTarget ~= -1 then
		return targetID == setTarget and 0.01 or 100
	end
	local targetDefID = Spring.GetUnitDefID(targetID)
	if not targetDefID then return 1 end
	local weapDef = WeaponDefs[unitDef.weapons[weaponID].weaponDef]
	if GG.dropShipCache[targetDefID] then 
		--Spring.Echo("TargetWeight (dropShip)", unitID, weapDef.name, UnitDefs[targetDefID].name, 5)
		return 5  -- low priority
	elseif GG.mechCache[targetDefID] then
		local range = weapDef.range
		local minRange = minRanges[weaponID]
		local dist = Spring.GetUnitSeparation(unitID, targetID)
		if minRange then
			if dist < minRange then
				--Spring.Echo("TargetWeight (In minRange)", unitID, weapDef.name, UnitDefs[targetDefID].name, 50)
				return 50 -- really don't want to target things in minrange if we can help it
			elseif missileWeaponIDs[weaponID] then
				--Spring.Echo("TargetWeight (Far)", unitID, weapDef.name, UnitDefs[targetDefID].name, range/dist)
				return (range-dist)/range -- prefer far targets for LRM / Arrow
			end
		else
			--Spring.Echo("TargetWeight (Close)", unitID, weapDef.name, UnitDefs[targetDefID].name, dist/range)
			return dist/range -- prefer close targets
		end
	end
	return 1
end]]

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
		if not flares[weaponID] then 
			Spring.Echo("BUGREPORT L842 of mech.lua, missing flare", unitDef.name, weaponID)
		else
			EmitSfx(flares[weaponID], SFX.CEG + weaponID)
		end
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
	local weapDef = WeaponDefs[unitDef.weapons[weaponID].weaponDef]
	if spinSpeeds[weaponID] then
		StartThread(SpinBarrels, weaponID, false)
	end
	if weaponsToReset[weaponID] then
		Spring.SetUnitWeaponState(unitID, weaponID, "accuracy", weapDef.accuracy)
		Spring.SetUnitWeaponState(unitID, weaponID, "projectileSpeed", weapDef.projectilespeed or 100)
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
	math.randomseed(unitID)
	local stackpoleProb = (currHeatLevel + excessHeat - heatLimit/2)/(heatLimit*2.5) * (superCharger and 2 or 1)
	local diceRoll = math.random()
	--Spring.Echo("Will I nuke?", stackpoleProb, diceRoll, stackpoleProb > diceRoll)
	local x,y,z = Spring.GetUnitBasePosition(unitID)
	if stackpoleProb > diceRoll then
		--Spring.Echo("NUUUUUUUUUUUKKKKKE")
		local DELAY_IN_SECONDS = 0.1
		GG.Delay.DelayCall(Spring.CreateUnit,{"nuke_meltdown", x, y, z, 0, teamID}, 30 * DELAY_IN_SECONDS)
	end
	-- Salavage time
	local attackerID = Spring.GetUnitLastAttacker(unitID)
	local numSalvage = GG.PinataLevel(attackerID) + 1 -- always produce at least 1
	GenSalvage(numSalvage)
	-- Let Betty commemorate your sacrifice
	local soundNum = math.random(2)
	if not Spring.GetUnitTransporter(unitID) then
		GG.PlaySoundForTeam(Spring.GetUnitTeam(unitID), "BB_BattleMech_destroyed_" .. soundNum, 1)
	end
	-- live fast, die young, leave a beautiful corpse
	local lArm = limbHPs["left_arm"] <= 0
	local rArm = limbHPs["right_arm"] <= 0
	local corpseType = (rArm and lArm) and "both" or rArm and "right" or lArm and "left" or nil
	if not corpseType then return 1 end
	-- spawn relevant feature
	local heading = Spring.GetUnitHeading(unitID)
	local featureID = Spring.CreateFeature(unitDef.name .. "_x_" .. corpseType, x,y,z, heading, teamID)
end
