-- Test Mech Script
-- useful global stuff
local ud = UnitDefs[Spring.GetUnitDefID(unitID)] -- unitID is available automatically to all LUS
local weapons = ud.weapons
local deg, rad = math.deg, math.rad

--piece defines
local pelvis, torso, barrel = piece ("pelvis", "torso", "barrel")
local lupperarm, llowerarm, rupperarm, rlowerarm = piece ("lupperarm", "llowerarm", "rupperarm", "rlowerarm")
local lupperleg, llowerleg, rupperleg, rlowerleg, rfronttoes, rbacktoes, lfronttoes, lbacktoes = piece ("lupperleg", "llowerleg", "rupperleg", "rlowerleg", "rfronttoes", "rbacktoes", "lfronttoes", "lbacktoes")
local flare1, flare2, flare3, flare4, flare5 = piece ("flare1", "flare2", "flare3", "flare4", "flare5")
 
--Turning/Movement Locals
local TORSO_SPEED = rad(200)
local ELEVATION_SPEED = rad(200)
local LEG_SPEED = rad(1000)

-- constants
local SIG_AIM = 2
local walking = false
local RESTORE_DELAY = Spring.UnitScript.GetLongestReloadTime(unitID) * 2

-- includes
include "smokeunit.lua"

--SFX defines
LASER_MUZZLEFLASH = SFX.CEG+0

local function MotionControl()
	while true do
		if walking then
			--Spring.Echo("Step ONE")
			--Left Leg--
			Turn(lupperleg, x_axis, rad(25), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(25), LEG_SPEED)
			Turn(lbacktoes, x_axis, rad(-60), LEG_SPEED)
			Turn(lfronttoes, x_axis, rad(-15), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(-25), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(15), LEG_SPEED)
			Turn(rbacktoes, x_axis, rad(-30), LEG_SPEED)
			Turn(rfronttoes, x_axis, rad(45), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lbacktoes, x_axis)
			WaitForTurn(lfronttoes, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rbacktoes, x_axis)
			WaitForTurn(rfronttoes, x_axis)
			Sleep(10)
			--Spring.Echo("Step TWO")
			--Left Leg--
			Turn(lupperleg, x_axis, rad(25), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(45), LEG_SPEED)
			Turn(lbacktoes, x_axis, rad(-75), LEG_SPEED)
			Turn(lfronttoes, x_axis, rad(-60), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(-45), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(0), LEG_SPEED)
			Turn(rbacktoes, x_axis, rad(-30), LEG_SPEED)
			Turn(rfronttoes, x_axis, rad(40), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lbacktoes, x_axis)
			WaitForTurn(lfronttoes, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rbacktoes, x_axis)
			WaitForTurn(rfronttoes, x_axis)
			Sleep(10)
			--Spring.Echo("Step THREE")
			--Left Leg--
			Turn(lupperleg, x_axis, rad(60), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(15), LEG_SPEED)
			Turn(lbacktoes, x_axis, rad(-45), LEG_SPEED)
			Turn(lfronttoes, x_axis, rad(0), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(-30), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(15), LEG_SPEED)
			Turn(rbacktoes, x_axis, rad(10), LEG_SPEED)
			Turn(rfronttoes, x_axis, rad(15), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lbacktoes, x_axis)
			WaitForTurn(lfronttoes, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rbacktoes, x_axis)
			WaitForTurn(rfronttoes, x_axis)
			Sleep(10)
			--Spring.Echo("Step FOUR")
			--Left Leg--
			Turn(lupperleg, x_axis, rad(-10), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(-15), LEG_SPEED)
			Turn(lbacktoes, x_axis, rad(-45), LEG_SPEED)
			Turn(lfronttoes, x_axis, rad(30), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(0), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(5), LEG_SPEED)
			Turn(rbacktoes, x_axis, rad(0), LEG_SPEED)
			Turn(rfronttoes, x_axis, rad(0), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lbacktoes, x_axis)
			WaitForTurn(lfronttoes, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rbacktoes, x_axis)
			WaitForTurn(rfronttoes, x_axis)
			Sleep(10)
			--Spring.Echo("Step FIVE")
			--Left Leg--
			Turn(lupperleg, x_axis, rad(-25), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(-15), LEG_SPEED)
			Turn(lbacktoes, x_axis, rad(-30), LEG_SPEED)
			Turn(lfronttoes, x_axis, rad(45), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(25), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(25), LEG_SPEED)
			Turn(rbacktoes, x_axis, rad(-60), LEG_SPEED)
			Turn(rfronttoes, x_axis, rad(-45), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lbacktoes, x_axis)
			WaitForTurn(lfronttoes, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rbacktoes, x_axis)
			WaitForTurn(rfronttoes, x_axis)
			Sleep(10)
			--Spring.Echo("Step SIX")
			--Left Leg--
			Turn(lupperleg, x_axis, rad(-45), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(0), LEG_SPEED)
			Turn(lbacktoes, x_axis, rad(-30), LEG_SPEED)
			Turn(lfronttoes, x_axis, rad(60), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(25), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(45), LEG_SPEED)
			Turn(rbacktoes, x_axis, rad(-75), LEG_SPEED)
			Turn(rfronttoes, x_axis, rad(-60), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lbacktoes, x_axis)
			WaitForTurn(lfronttoes, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rbacktoes, x_axis)
			WaitForTurn(rfronttoes, x_axis)
			Sleep(10)
			--Spring.Echo("Step SEVEN")
			--Left Leg--
			Turn(lupperleg, x_axis, rad(-30), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(15), LEG_SPEED)
			Turn(lbacktoes, x_axis, rad(10), LEG_SPEED)
			Turn(lfronttoes, x_axis, rad(15), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(45), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(15), LEG_SPEED)
			Turn(rbacktoes, x_axis, rad(-45), LEG_SPEED)
			Turn(rfronttoes, x_axis, rad(0), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lbacktoes, x_axis)
			WaitForTurn(lfronttoes, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rbacktoes, x_axis)
			WaitForTurn(rfronttoes, x_axis)
			Sleep(10)
			--Spring.Echo("Step EIGHT")
			--Left Leg--
			Turn(lupperleg, x_axis, rad(0), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(5), LEG_SPEED)
			Turn(lbacktoes, x_axis, rad(0), LEG_SPEED)
			Turn(lfronttoes, x_axis, rad(0), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(-10), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(-15), LEG_SPEED)
			Turn(rbacktoes, x_axis, rad(-45), LEG_SPEED)
			Turn(rfronttoes, x_axis, rad(30), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lbacktoes, x_axis)
			WaitForTurn(lfronttoes, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rbacktoes, x_axis)
			WaitForTurn(rfronttoes, x_axis)
			Sleep(10)
		else
			Turn(lupperleg, x_axis, rad(0), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(0), LEG_SPEED)
			Turn(lfronttoes, x_axis, rad(0), LEG_SPEED)
			Turn(lbacktoes, x_axis, rad(0), LEG_SPEED)
			Turn(rupperleg, x_axis, rad(0), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(0), LEG_SPEED)
			Turn(rfronttoes, x_axis, rad(0), LEG_SPEED)
			Turn(rbacktoes, x_axis, rad(0),LEG_SPEED)
			Sleep(100)
		end
	end
