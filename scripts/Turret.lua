-- Vehicle Script
-- useful global stuff
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
local noFiring = true
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
	else
		flares[weaponID] = piece ("flare_" .. weaponID)
	end
	if info.mantletIDs[weaponID] then
		mantlets[weaponID] = piece("mantlet_" .. weaponID)
	end
	if info.barrelIDs[weaponID] then
		barrels[weaponID] = piece("barrel_" .. weaponID)
	end
end

-- Constants
local DROP_HEIGHT = 10000
local GRAVITY = 120/Game.gravity
local X, _, Z = Spring.GetUnitPosition(unitID)
local GY = Spring.GetGroundHeight(X, Z)
local FACING

-- Variables
local stage = 1

function TeamChange(teamID)
	if stage == 3 then -- only toggle noFiring once landed
		if teamID == GAIA_TEAM_ID then
			noFiring = true
		else
			noFiring = false
		end
	end
end

local legs = {}
local breaks = {}
local exhausts = {}
for i = 1, 4 do
	legs[i] = piece("leg_" .. i)
	breaks[i] = piece("break_" .. i)
	exhausts[i] = piece("exhaust_" .. i)
end

local SPEED = math.rad(150)
function TouchDown()
	stage = 3
	FACING = select(2, Spring.UnitScript.GetPieceRotation(base)) or 0 -- TODO: Discover how this can be nil?
end

function fx()
	while stage == 1 do
		Sleep(50)
	end
	if stage == 2 then
		for i = 1,4 do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhausts[i], {id = "turret_exhaust", width = 25, length = 70})
		end
	end
	while stage == 2 do
		Sleep(50)
	end
	if stage == 3 then -- for clarity only
		GG.RemoveLupsSfx(unitID, "turret_exhaust")
		if unitDef.customParams.hasbap then
			GG.PlaySoundForTeam(Spring.GetUnitTeam(unitID), "BB_bap_deployed", 1)
		else
			GG.PlaySoundForTeam(Spring.GetUnitTeam(unitID), "BB_turret_deployed", 1)
		end
		Sleep(1000)
		for i = 1,4 do
			local axis = (i % 2 == 0 and z_axis) or x_axis -- even use z, odd use x
			local dir = (i == 1 or i == 4) and -1 or 1
			Turn(legs[i], axis, math.rad(dir * 83), SPEED)
		end
		WaitForTurn(legs[4], z_axis)
		for i = 1,4 do
			local axis = (i % 2 == 0 and z_axis) or x_axis -- even use z, odd use x
			local dir = (i == 1 or i == 4) and -1 or 1
			Turn(legs[i], axis, math.rad(dir * 110), SPEED / 5)
		end
		local height = 0
		local angleDiff = math.rad(110 - 83)
		local hyp = 5 / math.sin(angleDiff)
		while height < 5 do
			local angle = angleDiff - (Spring.UnitScript.GetPieceRotation(legs[1]) - math.rad(250))
			height = math.sin(angle) * hyp
			Move(base, y_axis, height)
			Sleep(50)
		end
		if mantlets[1] then 
			Turn(mantlets[1], x_axis, 0, SPEED)
			WaitForTurn(mantlets[1], x_axis)
		end
		-- Start acting like a real boy
		StartThread(SmokeUnit, {base, turret})
		noFiring = false
		Spring.SetUnitNeutral(unitID, false)
		Spring.SetUnitStealth(unitID, false)
		Spring.SetUnitSensorRadius(unitID, "los", unitDef.losRadius)
		Spring.SetUnitSensorRadius(unitID, "los", unitDef.airLosRadius)
		Spring.SetUnitSensorRadius(unitID, "radar", unitDef.radarRadius)
	end
end

function script.Create()
	-- Pre-setup
	if mantlets[1] then 
		Turn(mantlets[1], x_axis, math.rad(-90))
	end
	Turn(exhausts[1], y_axis, math.rad(180))	
	Turn(exhausts[2], y_axis, math.rad(-90))
	Turn(exhausts[4], y_axis, math.rad(90))
		
	-- Orbital insertion anim
	Spring.MoveCtrl.Enable(unitID)
	Spring.MoveCtrl.SetPosition(unitID, X, GY + DROP_HEIGHT, Z)
	Spring.SetUnitNeutral(unitID, true)
	Spring.SetUnitStealth(unitID, true)
	Spring.SetUnitSensorRadius(unitID, "los", 0)
	Spring.SetUnitSensorRadius(unitID, "airLos", 0)
	Spring.SetUnitSensorRadius(unitID, "radar", 0)
	
	for i = 1,4 do
		Turn(exhausts[i], x_axis, math.rad(70))
		Spin(exhausts[i], z_axis, math.rad(360)) -- doesn't seem to be working?
	end

	Spin(base, y_axis, 10)
	Spring.MoveCtrl.SetGravity(unitID, GRAVITY)
	Spring.MoveCtrl.SetCollideStop(unitID, true)
	Spring.MoveCtrl.SetTrackGround(unitID, true)
	StartThread(fx)
	
	local _, y, _ = Spring.GetUnitPosition(unitID)
	while y - GY > 1000 do
		_,y,_ = Spring.GetUnitPosition(unitID)
		Sleep(100)
	end

	stage = 2
	StopSpin(base, y_axis, 0.1)
	
	for i = 1,4 do
		Hide(breaks[i])
		Explode(breaks[i], SFX.FIRE + SFX.FALL)
	end

	Spring.MoveCtrl.SetGravity(unitID, 0)

	local _, sy, _ = Spring.GetUnitVelocity(unitID)
	Spring.MoveCtrl.SetVelocity(unitID, 0, sy * 0.75, 0)
	while -sy > 5 do
		Sleep(120)
		_, y, _ = Spring.GetUnitPosition(unitID)
		_, sy, _ = Spring.GetUnitVelocity(unitID)
		Spring.MoveCtrl.SetVelocity(unitID, 0, sy * 0.8, 0)
	end	
	Spring.MoveCtrl.SetGravity(unitID, -0.01 * GRAVITY)
end


function script.AimWeapon(weaponID, heading, pitch)
	if noFiring then return false end
	Signal(2 ^ weaponID) -- 2 'to the power of' weapon ID
	SetSignalMask(2 ^ weaponID)
	
	Turn(turret, y_axis, heading - FACING, TURRET_SPEED)
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
	Sleep(100 * weaponID) -- desync barrels to fire independently
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
