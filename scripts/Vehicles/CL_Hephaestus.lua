-- Test Tank Script
local deg, rad = math.deg, math.rad
--defines
local body, turret, guns = piece ("body", "turret", "guns")
local floatr, floatl = piece ("floatr", "floatl")
local flare1, flare2, flare3 = piece ("flare1", "flare2", "flare3")

--Turning/Movement Locals
local TURRET_SPEED = rad(75)
local ELEVATION_SPEED = rad(200)
local ELEVATION_SPEED_FAST = rad(200)
local CANNON_RECOIL_DISTANCE = -5
local CANNON_RECOIL_SPEED = 100
local WHEEL_SPEED = rad(100)
local WHEEL_ACCELERATION = rad(200)

-- constants
local SIG_AIM1 = 2
local SIG_AIM2 = 4
local RESTORE_DELAY = Spring.UnitScript.GetLongestReloadTime(unitID) * 2

-- includes
include "smokeunit.lua"

--SFX defines
MISSILE_MUZZLEFLASH = SFX.CEG+0
LASER_MUZZLEFLASH = SFX.CEG+1

function script.Create()
	StartThread(SmokeUnit, {body, turret})
end

function script.StartMoving()
end

function script.StopMoving()
end

local function RestoreAfterDelay(unitID)
	Sleep(RESTORE_DELAY)
	Turn(turret, y_axis, 0, TURRET_SPEED)
	Turn(guns, x_axis, 0, ELEVATION_SPEED)
end

function script.AimWeapon1(heading, pitch)
	Signal(SIG_AIM1)
	SetSignalMask(SIG_AIM1)
	Turn(turret, y_axis, heading, TURRET_SPEED)
	Turn(guns, x_axis, -pitch, ELEVATION_SPEED)
	WaitForTurn(turret, y_axis)
	StartThread(RestoreAfterDelay)
	return true
end

function script.FireWeapon1()
	EmitSfx(flare1, LASER_MUZZLEFLASH)
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
	Turn(guns, x_axis, -pitch, ELEVATION_SPEED)
	WaitForTurn(turret, y_axis)
	StartThread(RestoreAfterDelay)
	return true
end

function script.FireWeapon2()
	EmitSfx(flare2, LASER_MUZZLEFLASH)
end

function script.AimFromWeapon2() 
	return turret 
end

function script.QueryWeapon2() 
	return flare2
end

function script.AimWeapon3(heading, pitch)
	Signal(SIG_AIM1)
	SetSignalMask(SIG_AIM1)
	Turn(turret, y_axis, heading, TURRET_SPEED)
	WaitForTurn(turret, y_axis)
	StartThread(RestoreAfterDelay)
	return true
end

function script.FireWeapon3()
	EmitSfx(flare3, MISSILE_MUZZLEFLASH)
end

function script.AimFromWeapon3() 
	return turret 
end

function script.QueryWeapon3() 
	return flare3
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
