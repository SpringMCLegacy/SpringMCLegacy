-- Vehicle Script
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

-- Info from lusHelper gadget
local heatLimit = info.heatLimit
local coolRate = info.coolRate * 4
local inWater = false
local missileWeaponIDs = info.missileWeaponIDs
local launcherIDs = info.launcherIDs
local barrelRecoils = info.barrelRecoilDist
local burstLengths = info.burstLengths
local heatDamages = info.heatDamages
local firingHeats = info.firingHeats
local amsID = info.amsID
local hover = info.hover
local vtol = info.vtol

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

--piece defines
local body, turret = piece ("body", "turret")

local wheels = {}
local trackr, trackl, wakepoint, blades1
if hover then
	wakepoint = piece ("wakepoint")
elseif vtol then
	blades1 = piece ("blades1")
else
	trackr, trackl = piece ("trackr", "trackl")
	for i = 1, info.numWheels do
		wheels[i] = piece ("wheel"..i)
	end
end

local flares = {}
local turrets = info.turrets
local mantlets = {}
local barrels = {}
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

local function RestoreAfterDelay(unitID)
	Sleep(RESTORE_DELAY)
	Turn(turret, y_axis, 0, TURRET_SPEED)
	for id in pairs(mantlets) do
		Turn(mantlets[id], x_axis, 0, ELEVATION_SPEED)
	end
	for id in pairs(launchers) do
		Turn(launchers[id], x_axis, 0, ELEVATION_SPEED)
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

function script.Create()
	StartThread(SmokeUnit, {body, turret})
	StartThread(CoolOff)
end

function script.StartMoving()
	for i = 1, #wheels do
		Spin(wheels[i], x_axis, WHEEL_SPEED, WHEEL_ACCEL)
	end
end

function script.StopMoving()
	for i = 1, #wheels do
		StopSpin(wheels[i], x_axis, WHEEL_ACCEL)
	end
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
	-- use a weapon-specific turret if it exists
	if turrets[weaponID] then
		Turn(turrets[weaponID], y_axis, heading, TURRET_2_SPEED)
	else -- otherwise use main
		Turn(turret, y_axis, heading, TURRET_SPEED)
	end
	if mantlets[weaponID] then
		Turn(mantlets[weaponID], x_axis, -pitch, TURRET_SPEED)
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
	if turrets[weaponID] then
		WaitForTurn(turrets[weaponID], y_axis)
	else
		WaitForTurn(turret, y_axis) -- CL_Mars shouldn't really wait here for missiles
	end
	if mantlets[weaponID] then
		WaitForTurn(mantlets[weaponID], x_axis)
	end
	StartThread(RestoreAfterDelay)
	return true
end

function script.FireWeapon(weaponID)
	currHeatLevel = currHeatLevel + firingHeats[weaponID]
	SetUnitRulesParam(unitID, "heat", currHeatLevel)
	if barrels[weaponID] and barrelRecoils[weaponID] then
		Move(barrels[weaponID], z_axis, -barrelRecoils[weaponID], BARREL_SPEED)
		WaitForMove(barrels[weaponID], z_axis)
		Move(barrels[weaponID], z_axis, 0, 10)
	end
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
	return turret
end

function script.QueryWeapon(weaponID) 
	if missileWeaponIDs[weaponID] then
		return launchPoints[weaponID][currPoints[weaponID]]
	elseif weaponID == amsID then
		return turret
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
