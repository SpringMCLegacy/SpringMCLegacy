-- Test Tank Script

--defines
local body, mantlet, barrel, laserturret, lasermantlet, lasers = piece ("body", "mantlet", "barrel", "laserturret", "lasermantlet", "lasers")
local trackr, trackl = piece ("trackr", "trackl")
local flare, laserflare1, laserflare2 = piece ("flare", "laserflare1", "laserflare2")
local smokePieces = {body}
local wheels = {}
local numWheels = 8
	for i = 1, numWheels do
		wheels[i] = piece ("wheel"..i)
	end
local rad = math.rad
-- constants
local SIG_MOVE = 1
local SIG_AIM1 = 2
local SIG_AIM2 = 4
local SIG_AIM3 = 8
local RESTORE_DELAY = Spring.UnitScript.GetLongestReloadTime(unitID) * 2

-- includes
include "smokeunit.lua"

--SFX defines
XXLARGE_MUZZLEFLASH = SFX.CEG+0

function script.Create()
	StartThread(SmokeUnit())
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
	Signal(SIG_MOVE)
end

function script.StopMoving()
	SpinWheels(false)
	Signal(SIG_MOVE)
end

local function RestoreAfterDelay(unitID)
	Sleep(RESTORE_DELAY)
	Turn(laserturret, y_axis, 0, math.rad(50))
	Turn(lasermantlet, y_axis, 0, math.rad(100))
	Turn(mantlet, x_axis, 0, math.rad(100))

end

function script.AimWeapon1(heading, pitch)
	Signal(SIG_AIM1)
	SetSignalMask(SIG_AIM1)
	Turn(mantlet, y_axis, heading, rad(50))
	Turn(mantlet, x_axis, -pitch, rad(50))
	WaitForTurn(mantlet, y_axis)
	WaitForTurn(mantlet, x_axis)
	StartThread(RestoreAfterDelay)
	return true
end

function script.FireWeapon1()
	EmitSfx(flare, XXLARGE_MUZZLEFLASH)
	Move(barrel, z_axis, -4, 75)
	WaitForMove(barrel, z_axis)
	Move(barrel, z_axis, 0, 5)
end

function script.AimFromWeapon1() 
	return mantlet
end

function script.QueryWeapon1() 
	return flare
end
	
	function script.AimWeapon2(heading, pitch)
	Signal(SIG_AIM2)
	SetSignalMask(SIG_AIM2)
	Turn(laserturret, y_axis, heading, rad(200))
	Turn(lasermantlet, x_axis, -pitch, rad(200))
	WaitForTurn(laserturret, y_axis)
	StartThread(RestoreAfterDelay)
	return true
end

function script.FireWeapon2()
end

function script.AimFromWeapon2() 
	return laserturret 
end

function script.QueryWeapon2() 
	return laserflare1
end

function script.AimWeapon3(heading, pitch)
	Signal(SIG_AIM3)
	SetSignalMask(SIG_AIM3)
	Turn(laserturret, y_axis, heading, rad(200))
	Turn(lasermantlet, x_axis, -pitch, rad(200))
	WaitForTurn(laserturret, y_axis)
	StartThread(RestoreAfterDelay)
	return true
end

function script.FireWeapon3()
end

function script.Shot3()
end

function script.AimFromWeapon3() 
	return laserturret 
end

function script.QueryWeapon3() 
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
