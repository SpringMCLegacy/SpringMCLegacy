-- Test Tank Script

--defines
local body, turret, guns = piece ("body", "turret", "guns")
local floatr, floatl = piece ("floatr", "floatl")
local flare1, flare2 = piece ("flare1", "flare2")
local smokePieces = {body, turret}
local rad = math.rad
-- constants
local SIG_AIM1 = 2
local SIG_AIM2 = 4
local RESTORE_DELAY = Spring.UnitScript.GetLongestReloadTime(unitID) * 2

-- includes
include "smokeunit.lua"

--SFX defines
MG_MUZZLEFLASH = SFX.CEG+0

function script.Create()
	StartThread(SmokeUnit())
end

function script.StartMoving()
end

function script.StopMoving()
end

local function RestoreAfterDelay(unitID)
	Sleep(RESTORE_DELAY)
	Turn(turret, y_axis, 0, math.rad(50))
	Turn(guns, x_axis, 0, math.rad(100))
end

function script.AimWeapon1(heading, pitch)
	Signal(SIG_AIM1)
	SetSignalMask(SIG_AIM1)
	Turn(turret, y_axis, heading, rad(75))
	Turn(guns, x_axis, -pitch, rad(200))
	WaitForTurn(turret, y_axis)
	StartThread(RestoreAfterDelay)
	return true
end

function script.FireWeapon1()
	EmitSfx(flare1, MG_MUZZLEFLASH)
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
	Turn(guns, x_axis, -pitch, rad(200))
	WaitForTurn(turret, y_axis)
	StartThread(RestoreAfterDelay)
	return true
end

function script.FireWeapon2()
	EmitSfx(flare2, MG_MUZZLEFLASH)
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
