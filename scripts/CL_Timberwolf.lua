-- Test Mech Script
-- useful global stuff
local ud = UnitDefs[Spring.GetUnitDefID(unitID)] -- unitID is available automatically to all LUS
local weapons = ud.weapons
local deg, rad = math.deg, math.rad

--piece defines
local pelvis, torso = piece ("pelvis", "torso")
local rupperarm, rlowerarm, lupperarm, llowerarm = piece ("rupperarm", "rlowerarm", "lupperarm", "llowerarm")
local lupperleg, llowerleg, rupperleg, rlowerleg, rfronttoes, rbacktoe, lfronttoes, lbacktoe = piece ("lupperleg", "llowerleg", "rupperleg", "rlowerleg", "rfronttoes", "rbacktoe", "lfronttoes", "lbacktoe")
local flare1, flare2, flare3, flare4, flare5, flare6, flare7, flare8 = piece ("flare1", "flare2", "flare3", "flare4", "flare5", "flare6", "flare7", "flare8")

local missileWeaponIDs = {[9] = true, [10] = true}
 
local launchPoints = {}
local numPoints = {}
local currPoints = {}
 
--Turning/Movement Locals
local TORSO_SPEED = rad(125)
local ELEVATION_SPEED = rad(165)
local LEG_SPEED = rad(450)

for weaponID in pairs(missileWeaponIDs) do
        launchPoints[weaponID] = {}
        currPoints[weaponID] = 1
        numPoints[weaponID] = WeaponDefs[weapons[weaponID].weaponDef].salvoSize
        for i = 1, numPoints[weaponID] do
                launchPoints[weaponID][i] = piece("launchpoint_" .. weaponID .. "_" .. i)
        end
end
local currLaunchPoint = 1

-- constants
local SIG_AIM = 2
local walking = false
local RESTORE_DELAY = Spring.UnitScript.GetLongestReloadTime(unitID) * 2

-- includes
include "smokeunit.lua"

--SFX defines
MISSILE_MUZZLEFLASH = SFX.CEG+0
LASER_MUZZLEFLASH = SFX.CEG+1
MG_MUZZLEFLASH = SFX.CEG+2

