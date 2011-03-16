-- Test Mech Script
-- useful global stuff
unitDefID = Spring.GetUnitDefID(unitID)
unitDef = UnitDefs[unitDefID]
info = GG.lusHelper[unitDefID]
-- the following have to be non-local for the walkscript include to find them
rad = math.rad
walking = false
jumping = false

-- localised API functions
local SetUnitRulesParam = Spring.SetUnitRulesParam
local SetUnitWeaponState = Spring.SetUnitWeaponState

-- includes
include "smokeunit.lua"
include ("walks/" .. unitDef.name .. "_walk.lua")

-- Info from lusHelper gadget
local heatLimit = info.heatLimit
local coolRate = info.coolRate
local missileWeaponIDs = info.missileWeaponIDs
local launcherIDs = info.launcherIDs
local burstLengths = info.burstLengths
local firingHeats = info.firingHeats
local hasArms = info.arms
local leftArmID = info.leftArmID
local rightArmID = info.rightArmID
local amsID = info.amsID

--Turning/Movement Locals
local TORSO_SPEED = info.torsoTurnSpeed
local ELEVATION_SPEED = info.elevationSpeed
local RESTORE_DELAY = Spring.UnitScript.GetLongestReloadTime(unitID) * 2

local currLaunchPoint = 1
local currHeatLevel = 0
local jumpHeat = 50
local heatDangerLimit = heatLimit * 0.5
local SlowDownRate = 2
local SlowFire = false
local StopFire = false

--piece defines
local pelvis, torso = piece ("pelvis", "torso")

local rlowerarm, llowerarm
if hasArms then
	rlowerarm = piece("rlowerarm")
	llowerarm = piece("llowerarm")
end

local jets = {}
if info.jumpjets then
	for i = 1, 4 do
		jets[i] = piece("jet" .. i)
	end
end

local flares = {}
local launchers = {}
local launchPoints = {}
local currPoints = {}
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
		flares[weaponID] = piece ("flare_" .. weaponID)
	end
end

local function RestoreAfterDelay(unitID)
	Sleep(RESTORE_DELAY)
	Turn(torso, y_axis, 0, TORSO_SPEED)
	
	if hasArms then
		Turn(llowerarm, x_axis, 0, ELEVATION_SPEED)
		Turn(rlowerarm, x_axis, 0, ELEVATION_SPEED)
	end
end

local function CoolOff()
	while true do
		currHeatLevel = currHeatLevel - coolRate
		if currHeatLevel < 0 then 
			currHeatLevel = 0 
		end
		if currHeatLevel > heatDangerLimit and currHeatLevel < heatLimit then 
			SlowFire = true
		elseif currHeatLevel < heatDangerLimit or currHeatLevel > heatLimit then 
			SlowFire = false 
		end
		if currHeatLevel > heatLimit then 
			StopFire = true 
		end
		if StopFire and currHeatLevel < heatDangerLimit then 
			StopFire = false 
		end
		SetUnitRulesParam(unitID, "heat", currHeatLevel)
		Sleep(1000) -- cools once per second
	end
end

function JumpFX()
	while jumping do
		local jumpJetTrail = SFX.CEG
		for i = 1, #jets do
			EmitSfx(jets[i], jumpJetTrail)
		end
		Sleep(50)
	end
end

function beginJump()
	jumping = true
	currHeatLevel = currHeatLevel + jumpHeat
	StartThread(JumpFX)
end

function endJump()
	jumping = false
end

function script.Create()
	StartThread(SmokeUnit, {pelvis, torso})
	StartThread(MotionControl)
	StartThread(CoolOff)
end

function script.StartMoving()
	walking = true
end

function script.StopMoving()
	walking = false
end

function script.Activate()
	Spring.SetUnitStealth(unitID, false)
end

function script.Deactivate()
	Spring.SetUnitStealth(unitID, true)
end

function script.AimWeapon(weaponID, heading, pitch)
	Signal(2 ^ weaponID) -- 2 'to the power of' weapon ID
	SetSignalMask(2 ^ weaponID)

	if hasArms and (weaponID == leftArmID or weaponID == rightArmID) then
		if weaponID == leftArmID then
			Turn(llowerarm, x_axis, -pitch, ELEVATION_SPEED)
		elseif weaponID == rightArmID then
			Turn(rlowerarm, x_axis, -pitch, ELEVATION_SPEED)
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
	end

	Turn(torso, y_axis, heading, TORSO_SPEED)
	WaitForTurn(torso, y_axis)
	StartThread(RestoreAfterDelay)
	return true
end

function script.FireWeapon(weaponID)
	currHeatLevel = currHeatLevel + firingHeats[weaponID]
	if SlowFire == false and StopFire == false then
		Spring.Echo("Mech " .. unitID .. ": Heat normal.")
	end
	if SlowFire then
		Spring.Echo("Mech " .. unitID .. ": Heat rising.")
	end
	if StopFire then 
		Spring.Echo("Mech " .. unitID .. ": Heat critical.")
	end
	SetUnitRulesParam(unitID, "heat", currHeatLevel)
end

function script.Shot(weaponID)
	if missileWeaponIDs[weaponID] then
		EmitSfx(launchPoints[weaponID][currPoints[weaponID]], SFX.CEG + weaponID)
        currPoints[weaponID] = currPoints[weaponID] + 1
        if currPoints[weaponID] > burstLengths[weaponID] then 
			currPoints[weaponID] = 1
        end
	else
		EmitSfx(flares[weaponID], SFX.CEG + weaponID)
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
