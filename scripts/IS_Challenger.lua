-- Test Tank Script
-- useful global stuff
local ud = UnitDefs[Spring.GetUnitDefID(unitID)] -- unitID is available automatically to all LUS
local weapons = ud.weapons
--piece defines
local body, turret, barrel1, barrel2, laser1, laser2, lamsturret, lams = piece ("body", "turret", "barrel1", "barrel2", "laser1", "laser2", "lamsturret", "lams")
local trackr, trackl = piece ("trackr", "trackl")
local flare1, flare2, laserflare1, laserflare2, lamsflare1, lamsflare2 = piece ("flare1", "flare2", "laserflare1", "laserflare2", "lamsflare1", "lamsflare2")

local missileWeaponIDs = {[3] = true} 
 
local launchPoints = {}
local numPoints = {}
local currPoints = {}
 
for weaponID in pairs(missileWeaponIDs) do
        launchPoints[weaponID] = {}
        currPoints[weaponID] = 1
        numPoints[weaponID] = WeaponDefs[weapons[weaponID].weaponDef].salvoSize
        for i = 1, numPoints[weaponID] do
                launchPoints[weaponID][i] = piece("launchpoint_" .. weaponID .. "_" .. i)
        end
end

local wheels = {}
local numWheels = 12
	for i = 1, numWheels do
		wheels[i] = piece ("wheel"..i)
	end
local rad = math.rad
local currLaunchPoint = 1

-- constants
local SIG_AIM = 2

local RESTORE_DELAY = Spring.UnitScript.GetLongestReloadTime(unitID) * 2

-- includes
include "smokeunit.lua"

--SFX defines
SMALL_MUZZLEFLASH = SFX.CEG+0
MEDIUM_MUZZLEFLASH = SFX.CEG+1
MG_MUZZLEFLASH = SFX.CEG+2

function script.Create()
	StartThread(SmokeUnit, {body, turret})
end

local function SpinWheels(moving)
	if moving then
		for i = 1, numWheels do
			Spin(wheels[i], x_axis, rad(200), rad(100))
		end
	else
		for i = 1, numWheels do
			StopSpin(wheels[i], x_axis, rad(100))
		end
	end	
end

function script.StartMoving()
	SpinWheels(true)
end

function script.StopMoving()
	SpinWheels(false)
end

function script.Activate()
	Spring.SetUnitStealth(unitID, false)
end

function script.Deactivate()
	Spring.SetUnitStealth(unitID, true)
end

local function RestoreAfterDelay(unitID)
	Sleep(RESTORE_DELAY)
	Turn(turret, y_axis, 0, math.rad(50))
	Turn(barrel1, x_axis, 0, math.rad(100))
	Turn(barrel2, x_axis, 0, math.rad(100))
	Turn(laser1, x_axis, 0, math.rad(100))
	Turn(laser2, x_axis, 0, math.rad(100))
--	Turn(lamsturret, y_axis, 0, math.rad(100))
--	Turn(lams, x_axis, 0, math.rad(100))
end

function script.AimWeapon(weaponID, heading, pitch)
	Signal(SIG_AIM ^ weaponID) -- 2 'to the power of' weapon ID
    SetSignalMask(SIG_AIM ^ weaponID)
		if weaponID == 1 then
			Turn(barrel1, x_axis, -pitch, rad(200))
			elseif weaponID == 2 then
				Turn(barrel2, x_axis, -pitch, rad(200))
			elseif weaponID == 4 then
				Turn(laser1, x_axis, -pitch, rad(200))
			elseif weaponID == 5 then
				Turn(laser2, x_axis, -pitch, rad(200))
		end
	Turn(turret, y_axis, heading, rad(75))
	WaitForTurn(turret, y_axis)
	StartThread(RestoreAfterDelay)
	return true
end

function script.FireWeapon(weaponID)
		if weaponID == 1 then
				Move(barrel1, z_axis, -5, 100)
				WaitForMove(barrel1, z_axis)
				Move(barrel1, z_axis, 0, 10)
		elseif weaponID == 2 then
				EmitSfx(flare2, MEDIUM_MUZZLEFLASH)
				Move(barrel2, z_axis, -5, 100)
				WaitForMove(barrel2, z_axis)
				Move(barrel2, z_axis, 0, 10)
		elseif weaponID == 4 then
				EmitSfx(laserflare1, MG_MUZZLEFLASH)
		elseif weaponID == 5 then
				EmitSfx(laserflare2, MG_MUZZLEFLASH)
		end
end

function script.Shot(weaponID)
	if missileWeaponIDs[weaponID] then
		EmitSfx(launchPoints[weaponID][currPoints[weaponID]], SMALL_MUZZLEFLASH)
        currPoints[weaponID] = currPoints[weaponID] + 1
        if currPoints[weaponID] > numPoints[weaponID] then 
                currPoints[weaponID] = 1
        end
	end		
end

function script.AimFromWeapon(weaponID) 
	return turret 
end

function script.QueryWeapon(weaponID) 
	if missileWeaponIDs[weaponID] then
		return launchPoints[weaponID][currPoints[weaponID]]
	else
		if weaponID == 1 then
			return flare1
		elseif weaponID == 2 then
			return flare2
		elseif weaponID == 4 then
			return laserflare1
		elseif weaponID == 5 then
			return laserflare2
		end
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
end
