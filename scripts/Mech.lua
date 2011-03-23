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

-- includes
include "smokeunit.lua"
include ("walks/" .. unitDef.name .. "_walk.lua")

-- Info from lusHelper gadget
local heatLimit = info.heatLimit
local coolRate = info.coolRate * 4
local inWater = false
local missileWeaponIDs = info.missileWeaponIDs
local launcherIDs = info.launcherIDs
local burstLengths = info.burstLengths
local heatDamages = info.heatDamages
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
local jumpHeat = 40
local SlowDownRate = 2

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
	local max = math.max
	-- localised API functions
	local GetGameFrame = Spring.GetGameFrame
	local GetGroundHeight = Spring.GetGroundHeight
	local GetUnitBasePosition = Spring.GetUnitBasePosition
	local SetUnitWeaponState = Spring.SetUnitWeaponState
	-- lusHelper info
	local reloadTimes = info.reloadTimes
	local numWeapons = info.numWeapons
	local baseCoolRate = info.coolRate
	-- variables	
	local heatElevatedLimit = 0.5 * heatLimit
	local heatElevated = false
	local heatCritical = false
	while true do
		if inWater then
			local x, _, z = GetUnitBasePosition(unitID)
			local depth = max(3, GetGroundHeight(x, z) / -3)
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
				for weaponID = 0, numWeapons - 1 do
					SetUnitWeaponState(unitID, weaponID, {reloadTime = 99999, reloadFrame = 99999})
				end
			end
		elseif currHeatLevel > heatElevatedLimit then
			if heatCritical and not heatElevated then -- critical -> elevated
				heatElevated = true
			elseif not heatElevated then -- normal -> elevated
				heatElevated = true
				-- reduce weapon rate here
				for weaponID = 0, numWeapons - 1 do
					local reload = reloadTimes[weaponID + 1] * 2
					SetUnitWeaponState(unitID, weaponID, {reloadTime = reload})
				end
			end
		else
			if heatCritical then -- critical->elevated->normal
				-- reset weapon rate here
				for weaponID = 0, numWeapons - 1 do
					local currFrame = GetGameFrame()
					SetUnitWeaponState(unitID, weaponID, {reloadTime = reloadTimes[weaponID + 1], reloadFrame = currFrame + reloadTimes[weaponID + 1] * 30})
				end
			elseif heatElevated then -- elevated->normal
				-- reset weapon rate here
				for weaponID = 0, numWeapons - 1 do
					SetUnitWeaponState(unitID, weaponID, {reloadTime = reloadTimes[weaponID + 1]})
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
		coolRate = info.coolRate * 4
	end
end

function script.HitByWeapon(x, z, weaponID)
	local wd = WeaponDefs[weaponID]
	local heatDamage = wd.customParams.heatdamage or 0
	--Spring.Echo(wd.customParams.heatdamage)
	currHeatLevel = currHeatLevel + heatDamage
	SetUnitRulesParam(unitID, "heat", currHeatLevel)
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
