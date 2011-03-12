-- Test Tank Script
-- useful global stuff
local ud = UnitDefs[Spring.GetUnitDefID(unitID)] -- unitID is available automatically to all LUS
local weapons = ud.weapons
local deg, rad = math.deg, math.rad
--piece defines
local body, turret, mantlet, barrel1, barrel2, hullbarrel, mg = piece ("body", "turret", "mantlet", "barrel1", "barrel2", "hullbarrel", "mg")
local trackr, trackl = piece ("trackr", "trackl")
local flare1, flare2, hullflare, mgflare1, mgflare2 = piece ("flare1", "flare2", "hullflare", "mgflare1", "mgflare2")

--Turning/Movement Locals
local TURRET_SPEED = rad(50)
local ELEVATION_SPEED = rad(100)
local ELEVATION_SPEED_FAST = rad(150)
local CANNON_RECOIL_DISTANCE = -5
local CANNON_RECOIL_SPEED = 100
local WHEEL_SPEED = rad(50)
local WHEEL_ACCELERATION = rad(100)

local missileWeaponIDs = {[4] = true, [5] = true, [6] = true}
 
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
local numWheels = 16
	for i = 1, numWheels do
		wheels[i] = piece ("wheel"..i)
	end

local currLaunchPoint = 1

-- constants
local SIG_AIM = 2

local RESTORE_DELAY = Spring.UnitScript.GetLongestReloadTime(unitID) * 2

-- includes
include "smokeunit.lua"

--SFX defines
GAUSS_MUZZLEFLASH = SFX.CEG+0
MISSILE_MUZZLEFLASH = SFX.CEG+1
AC10_MUZZLEFLASH = SFX.CEG+2
LASER_MUZZLEFLASH = SFX.CEG+3
MG_MUZZLEFLASH = SFX.CEG+4

function script.Create()
	StartThread(SmokeUnit, {body, turret})
end

local function SpinWheels(moving)
	if moving then
		for i = 1, numWheels do
			Spin(wheels[i], x_axis, WHEEL_ACCELERATION, WHEEL_SPEED)
		end
	else
		for i = 1, numWheels do
			StopSpin(wheels[i], x_axis, WHEEL_SPEED)
		end
	end	
end

function script.StartMoving()
	SpinWheels(true)
end

function script.StopMoving()
	SpinWheels(false)
end

local function RestoreAfterDelay(unitID)
	Sleep(RESTORE_DELAY)
	Turn(turret, y_axis, 0, TURRET_SPEED)
	Turn(mantlet, x_axis, 0, ELEVATION_SPEED)
	Turn(hullbarrel, y_axis, 0, TURRET_SPEED)
	Turn(hullbarrel, x_axis, 0, ELEVATION_SPEED)
	Turn(barrel2, x_axis, 0, ELEVATION_SPEED)
	Turn(mg, x_axis, 0, ELEVATION_SPEED_FAST)
end

function script.AimWeapon(weaponID, heading, pitch)
	Signal(SIG_AIM ^ weaponID) -- 2 'to the power of' weapon ID
    SetSignalMask(SIG_AIM ^ weaponID)
		--if missileWeaponIDs[weaponID] then
		--	Turn(launchPoints[weaponID][i], x_axis, -pitch, rad(200))
		if weaponID == 1 then
			Turn(mantlet, x_axis, -pitch, ELEVATION_SPEED)
			Turn(turret, y_axis, heading, TURRET_SPEED)
			WaitForTurn(turret, y_axis)
		elseif weaponID == 2 then
			Turn(barrel2, x_axis, -pitch, ELEVATION_SPEED)
			Turn(turret, y_axis, heading, TURRET_SPEED)
			WaitForTurn(turret, y_axis)
		elseif weaponID == 3 then
			Turn(hullbarrel, y_axis, heading, ELEVATION_SPEED)
			Turn(hullbarrel, x_axis, -pitch, TURRET_SPEED)
			WaitForTurn(hullbarrel, y_axis)
		elseif weaponID == 7 then
			Turn(mg, x_axis, -pitch, ELEVATION_SPEED_FAST)
			Turn(turret, y_axis, heading, TURRET_SPEED)
			WaitForTurn(turret, y_axis)
		elseif weaponID == 8 then
			Turn(mg, x_axis, -pitch, ELEVATION_SPEED_FAST)
			Turn(turret, y_axis, heading, TURRET_SPEED)
			WaitForTurn(turret, y_axis)
		end
	StartThread(RestoreAfterDelay)
	return true
end

function script.FireWeapon(weaponID)
		if weaponID == 1 then
			EmitSfx(flare1, GAUSS_MUZZLEFLASH)
			Move(barrel1, z_axis, CANNON_RECOIL_DISTANCE, CANNON_RECOIL_SPEED)
			WaitForMove(barrel1, z_axis)
			Move(barrel1, z_axis, 0, 10)
		elseif weaponID == 2 then
			EmitSfx(flare2, LASER_MUZZLEFLASH)
		elseif weaponID == 3 then
			EmitSfx(hullflare, AC10_MUZZLEFLASH)
			Move(hullbarrel, z_axis, CANNON_RECOIL_DISTANCE, CANNON_RECOIL_SPEED)
			WaitForMove(hullbarrel, z_axis)
			Move(hullbarrel, z_axis, 0, 10)
		elseif weaponID == 7 then
			EmitSfx(mgflare1, MG_MUZZLEFLASH)
			Sleep(100)
			EmitSfx(mgflare1, MG_MUZZLEFLASH)
			Sleep(100)
			EmitSfx(mgflare1, MG_MUZZLEFLASH)
			Sleep(100)
			EmitSfx(mgflare1, MG_MUZZLEFLASH)
			Sleep(100)
			EmitSfx(mgflare1, MG_MUZZLEFLASH)
			Sleep(100)
			EmitSfx(mgflare1, MG_MUZZLEFLASH)
		elseif weaponID == 8 then
			EmitSfx(mgflare2, MG_MUZZLEFLASH)
			Sleep(100)
			EmitSfx(mgflare2, MG_MUZZLEFLASH)
			Sleep(100)
			EmitSfx(mgflare2, MG_MUZZLEFLASH)
			Sleep(100)
			EmitSfx(mgflare2, MG_MUZZLEFLASH)
			Sleep(100)
			EmitSfx(mgflare2, MG_MUZZLEFLASH)
			Sleep(100)
			EmitSfx(mgflare2, MG_MUZZLEFLASH)
		end
end

function script.Shot(weaponID)
	if missileWeaponIDs[weaponID] then
		EmitSfx(launchPoints[weaponID][currPoints[weaponID]], MISSILE_MUZZLEFLASH)
        currPoints[weaponID] = currPoints[weaponID] + 1
        if currPoints[weaponID] > numPoints[weaponID] then 
                currPoints[weaponID] = 1
        end
	end		
end

function script.AimFromWeapon(weaponID)
	if missileWeaponIDs[weaponID] then
		return body
	elseif weaponID == 3 then
		return hullbarrel
	end
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
		elseif weaponID == 3 then
			return hullflare
		elseif weaponID == 7 then
			return mgflare1
		elseif weaponID == 8 then
			return mgflare2
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
