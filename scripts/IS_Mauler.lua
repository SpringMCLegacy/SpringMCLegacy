-- Test Mech Script
-- useful global stuff
local ud = UnitDefs[Spring.GetUnitDefID(unitID)] -- unitID is available automatically to all LUS
local weapons = ud.weapons
local deg, rad = math.deg, math.rad

--piece defines
local pelvis, torso = piece ("pelvis", "torso")
local mantlet1, barrel1, mantlet2, barrel2, mantlet3, barrel3, mantlet4, barrel4 = piece ("mantlet1", "barrel1", "mantlet2", "barrel2", "mantlet3", "barrel3", "mantlet4", "barrel4")
local rupperarm, rlowerarm, lupperarm, llowerarm = piece ("rupperarm", "rlowerarm", "lupperarm", "llowerarm")
local lupperleg, llowerleg, rupperleg, rlowerleg, rfoot, lfoot = piece ("lupperleg", "llowerleg", "rupperleg", "rlowerleg", "rfoot", "lfoot")
local flare1, flare2, acflare1, acflare2, acflare3, acflare4 = piece ("flare1", "flare2", "acflare1", "acflare2", "acflare3", "acflare4")

local missileWeaponIDs = {[3] = true, [4] = true }
 
local launchPoints = {}
local numPoints = {}
local currPoints = {}
 
--Turning/Movement Locals
local TORSO_SPEED = rad(100)
local ELEVATION_SPEED = rad(150)
local LEG_SPEED = rad(350)

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
MEDIUM_MUZZLEFLASH = SFX.CEG+0
XSMALL_MUZZLEFLASH = SFX.CEG+1
MG_MUZZLEFLASH = SFX.CEG+2

local function MotionControl()
	while true do
		if walking then
			--Spring.Echo("Step ONE")
			--Left Leg--
			Turn(lupperleg, x_axis, rad(25), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(25), LEG_SPEED)
			Turn(lfoot, x_axis, rad(-15), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(-25), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(15), LEG_SPEED)
			Turn(rfoot, x_axis, rad(45), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lfoot, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rfoot, x_axis)
			Sleep(10)
			--Spring.Echo("Step TWO")
			--Left Leg--
			Turn(lupperleg, x_axis, rad(25), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(45), LEG_SPEED)
			Turn(lfoot, x_axis, rad(-60), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(-45), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(0), LEG_SPEED)
			Turn(rfoot, x_axis, rad(40), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lfoot, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rfoot, x_axis)
			Sleep(10)
			--Spring.Echo("Step THREE")
			--Left Leg--
			Turn(lupperleg, x_axis, rad(60), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(15), LEG_SPEED)
			Turn(lfoot, x_axis, rad(0), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(-30), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(15), LEG_SPEED)
			Turn(rfoot, x_axis, rad(15), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lfoot, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rfoot, x_axis)
			Sleep(10)
			--Spring.Echo("Step FOUR")
			--Left Leg--
			Turn(lupperleg, x_axis, rad(-10), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(-15), LEG_SPEED)
			Turn(lfoot, x_axis, rad(30), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(0), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(5), LEG_SPEED)
			Turn(rfoot, x_axis, rad(0), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lfoot, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rfoot, x_axis)
			Sleep(10)
			--Spring.Echo("Step FIVE")
			--Left Leg--
			Turn(lupperleg, x_axis, rad(-25), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(-15), LEG_SPEED)
			Turn(lfoot, x_axis, rad(45), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(25), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(25), LEG_SPEED)
			Turn(rfoot, x_axis, rad(-45), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lfoot, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rfoot, x_axis)
			Sleep(10)
			--Spring.Echo("Step SIX")
			--Left Leg--
			Turn(lupperleg, x_axis, rad(-45), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(0), LEG_SPEED)
			Turn(lfoot, x_axis, rad(60), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(25), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(45), LEG_SPEED)
			Turn(rfoot, x_axis, rad(-60), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lfoot, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rfoot, x_axis)
			Sleep(10)
			--Spring.Echo("Step SEVEN")
			--Left Leg--
			Turn(lupperleg, x_axis, rad(-30), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(15), LEG_SPEED)
			Turn(lfoot, x_axis, rad(15), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(45), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(15), LEG_SPEED)
			Turn(rfoot, x_axis, rad(0), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lfoot, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rfoot, x_axis)
			Sleep(10)
			--Spring.Echo("Step EIGHT")
			--Left Leg--
			Turn(lupperleg, x_axis, rad(0), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(5), LEG_SPEED)
			Turn(lfoot, x_axis, rad(0), LEG_SPEED)
			--Right Leg--
			Turn(rupperleg, x_axis, rad(-10), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(-15), LEG_SPEED)
			Turn(rfoot, x_axis, rad(30), LEG_SPEED)
			--Wait For Turns...--
			WaitForTurn(lupperleg, x_axis)
			WaitForTurn(llowerleg, x_axis)
			WaitForTurn(lfoot, x_axis)
			WaitForTurn(rupperleg, x_axis)
			WaitForTurn(rlowerleg, x_axis)
			WaitForTurn(rfoot, x_axis)
			Sleep(10)
		else
			Turn(lupperleg, x_axis, rad(0), LEG_SPEED)
			Turn(llowerleg, x_axis, rad(0), LEG_SPEED)
			Turn(lfoot, x_axis, rad(0), LEG_SPEED)
			Turn(rupperleg, x_axis, rad(0), LEG_SPEED)
			Turn(rlowerleg, x_axis, rad(0), LEG_SPEED)
			Turn(rfoot, x_axis, rad(0), LEG_SPEED)
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
	Turn(mantlet1, x_axis, 0, ELEVATION_SPEED)
	Turn(mantlet2, x_axis, 0, ELEVATION_SPEED)
	Turn(mantlet3, x_axis, 0, ELEVATION_SPEED)
	Turn(mantlet4, x_axis, 0, ELEVATION_SPEED)