end


--local function StopWalk()
--	Turn(lupperleg, x_axis, 0, rad(200))
--	Turn(rupperleg, x_axis, 0, rad(200))
--end

function script.Create()
	StartThread(SmokeUnit, {pelvis, torso})
	StartThread(MotionControl)
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

local function RestoreAfterDelay(unitID)
	Sleep(RESTORE_DELAY)
	Turn(torso, y_axis, 0, TORSO_SPEED)
	Turn(barrel, x_axis, 0, ELEVATION_SPEED)
	Turn(llowerarm, x_axis, 0, ELEVATION_SPEED)
	Turn(rlowerarm, x_axis, 0, ELEVATION_SPEED)
end

function script.AimWeapon(weaponID, heading, pitch)
	Signal(SIG_AIM ^ weaponID) -- 2 'to the power of' weapon ID
    SetSignalMask(SIG_AIM ^ weaponID)
		if weaponID == 1 then
			Turn(barrel, x_axis, -pitch, ELEVATION_SPEED)
		elseif weaponID == 2 then
			Turn(llowerarm, x_axis, -pitch, rad(150))
		elseif weaponID == 4 then
			Turn(rlowerarm, x_axis, -pitch, rad(150))
		end
	Turn(torso, y_axis, heading, TORSO_SPEED)
	WaitForTurn(torso, y_axis)
	StartThread(RestoreAfterDelay)
	return true
end

function script.FireWeapon(weaponID)
		if weaponID == 1 then
			EmitSfx(flare1, LASER_MUZZLEFLASH)
		elseif weaponID == 2 then
			EmitSfx(flare2, LASER_MUZZLEFLASH)
		elseif weaponID == 3 then
			EmitSfx(flare3, LASER_MUZZLEFLASH)
		elseif weaponID == 4 then
			EmitSfx(flare4, LASER_MUZZLEFLASH)
		elseif weaponID == 5 then
			EmitSfx(flare5, LASER_MUZZLEFLASH)
		end
end

function script.Shot(weaponID)
end

function script.AimFromWeapon(weaponID) 
	return torso
end

function script.QueryWeapon(weaponID) 
	if weaponID == 1 then
		return flare1
	elseif weaponID == 2 then
		return flare2
	elseif weaponID == 3 then
		return flare3
	elseif weaponID == 4 then
		return flare4
	elseif weaponID == 5 then
		return flare5
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
