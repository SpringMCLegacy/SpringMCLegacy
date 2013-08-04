-- Test Mech Script
-- useful global stuff
unitDefID = Spring.GetUnitDefID(unitID)
unitDef = UnitDefs[unitDefID]
info = GG.lusHelper[unitDefID]
-- the following have to be non-local for the walkscript include to find them
rad = math.rad

SIG_ANIMATE = {}
jumping = false

-- localised API functions
local SetUnitRulesParam = Spring.SetUnitRulesParam
local GetUnitSeparation = Spring.GetUnitSeparation
local GetUnitCommands   = Spring.GetUnitCommands
local GetUnitLastAttackedPiece = Spring.GetUnitLastAttackedPiece
-- localised GG functions
local GetUnitDistanceToPoint = GG.GetUnitDistanceToPoint
local GetUnitUnderJammer = GG.GetUnitUnderJammer
local IsUnitNARCed = GG.IsUnitNARCed

-- includes
include "smokeunit.lua"
include ("walks/" .. unitDef.name .. "_walk.lua")

-- Info from lusHelper gadget
-- non-local so perks can change them (flagrant lack of encapsulation!)
heatLimit = info.heatLimit 
baseCoolRate = info.coolRate * 2
local coolRate = baseCoolRate
local inWater = false

local missileWeaponIDs = info.missileWeaponIDs
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
	SetUnitRulesParam(unitID, "ammo_" .. k .. "_limit", v)
end
local hasArms = info.arms
local leftArmIDs = info.leftArmIDs
local rightArmIDs = info.rightArmIDs
local leftArmMasterID = info.leftArmMasterID
local rightArmMasterID = info.rightArmMasterID
local amsID = info.amsID
local limbHPs = {}
for k,v in pairs(info.limbHPs) do -- copy table from defaults
	limbHPs[k] = v
end

--Turning/Movement Locals
local TORSO_SPEED = info.torsoTurnSpeed
local ELEVATION_SPEED = info.elevationSpeed
local BARREL_SPEED = info.barrelRecoilSpeed
local RESTORE_DELAY = Spring.UnitScript.GetLongestReloadTime(unitID) * 2

local currLaunchPoint = 1
local currHeatLevel = 0
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
	for i = 1, 4 do
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
	elseif weaponID ~= amsID then
		flares[weaponID] = piece("flare_" .. weaponID)
		if spinSpeeds[weaponID] then
			spinPieces[weaponID] = piece("barrels_" .. weaponID)
			spinPiecesState[weaponID] = false
		elseif info.barrelIDs[weaponID] then
			barrels[weaponID] = piece("barrel_" .. weaponID)
		end
	end
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
	local newAmmoLevel = currAmmo[ammoType] + amount
	if newAmmoLevel <= maxAmmo[ammoType] then
		currAmmo[ammoType] = newAmmoLevel
		SetUnitRulesParam(unitID, "ammo_" .. ammoType, newAmmoLevel)
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
		Sleep(2000)
		StopSpin(spinPieces[weaponID], z_axis, spinSpeeds[weaponID]/10)
	end
	spinPiecesState[weaponID] = start -- must come after the Sleep
end

local function CoolOff()
	local max = math.max
	-- localised API functions
	local GetGameFrame = Spring.GetGameFrame
	local GetGroundHeight = Spring.GetGroundHeight
	local GetUnitBasePosition = Spring.GetUnitBasePosition
	local SetUnitWeaponState = Spring.SetUnitWeaponState
	-- lusHelper info
	local reloadTimes = info.reloadTimes
	local numWeapons = info.numWeapons
	-- variables	
	local heatElevated = false
	local heatCritical = false
	while true do
		local heatElevatedLimit = 0.5 * heatLimit
		coolRate = baseCoolRate -- reset coolRate in case of perk
		if inWater then
			local x, _, z = GetUnitBasePosition(unitID)
			local depth = max(4, GetGroundHeight(x, z) / -3)
			coolRate = baseCoolRate * depth
		end
		currHeatLevel = currHeatLevel - coolRate
		if currHeatLevel < 0 then 
			currHeatLevel = 0 
		end
		if currHeatLevel > heatLimit then 
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
		end
		SetUnitRulesParam(unitID, "heat", currHeatLevel)
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

function SmokeLimb(limb, piece)
	local maxHealth = info.limbHPs[limb] / 100
	while true do
		local health = limbHPs[limb]/maxHealth
		--Spring.Echo("LIMB HEALTH", limb, health, piece)
		if (health <= 66) then -- only smoke if less then 2/3rd limb maxhealth left
			--Spring.Echo("CRASHTESTDUMMY", SFX.CEG + info.numWeapons + 2)
			EmitSfx(piece, SFX.CEG)-- + info.numWeapons + 2)
			--EmitSfx(piece, SFX.CEG + info.numWeapons + 3)
		end
		Sleep(20*health + 150)
	end
end

function hideLimbPieces(limb)
	if limb == "left_arm" then
		RecursiveHide(lupperarm)
		EmitSfx(lupperarm, SFX.CEG + info.numWeapons + 1)
		Explode(lupperarm, SFX.FIRE + SFX.SMOKE)
	elseif limb == "right_arm" then
		RecursiveHide(rupperarm)
		EmitSfx(rupperarm, SFX.CEG + info.numWeapons + 1)
		Explode(rupperarm, SFX.FIRE + SFX.SMOKE)
	end
end

