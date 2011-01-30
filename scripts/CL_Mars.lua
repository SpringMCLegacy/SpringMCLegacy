-- Test Tank Script
-- useful global stuff
local ud = UnitDefs[Spring.GetUnitDefID(unitID)] -- unitID is available automatically to all LUS
local weapons = ud.weapons
--piece defines
local body, turret, mantlet, barrel1, barrel2, hullbarrel, mg = piece ("body", "turret", "mantlet", "barrel1", "barrel2", "hullbarrel", "mg")
local trackr, trackl = piece ("trackr", "trackl")
local flare1, flare2, hullflare, mgflare1, mgflare2 = piece ("flare1", "flare2", "hullflare", "mgflare1", "mgflare2")
local smokePieces = {body, turret}

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
local rad = math.rad
local currLaunchPoint = 1

-- constants
local SIG_AIM = 2

local RESTORE_DELAY = Spring.UnitScript.GetLongestReloadTime(unitID) * 2

-- includes
include "smokeunit.lua"

--SFX defines
LARGE_MUZZLEFLASH = SFX.CEG+0
MEDIUM_MUZZLEFLASH = SFX.CEG+1
MG_MUZZLEFLASH = SFX.CEG+2

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
end

function script.StopMoving()
	SpinWheels(false)
end

local function RestoreAfterDelay(unitID)
	Sleep(RESTORE_DELAY)
	Turn(turret, y_axis, 0, math.rad(50))
	Turn(mantlet, x_axis, 0, math.rad(100))
	Turn(hullbarrel, y_axis, 0, math.rad(50))
	Turn(hullbarrel, x_axis, 0, math.rad(100))
	Turn(barrel2, x_axis, 0, math.rad(100))
	Turn(mg, x_axis, 0, math.rad(200))
end

function script.AimWeapon(weaponID, heading, pitch)
	Signal(SIG_AIM ^ weaponID) -- 2 'to the power of' weapon ID
    SetSignalMask(SIG_AIM ^ weaponID)
		--if missileWeaponIDs[weaponID] then
		--	Turn(launchPoints[weaponID][i], x_axis, -pitch, rad(200))
		if weaponID == 1 then
			Turn(mantlet, x_axis, -pitch, rad(100))
			Turn(turret, y_axis, heading, rad(50))
			WaitForTurn(turret, y_axis)
		elseif weaponID == 2 then
			Turn(barrel2, x_axis, -pitch, rad(100))
			Turn(turret, y_axis, heading, rad(50))
			WaitForTurn(turret, y_axis)
		elseif weaponID == 3 then
			Turn(hullbarrel, y_axis, heading, rad(50))
			Turn(hullbarrel, x_axis, -pitch, rad(100))
			WaitForTurn(hullbarrel, y_axis)
		elseif weaponID == 7 then
			Turn(mg, x_axis, -pitch, rad(200))
			Turn(turret, y_axis, heading, rad(50))
			WaitForTurn(turret, y_axis)
		elseif weaponID == 8 then
			Turn(mg, x_axis, -pitch, rad(200))
			Turn(turret, y_axis, heading, rad(50))
			WaitForTurn(turret, y_axis)
		end
	StartThread(RestoreAfterDelay)
	return true
end

function script.FireWeapon(weaponID)
		if weaponID == 1 then
			EmitSfx(flare1, LARGE_MUZZLEFLASH)
		elseif weaponID == 2 then
			EmitSfx(flare2, MG_MUZZLEFLASH)
		elseif weaponID == 3 then
			EmitSfx(hullflare, MEDIUM_MUZZLEFLASH)
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
		EmitSfx(launchPoints[weaponID][currPoints[weaponID]], MEDIUM_MUZZLEFLASH)
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
