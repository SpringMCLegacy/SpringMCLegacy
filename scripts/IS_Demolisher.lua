-- Test Tank Script

--defines
local body, turret, barrel1, barrel2 = piece ("body", "turret", "barrel1", "barrel2")
local trackr, trackl = piece ("trackr", "trackl")
local flare1, flare2 = piece ("flare1", "flare2")
local wheels = {}
local numWheels = 12
	for i = 1, numWheels do
		wheels[i] = piece ("wheel"..i)
	end
local rad = math.rad
local currLaunchPoint = 1

-- constants
local SIG_AIM1 = 2
local SIG_AIM2 = 4

local RESTORE_DELAY = Spring.UnitScript.GetLongestReloadTime(unitID) * 2

-- includes
include "smokeunit.lua"

--SFX defines
LARGE_MUZZLEFLASH = SFX.CEG+0

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
end

function script.AimWeapon1(heading, pitch)
	Signal(SIG_AIM1)
	SetSignalMask(SIG_AIM1)
	Turn(turret, y_axis, heading, rad(75))
	Turn(barrel1, x_axis, -pitch, rad(200))
	WaitForTurn(turret, y_axis)
	StartThread(RestoreAfterDelay)
	return true
end

function script.FireWeapon1()
	EmitSfx(flare1, LARGE_MUZZLEFLASH)
	Move(barrel1, z_axis, -5, 100)
	WaitForMove(barrel1, z_axis)
	Move(barrel1, z_axis, 0, 10)
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
	Turn(turret, y_axis, heading, rad(75))
	Turn(barrel2, x_axis, -pitch, rad(200))
	WaitForTurn(turret, y_axis)
	StartThread(RestoreAfterDelay)
	return true
end

function script.FireWeapon2()
	EmitSfx(flare2, LARGE_MUZZLEFLASH)
	Move(barrel2, z_axis, -5, 100)
	WaitForMove(barrel2, z_axis)
	Move(barrel2, z_axis, 0, 10)
end

function script.Shot2()
end

function script.AimFromWeapon2() 
	return turret 
end

function script.QueryWeapon2() 
	return flare2
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