local function MotionControl()
	while true do
		if walking then
			--Spring.Echo("Step ONE")
			--Left Leg--
			Turn(lupperleg, x_axis, rad(25), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(25), LEG_SPEED)
			Turn(lbacktoe, x_axis, rad(-60), LEG_SPEED)
			Turn(lfronttoes, x_axis, rad(-15), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(-25), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(15), LEG_SPEED)
			Turn(rbacktoe, x_axis, rad(-30), LEG_SPEED)
			Turn(rfronttoes, x_axis, rad(45), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lbacktoe, x_axis)
			WaitForTurn(lfronttoes, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rbacktoe, x_axis)
			WaitForTurn(rfronttoes, x_axis)
			Sleep(10)
			--Spring.Echo("Step TWO")
			--Left Leg--
			Turn(lupperleg, x_axis, rad(25), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(45), LEG_SPEED)
			Turn(lbacktoe, x_axis, rad(-75), LEG_SPEED)
			Turn(lfronttoes, x_axis, rad(-60), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(-45), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(0), LEG_SPEED)
			Turn(rbacktoe, x_axis, rad(-30), LEG_SPEED)
			Turn(rfronttoes, x_axis, rad(40), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lbacktoe, x_axis)
			WaitForTurn(lfronttoes, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rbacktoe, x_axis)
			WaitForTurn(rfronttoes, x_axis)
			Sleep(10)
			--Spring.Echo("Step THREE")
			--Left Leg--
			Turn(lupperleg, x_axis, rad(60), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(15), LEG_SPEED)
			Turn(lbacktoe, x_axis, rad(-45), LEG_SPEED)
			Turn(lfronttoes, x_axis, rad(0), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(-30), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(15), LEG_SPEED)
			Turn(rbacktoe, x_axis, rad(10), LEG_SPEED)
			Turn(rfronttoes, x_axis, rad(15), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lbacktoe, x_axis)
			WaitForTurn(lfronttoes, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rbacktoe, x_axis)
			WaitForTurn(rfronttoes, x_axis)
			Sleep(10)
			--Spring.Echo("Step FOUR")
			--Left Leg--
			Turn(lupperleg, x_axis, rad(-10), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(-15), LEG_SPEED)
			Turn(lbacktoe, x_axis, rad(-45), LEG_SPEED)
			Turn(lfronttoes, x_axis, rad(30), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(0), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(5), LEG_SPEED)
			Turn(rbacktoe, x_axis, rad(0), LEG_SPEED)
			Turn(rfronttoes, x_axis, rad(0), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lbacktoe, x_axis)
			WaitForTurn(lfronttoes, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rbacktoe, x_axis)
			WaitForTurn(rfronttoes, x_axis)
			Sleep(10)
			--Spring.Echo("Step FIVE")
			--Left Leg--
			Turn(lupperleg, x_axis, rad(-25), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(-15), LEG_SPEED)
			Turn(lbacktoe, x_axis, rad(-30), LEG_SPEED)
			Turn(lfronttoes, x_axis, rad(45), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(25), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(25), LEG_SPEED)
			Turn(rbacktoe, x_axis, rad(-60), LEG_SPEED)
			Turn(rfronttoes, x_axis, rad(-45), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lbacktoe, x_axis)
			WaitForTurn(lfronttoes, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rbacktoe, x_axis)
			WaitForTurn(rfronttoes, x_axis)
			Sleep(10)
			--Spring.Echo("Step SIX")
			--Left Leg--
			Turn(lupperleg, x_axis, rad(-45), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(0), LEG_SPEED)
			Turn(lbacktoe, x_axis, rad(-30), LEG_SPEED)
			Turn(lfronttoes, x_axis, rad(60), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(25), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(45), LEG_SPEED)
			Turn(rbacktoe, x_axis, rad(-75), LEG_SPEED)
			Turn(rfronttoes, x_axis, rad(-60), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lbacktoe, x_axis)
			WaitForTurn(lfronttoes, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rbacktoe, x_axis)
			WaitForTurn(rfronttoes, x_axis)
			Sleep(10)
			--Spring.Echo("Step SEVEN")
			--Left Leg--
			Turn(lupperleg, x_axis, rad(-30), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(15), LEG_SPEED)
			Turn(lbacktoe, x_axis, rad(10), LEG_SPEED)
			Turn(lfronttoes, x_axis, rad(15), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(45), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(15), LEG_SPEED)
			Turn(rbacktoe, x_axis, rad(-45), LEG_SPEED)
			Turn(rfronttoes, x_axis, rad(0), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lbacktoe, x_axis)
			WaitForTurn(lfronttoes, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rbacktoe, x_axis)
			WaitForTurn(rfronttoes, x_axis)
			Sleep(10)
			--Spring.Echo("Step EIGHT")
			--Left Leg--
			Turn(lupperleg, x_axis, rad(0), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(5), LEG_SPEED)
			Turn(lbacktoe, x_axis, rad(0), LEG_SPEED)
			Turn(lfronttoes, x_axis, rad(0), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(-10), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(-15), LEG_SPEED)
			Turn(rbacktoe, x_axis, rad(-45), LEG_SPEED)
			Turn(rfronttoes, x_axis, rad(30), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lbacktoe, x_axis)
			WaitForTurn(lfronttoes, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rbacktoe, x_axis)
			WaitForTurn(rfronttoes, x_axis)
			Sleep(10)
		else
			Turn(lupperleg, x_axis, rad(0), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(0), LEG_SPEED)
			Turn(lfronttoes, x_axis, rad(0), LEG_SPEED)
			Turn(lbacktoe, x_axis, rad(0), LEG_SPEED)
			Turn(rupperleg, x_axis, rad(0), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(0), LEG_SPEED)
			Turn(rfronttoes, x_axis, rad(0), LEG_SPEED)
			Turn(rbacktoe, x_axis, rad(0),LEG_SPEED)
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
	Turn(llowerarm, x_axis, 0, ELEVATION_SPEED)
	Turn(rlowerarm, x_axis, 0, ELEVATION_SPEED)
end

function script.AimWeapon(weaponID, heading, pitch)
	Signal(SIG_AIM ^ weaponID) -- 2 'to the power of' weapon ID
    SetSignalMask(SIG_AIM ^ weaponID)
		if weaponID == 1 then
			Turn(llowerarm, x_axis, -pitch, ELEVATION_SPEED)
		elseif weaponID == 6 then
			Turn(rlowerarm, x_axis, -pitch, ELEVATION_SPEED)
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
			EmitSfx(flare5, MG_MUZZLEFLASH)
			Sleep(100)
			EmitSfx(flare5, MG_MUZZLEFLASH)
			Sleep(100)
			EmitSfx(flare5, MG_MUZZLEFLASH)
			Sleep(100)
			EmitSfx(flare5, MG_MUZZLEFLASH)
			Sleep(100)
			EmitSfx(flare5, MG_MUZZLEFLASH)
			Sleep(100)
			EmitSfx(flare5, MG_MUZZLEFLASH)
		elseif weaponID == 6 then
			EmitSfx(flare6, MG_MUZZLEFLASH)
			Sleep(100)
			EmitSfx(flare6, MG_MUZZLEFLASH)
			Sleep(100)
			EmitSfx(flare6, MG_MUZZLEFLASH)
			Sleep(100)
			EmitSfx(flare6, MG_MUZZLEFLASH)
			Sleep(100)
			EmitSfx(flare6, MG_MUZZLEFLASH)
			Sleep(100)
			EmitSfx(flare6, MG_MUZZLEFLASH)
			Sleep(100)
		elseif weaponID == 7 then
			EmitSfx(flare7, LASER_MUZZLEFLASH)
		elseif weaponID == 8 then
			EmitSfx(flare8, LASER_MUZZLEFLASH)
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
	return torso
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
			return flare3
		elseif weaponID == 4 then
			return flare4
		elseif weaponID == 5 then
			return flare5
		elseif weaponID == 6 then
			return flare6
		elseif weaponID == 7 then
			return flare7
		elseif weaponID == 8 then
			return flare8
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