function limbHPControl(limb, damage)
	local currHP = limbHPs[limb]
	if currHP > 0 then
		local newHP = limbHPs[limb] - damage
		--Spring.Echo(unitDef.name, limb, newHP)
		if newHP < 0 then 
			hideLimbPieces(limb)
			newHP = 0
		end
		limbHPs[limb] = newHP
	end
end

function script.HitByWeapon(x, z, weaponID, damage)
	local wd = WeaponDefs[weaponID]
	local heatDamage = wd.customParams.heatdamage or 0
	--Spring.Echo(wd.customParams.heatdamage)
	currHeatLevel = currHeatLevel + heatDamage
	SetUnitRulesParam(unitID, "heat", currHeatLevel)
	local hitPiece = GetUnitLastAttackedPiece(unitID) or ""
	if hitPiece == "torso" or hitPiece == "pelvis" then 
		return damage
	elseif hitPiece == "lupperleg" or hitPiece == "llowerleg" then
		--deduct Left Leg HP
		limbHPControl("left_leg", damage)
	elseif hitPiece == "rupperleg" or hitPiece == "rlowerleg" then
		--deduct Right Leg HP
		limbHPControl("right_leg", damage)
	elseif hitPiece == "lupperarm" or hitPiece == "llowerarm" then
		--deduct Left Arm HP
		limbHPControl("left_arm", damage)
	elseif hitPiece == "rupperarm" or hitPiece == "rlowerarm" then
		--deduct Right Arm HP
		limbHPControl("right_arm", damage)
	end
	return 0
end

function PreJump(delay, turn, lineDist)
	StartThread(anim_PreJump)
end

function StartJump()
	jumping = true
	currHeatLevel = currHeatLevel + jumpHeat
	StartThread(anim_StartJump)
end

function Jumping()-- Gets called throughout by gadget
	for i = 1, #jets do -- emit JumpJetTrail
		EmitSfx(jets[i], SFX.CEG)
	end
end

function HalfJump()
	StartThread(anim_HalfJump)
end

function StopJump()
	jumping = false
	StartThread(anim_StopJump)
end

function StartTurn(clockwise)
	StartThread(anim_Turn, clockwise)
end

function StopTurn()
	StartThread(anim_Reset)
end

function script.StartMoving(reversing)
	Spring.Echo("Reversing?", reversing)
	StartThread(anim_Walk)
end

function script.StopMoving()
	StartThread(anim_Reset)
end

function script.Create()
	if info.builderID then script.StartMoving() end -- walk down ramp
	--StartThread(SmokeUnit, {pelvis, torso})
	StartThread(SmokeLimb, "left_arm", lupperarm)
	StartThread(SmokeLimb, "right_arm", rupperarm)
	StartThread(CoolOff)
end

function script.Activate()
	Spring.SetUnitStealth(unitID, false)
end

function script.Deactivate()
	Spring.SetUnitStealth(unitID, true)
end

local function WeaponCanFire(weaponID)
	if leftArmIDs[weaponID] and limbHPs["left_arm"] <= 0 then
		return false
	elseif rightArmIDs[weaponID] and limbHPs["right_arm"] <= 0 then
		return false
	end
	local ammoType = ammoTypes[weaponID]
	if ammoType and (currAmmo[ammoType] or 0) < (burstLengths[weaponID] or 0) then
		if spinSpeeds[weaponID] then
			StartThread(SpinBarrels, weaponID, false)
		end
		return false
	else
		if spinSpeeds[weaponID] and not spinPiecesState[weaponID] then
			StartThread(SpinBarrels, weaponID, true)
		end
		return true
	end
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
				Turn(launchPoints[weaponID][i], x_axis, -pitch, ELEVATION_SPEED)
			end
		end
	else
		Turn(flares[weaponID], x_axis, -pitch, ELEVATION_SPEED)
		if weaponID == amsID then 
			Turn(flares[weaponID], y_axis, heading, TORSO_SPEED)
			WaitForTurn(flares[weaponID], y_axis)
			return true 
		end
	end

	Turn(torso, y_axis, heading, TORSO_SPEED)
	WaitForTurn(torso, y_axis)
	StartThread(RestoreAfterDelay)
	return WeaponCanFire(weaponID)
end

function script.BlockShot(weaponID, targetID, userTarget)
	if weaponID == amsID then return false end
	local jammable = jammableIDs[weaponID]
	if jammable then
		if targetID then
			local jammed = GetUnitUnderJammer(targetID) and (not IsUnitNARCed(targetID))
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

function script.FireWeapon(weaponID)
	currHeatLevel = currHeatLevel + firingHeats[weaponID]
	SetUnitRulesParam(unitID, "heat", currHeatLevel)
	if barrels[weaponID] and barrelRecoils[weaponID] then
		Move(barrels[weaponID], z_axis, -barrelRecoils[weaponID], BARREL_SPEED)
		WaitForMove(barrels[weaponID], z_axis)
		Move(barrels[weaponID], z_axis, 0, 10)
	end
	local ammoType = ammoTypes[weaponID]
	if ammoType then
		ChangeAmmo(ammoType, -burstLengths[weaponID])
	end
	if not missileWeaponIDs[weaponID] and weaponID ~= amsID then
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
	end
end

function script.EndBurst(weaponID)
	if spinSpeeds[weaponID] then
		StartThread(SpinBarrels, weaponID, false)
	end
end

function script.AimFromWeapon(weaponID) 
	return torso
end

function script.QueryWeapon(weaponID) 
	if missileWeaponIDs[weaponID] then
		return launchPoints[weaponID][currPoints[weaponID]]
	elseif weaponID == amsID then
		return torso
	else
		return flares[weaponID]
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
