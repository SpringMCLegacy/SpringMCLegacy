-- Test Tank Script
-- useful global stuff
local ud = UnitDefs[Spring.GetUnitDefID(unitID)] -- unitID is available automatically to all LUS
local weapons = ud.weapons
local deg, rad = math.deg, math.rad

--piece defines
local pelvis, torso, launcher1, launcher2, barrel = piece ("pelvis", "torso", "launcher1", "launcher2", "barrel")
local lupperleg, llowerleg, rupperleg, rlowerleg, rfronttoes, rbacktoes, lfronttoes, lbacktoes = piece ("lupperleg", "llowerleg", "rupperleg", "rlowerleg", "rfronttoes", "rbacktoes", "lfronttoes", "lbacktoes")
local flare = piece ("flare")
local smokePieces = {body, turret}

local missileWeaponIDs = {[2] = true, [3] = true}
 
local launchPoints = {}
local numPoints = {}
local currPoints = {}
 
--Turning/Movement Locals
local TORSO_SPEED = rad(200)
local ELEVATION_SPEED = rad(200)

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

local RESTORE_DELAY = Spring.UnitScript.GetLongestReloadTime(unitID) * 2

-- includes
include "smokeunit.lua"

--SFX defines
SMALL_MUZZLEFLASH = SFX.CEG+0
MG_MUZZLEFLASH = SFX.CEG+1

function script.Create()
	StartThread(SmokeUnit())
end

function script.StartMoving()
	--omg WALK!!!!!
end

function script.StopMoving()
	--omg STOP WALKING!!!!!
end

local function RestoreAfterDelay(unitID)
	Sleep(RESTORE_DELAY)
	Turn(torso, y_axis, 0, TORSO_SPEED)
	Turn(barrel, x_axis, 0, ELEVATION_SPEED)
	Turn(launcher1, x_axis, 0, ELEVATION_SPEED)
	Turn(launcher2, x_axis, 0, ELEVATION_SPEED)
end

function script.AimWeapon(weaponID, heading, pitch)
	Signal(SIG_AIM ^ weaponID) -- 2 'to the power of' weapon ID
    SetSignalMask(SIG_AIM ^ weaponID)
		if weaponID == 1 then
			Turn(barrel, x_axis, -pitch, ELEVATION_SPEED)
		--elseif weaponID == 2 then
		--	Turn(launcher1, x_axis, -pitch, rad(150))
		--elseif weaponID == 3 then
		--	Turn(launcher2, x_axis, -pitch, rad(150))
		end
	Turn(torso, y_axis, heading, TORSO_SPEED)
	WaitForTurn(torso, y_axis)
	StartThread(RestoreAfterDelay)
	return true
end

function script.FireWeapon(weaponID)
		if weaponID == 1 then
			EmitSfx(flare, MG_MUZZLEFLASH)
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
	return torso
end

function script.QueryWeapon(weaponID) 
	if missileWeaponIDs[weaponID] then
		return launchPoints[weaponID][currPoints[weaponID]]
	else
		if weaponID == 1 then
			return flare
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