end

function script.AimWeapon(weaponID, heading, pitch)
	Signal(SIG_AIM ^ weaponID) -- 2 'to the power of' weapon ID
    SetSignalMask(SIG_AIM ^ weaponID)
		if weaponID == 1 then
			Turn(llowerarm, x_axis, -pitch, ELEVATION_SPEED)
		elseif weaponID == 2 then
			Turn(rlowerarm, x_axis, -pitch, ELEVATION_SPEED)
		elseif weaponID == 5 then
			Turn(mantlet1, x_axis, -pitch, ELEVATION_SPEED)
		elseif weaponID == 6 then
			Turn(mantlet2, x_axis, -pitch, ELEVATION_SPEED)
		elseif weaponID == 7 then
			Turn(mantlet3, x_axis, -pitch, ELEVATION_SPEED)
		elseif weaponID == 8 then
			Turn(mantlet4, x_axis, -pitch, ELEVATION_SPEED)
		end
	Turn(torso, y_axis, heading, TORSO_SPEED)
	WaitForTurn(torso, y_axis)
	StartThread(RestoreAfterDelay)
	return true
end

function script.FireWeapon(weaponID)
		if weaponID == 1 then
			EmitSfx(flare1, MG_MUZZLEFLASH)
		elseif weaponID == 2 then
			EmitSfx(flare2, MG_MUZZLEFLASH)
		elseif weaponID == 5 then
			EmitSfx(acflare1, XSMALL_MUZZLEFLASH)
			Move(barrel1, z_axis, -1, 200)
			WaitForMove(barrel1, z_axis)
			Move(barrel1, z_axis, 0, 50)
		elseif weaponID == 6 then
			EmitSfx(acflare2, XSMALL_MUZZLEFLASH)
			Move(barrel2, z_axis, -1, 200)
			WaitForMove(barrel2, z_axis)
			Move(barrel2, z_axis, 0, 50)
		elseif weaponID == 7 then
			EmitSfx(acflare3, XSMALL_MUZZLEFLASH)
			Move(barrel3, z_axis, -1, 200)
			WaitForMove(barrel3, z_axis)
			Move(barrel3, z_axis, 0, 50)
		elseif weaponID == 8 then
			EmitSfx(acflare4, XSMALL_MUZZLEFLASH)
			Move(barrel4, z_axis, -1, 200)
			WaitForMove(barrel4, z_axis)
			Move(barrel4, z_axis, 0, 50)
		end
end

function script.Shot(weaponID)
	if missileWeaponIDs[weaponID] then
		EmitSfx(launchPoints[weaponID][currPoints[weaponID]], MEDIUM_MUZZLEFLASH)
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
		elseif weaponID == 5 then
			return acflare1
		elseif weaponID == 6 then
			return acflare2
		elseif weaponID == 7 then
			return acflare3
		elseif weaponID == 8 then
			return acflare4
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
