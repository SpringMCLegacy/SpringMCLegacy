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
include ("anims/" .. unitDef.name:sub(1, (unitDef.name:find("_", 4) or 0) - 1) .. ".lua")

-- Info from lusHelper gadget
-- non-local so perks can change them (flagrant lack of encapsulation!)
heatLimit = info.heatLimit
baseCoolRate = info.coolRate
local coolRate = baseCoolRate
local inWater = false
local activated = true
local mascLevel = 100
local mascActive = false

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
local hasArms = info.arms
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
local TORSO_SPEED = info.torsoTurnSpeed
local ELEVATION_SPEED = info.elevationSpeed
local BARREL_SPEED = info.barrelRecoilSpeed
local RESTORE_DELAY = Spring.UnitScript.GetLongestReloadTime(unitID) * 2

local currLaunchPoint = 1
local currHeatLevel = 0
local excessHeat = 0
SetUnitRulesParam(unitID, "heat", 0)
SetUnitRulesParam(unitID, "excess_heat", 0)
local jumpHeat = 40
local SlowDownRate = 2

--piece defines
local pelvis, torso = piece ("pelvis", "torso")

local rupperarm, lupperarm
if hasArms then
	rupperarm = piece("rupperarm")
	lupperarm = piece("lupperarm")
end

local jets = {}
if info.jumpjets then
	for i = 1, info.jumpjets do
		jets[i] = piece("jet" .. i)
	end
end

local flares = {}
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
	else
		flares[weaponID] = piece("flare_" .. weaponID)
		if spinSpeeds[weaponID] then
			spinPieces[weaponID] = piece("barrels_" .. weaponID)
			spinPiecesState[weaponID] = false
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
	
	if hasArms then
		Turn(lupperarm, x_axis, 0, ELEVATION_SPEED)
		Turn(rupperarm, x_axis, 0, ELEVATION_SPEED)
	end
end

-- non-local function called by gadgets/game_ammo.lua
function ChangeAmmo(ammoType, amount) 
	local newAmmoLevel = (currAmmo[ammoType] or 0) + amount -- amount is a -ve to deduct
	if newAmmoLevel <= maxAmmo[ammoType] then
		currAmmo[ammoType] = newAmmoLevel
		SetUnitRulesParam(unitID, "ammo_" .. ammoType, 100 * newAmmoLevel / maxAmmo[ammoType])
		return true -- Ammo was changed
	end
	return false -- Ammo was not changed
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
	for i = 1, info.jumpjets do -- emit JumpJetTrail
		Turn(jets[i], x_axis, math.rad(100))
		GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", jets[i], {id = "vExhaustsJets", width = 7, length = 15})
	end
end

function HalfJump()
	StartThread(anim_HalfJump)
end

function StopJump()
	jumping = false
	local x,y,z = GetUnitPosition(unitID)
	--SpawnCEG("mech_jump_dust", x,y,z)
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
end

function script.StopMoving()
	StartThread(anim_Reset)
	moving = false
end

apc = nil
--[[function GetBackIn()
	Spring.GiveOrderToUnit(unitID, CMD.LOAD_ONTO, {apc}, {})
	Spring.GiveOrderToUnit(apc, CMD.WAIT, {}, {})
end]]

local function bob()
	while true do
		if not Spring.GetUnitIsDead(unitID) then
			Spring.MoveCtrl.SetGunshipMoveTypeData(unitID, "wantedHeight", 50 + math.random(-50, 50))
		end
		Sleep(1000 + math.random(-500, 500))
	end
end

function script.Create()
	apc = Spring.GetUnitTransporter(unitID)
	for i = 1,2 do
		Spring.SetUnitWeaponState(unitID, i, "range", 500)
	end
	--StartThread(bob)
	StartThread(Jumping)
end

local function WeaponCanFire(weaponID)
	local ammoType = ammoTypes[weaponID]
	if ammoType and (currAmmo[ammoType] or 0) < (burstLengths[weaponID] or 0) then
		if spinSpeeds[weaponID] then
			StartThread(SpinBarrels, weaponID, false)
		end
		return false
	end
	return true
end

function script.AimWeapon(weaponID, heading, pitch)
	Signal(2 ^ weaponID) -- 2 'to the power of' weapon ID
	SetSignalMask(2 ^ weaponID)

	if hasArms and (weaponID == leftArmMasterID or weaponID == rightArmMasterID) then
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
		Turn(flares[weaponID], x_axis, -pitch, ELEVATION_SPEED)
		if amsIDs[weaponID] then 
			Turn(flares[weaponID] or flares[1], y_axis, heading, TORSO_SPEED)
			WaitForTurn(flares[weaponID] or flares[1], y_axis)
			return true 
		end
	end

	Turn(torso, y_axis, heading, TORSO_SPEED)
	WaitForTurn(torso, y_axis)
	StartThread(RestoreAfterDelay)
	return WeaponCanFire(weaponID)
end


function script.FireWeapon(weaponID)
	local ammoType = ammoTypes[weaponID]
	if ammoType then
		ChangeAmmo(ammoType, -burstLengths[weaponID])
	end
	if not missileWeaponIDs[weaponID] and not flareOnShots[weaponID] then
		EmitSfx(flares[weaponID], SFX.CEG + weaponID)
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
end

function script.AimFromWeapon(weaponID) 
	return torso
end

function script.QueryWeapon(weaponID) 
	if missileWeaponIDs[weaponID] then
		return launchPoints[weaponID][currPoints[weaponID]] or launchPoints[weaponID][1]
	else
		return flares[weaponID] or torso
	end
end

function script.Killed(recentDamage, maxHealth)
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
