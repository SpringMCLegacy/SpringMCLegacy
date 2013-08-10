-- Vehicle Script
-- useful global stuff
unitDefID = Spring.GetUnitDefID(unitID)
unitDef = UnitDefs[unitDefID]
info = GG.lusHelper[unitDefID]

-- localised API functions
local SetUnitRulesParam = Spring.SetUnitRulesParam
local GetUnitSeparation = Spring.GetUnitSeparation
local GetUnitCommands   = Spring.GetUnitCommands
local GetUnitLastAttackedPiece = Spring.GetUnitLastAttackedPiece
-- localised GG functions
local GetUnitDistanceToPoint = GG.GetUnitDistanceToPoint
local GetUnitUnderJammer = GG.GetUnitUnderJammer
local IsUnitNARCed = GG.IsUnitNARCed
local IsUnitTAGed = GG.IsUnitTAGed

-- includes
include "smokeunit.lua"

-- Info from lusHelper gadget
local missileWeaponIDs = info.missileWeaponIDs
local flareOnShots = info.flareOnShots
local jammableIDs = info.jammableIDs
local launcherIDs = info.launcherIDs
local barrelRecoils = info.barrelRecoilDist
local burstLengths = info.burstLengths
local firingHeats = info.firingHeats
local minRanges = info.minRanges
local spinSpeeds = info.spinSpeeds

--Turning/Movement Locals
local TURRET_SPEED = info.turretTurnSpeed
local ELEVATION_SPEED = info.elevationSpeed
local BARREL_SPEED = info.barrelRecoilSpeed
local RESTORE_DELAY = Spring.UnitScript.GetLongestReloadTime(unitID) * 2

local currLaunchPoint = 1
local noFiring = false
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()

--piece defines
local base, turret = piece ("base", "turret")

local flares = {}
local mantlets = {}
local barrels = {}
local launchers = {}
local launchPoints = {}
local currPoints = {}
for weaponID = 1, info.numWeapons do
	if missileWeaponIDs[weaponID] then
		if launcherIDs[weaponID] then
			launchers[weaponID] = piece("launcher_" .. weaponID)
		end
		launchPoints[weaponID] = {}
		currPoints[weaponID] = 1
		for i = 1, burstLengths[weaponID] do
			launchPoints[weaponID][i] = piece("launchpoint_" .. weaponID .. "_" .. i)
		end	
	elseif weaponID ~= amsID then
		flares[weaponID] = piece ("flare_" .. weaponID)
	end
	if info.mantletIDs[weaponID] then
		mantlets[weaponID] = piece("mantlet_" .. weaponID)
	end
	if info.barrelIDs[weaponID] then
		barrels[weaponID] = piece("barrel_" .. weaponID)
	end
end

function TeamChange(teamID)
	if teamID == GAIA_TEAM_ID then
		noFiring = true
	else
		noFiring = false
	end
end

function script.Create()
	StartThread(SmokeUnit, {base, turret})
end


function script.AimWeapon(weaponID, heading, pitch)
	if noFiring then return false end
	Signal(2 ^ weaponID) -- 2 'to the power of' weapon ID
	SetSignalMask(2 ^ weaponID)
	
	Turn(turret, y_axis, heading, TURRET_SPEED)
	if mantlets[weaponID] then
		Turn(mantlets[weaponID], x_axis, -pitch, TURRET_SPEED)
	elseif missileWeaponIDs[weaponID] then
		if launchers[weaponID] then
			Turn(launchers[weaponID], x_axis, -pitch, ELEVATION_SPEED)
		else
			for i = 1, burstLengths[weaponID] do
				Turn(launchPoints[weaponID][i], x_axis, -pitch, ELEVATION_SPEED)
			end
		end
	else
		Turn(flares[weaponID], x_axis, -pitch, ELEVATION_SPEED)
	end
	WaitForTurn(turret, y_axis)
	if mantlets[weaponID] then
		WaitForTurn(mantlets[weaponID], x_axis)
	end
	return true
end

function script.BlockShot(weaponID, targetID, userTarget)
	local jammable = jammableIDs[weaponID]
	if jammable then
		if targetID then
			local jammed = GetUnitUnderJammer(targetID) and (not IsUnitNARCed(targetID))
			if jammed then
				--Spring.Echo("Can't fire weapon " .. weaponID .. " as target is jammed")
				return true 
			end
		end
	end
	local minRange = minRanges[weaponID]
	if minRange then
		local distance
		if targetID then
			distance = GetUnitSeparation(unitID, targetID, true)
		elseif userTarget then
			local cmd = GetUnitCommands(unitID, 1)[1]
			if cmd.id == CMD.ATTACK then
				local tx,ty,tz = unpack(cmd.params)
				distance = GetUnitDistanceToPoint(unitID, tx, ty, tz, false)
			end
		end
		if distance < minRange then return true end
	end
	return false
end

function script.FireWeapon(weaponID)
	if barrels[weaponID] and barrelRecoils[weaponID] then
		Move(barrels[weaponID], z_axis, -barrelRecoils[weaponID], BARREL_SPEED)
		WaitForMove(barrels[weaponID], z_axis)
		Move(barrels[weaponID], z_axis, 0, 10)
	end
	if not missileWeaponIDs[weaponID] and not flareOnShots[weaponID] then
		EmitSfx(flares[weaponID], SFX.CEG + weaponID)
	end
end

function script.Shot(weaponID)
	if missileWeaponIDs[weaponID] then
		EmitSfx(launchPoints[weaponID][currPoints[weaponID]], SFX.CEG + weaponID)
        currPoints[weaponID] = currPoints[weaponID] + 1
        if currPoints[weaponID] > burstLengths[weaponID] then 
			currPoints[weaponID] = 1
        end
	elseif flareOnShots[weaponID] then
		EmitSfx(flares[weaponID], SFX.CEG + weaponID)
	end
end

function script.AimFromWeapon(weaponID) 
	return turret
end

function script.QueryWeapon(weaponID) 
	if missileWeaponIDs[weaponID] then
		return launchPoints[weaponID][currPoints[weaponID]]
	--[[elseif weaponID == amsID then
		return turret]]
	else
		return flares[weaponID]
	end
end

function script.Killed(recentDamage, maxHealth)
	--local severity = recentDamage / maxHealth * 100
	--if severity <= 25 then
	--	Explode(base, math.bit_or({SFX.BITMAPONLY, SFX.BITMAP1}))
	--	return 1
	--elseif severity <= 50 then
	--	Explode(base, math.bit_or({SFX.FALL, SFX.BITMAP1}))
	--	return 2
	--else
	--	Explode(base, math.bit_or({SFX.FALL, SFX.SMOKE, SFX.FIRE, SFX.EXPLODE_ON_HIT, SFX.BITMAP1}))
	--	return 3
	--end
	return 1
end
