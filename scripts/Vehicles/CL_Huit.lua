-- Test Tank Script
local deg, rad = math.deg, math.rad
--defines
local body, turret, launcher1, launcher2, lasers = piece ("body", "turret", "launcher1", "launcher2", "lasers")
local trackr, trackl = piece ("trackr", "trackl")
local flare1, flare2, laserflare1, laserflare2 = piece ("flare1", "flare2", "laserflare1", "laserflare2")
local wheels = {}
local numWheels = 10
	for i = 1, numWheels do
		wheels[i] = piece ("wheel"..i)
	end

--Turning/Movement Locals
local TURRET_SPEED = rad(50)
local ELEVATION_SPEED = rad(75)
local ELEVATION_SPEED_FAST = rad(150)
local CANNON_RECOIL_DISTANCE = -5
local CANNON_RECOIL_SPEED = 100
local WHEEL_SPEED = rad(50)
local WHEEL_ACCELERATION = rad(100)

-- constants
local SIG_AIM1 = 2
local SIG_AIM2 = 4
local SIG_AIM3 = 8
local SIG_AIM4 = 16

local RESTORE_DELAY = Spring.UnitScript.GetLongestReloadTime(unitID) * 2

-- includes
include "smokeunit.lua"

--SFX defines
ARROW_MUZZLEFLASH = SFX.CEG+0
LASER_MUZZLEFLASH = SFX.CEG+1

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

function script.Activate()
	Spring.SetUnitStealth(unitID, false)
end

function script.Deactivate()
	Spring.SetUnitStealth(unitID, true)
end

local function RestoreAfterDelay(unitID)
	Sleep(RESTORE_DELAY)
	Turn(turret, y_axis, 0, TURRET_SPEED)
	Turn(launcher1, x_axis, 0, ELEVATION_SPEED)
	Turn(launcher2, x_axis, 0, ELEVATION_SPEED)
	Turn(lasers, x_axis, 0, ELEVATION_SPEED_FAST)
end

function script.AimWeapon1(heading, pitch)
	Signal(SIG_AIM1)
	SetSignalMask(SIG_AIM1)
	Turn(turret, y_axis, heading, TURRET_SPEED)
	Turn(launcher1, x_axis, -pitch, ELEVATION_SPEED)
	WaitForTurn(turret, y_axis)
	StartThread(RestoreAfterDelay)
	return true
end

function script.FireWeapon1()
	EmitSfx(flare1, ARROW_MUZZLEFLASH)
end

function script.Shot1()
end

function script.AimFromWeapon1() 
	return turret 
end

function script.QueryWeapon1() 
	return flare1
end
	
function script.AimWeapon2(heading, pitch)
	Signal(SIG_AIM2)
	SetSignalMask(SIG_AIM2)
	Turn(turret, y_axis, heading, TURRET_SPEED)
	Turn(launcher2, x_axis, -pitch, ELEVATION_SPEED)
	WaitForTurn(turret, y_axis)
	StartThread(RestoreAfterDelay)
	return true
end

function script.FireWeapon2()
	EmitSfx(flare2, ARROW_MUZZLEFLASH)
end

function script.Shot2()
end

function script.AimFromWeapon2() 
	return turret 
end

function script.QueryWeapon2() 
	return flare2
end

function script.AimWeapon3(heading, pitch)
	Signal(SIG_AIM3)
	SetSignalMask(SIG_AIM3)
	Turn(turret, y_axis, heading, TURRET_SPEED)
	Turn(lasers, x_axis, -pitch, ELEVATION_SPEED_FAST)
	WaitForTurn(turret, y_axis)
	StartThread(RestoreAfterDelay)
	return true
end

function script.FireWeapon3()
	EmitSfx(laserflare1, LASER_MUZZLEFLASH)
end

function script.Shot3()
end

function script.AimFromWeapon3() 
	return turret 
end

function script.QueryWeapon3() 
	return laserflare1
end

function script.AimWeapon4(heading, pitch)
	Signal(SIG_AIM3)
	SetSignalMask(SIG_AIM3)
	Turn(turret, y_axis, heading, TURRET_SPEED)
	Turn(lasers, x_axis, -pitch, ELEVATION_SPEED_FAST)
	WaitForTurn(turret, y_axis)
	StartThread(RestoreAfterDelay)
	return true
end

function script.FireWeapon4()
	EmitSfx(laserflare2, LASER_MUZZLEFLASH)
end

function script.Shot4()
end

function script.AimFromWeapon4() 
	return turret 
end

function script.QueryWeapon4() 
	return laserflare2
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
