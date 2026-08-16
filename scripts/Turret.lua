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
local numWeapons = info.numWeapons
local amsIDs = info.amsIDs
local missileWeaponIDs = info.missileWeaponIDs
local flareOnShots = info.flareOnShots
local jammableIDs = info.jammableIDs
local launcherIDs = info.launcherIDs
local launcherDoorIDs = info.launcherDoorIDs
local barrelRecoils = info.barrelRecoilDist
local burstLengths = info.burstLengths
local firingHeats = info.firingHeats
local minRanges = info.minRanges
local spinSpeeds = info.spinSpeeds
local ammoTypes = info.ammoTypes
local maxAmmo = info.maxAmmo
local currAmmo = {} -- copy maxAmmo table into currAmmo
for k,v in pairs(maxAmmo) do 
	currAmmo[k] = v 
	SetUnitRulesParam(unitID, "ammo_" .. k, 100)
end

local largeTurret = tonumber(unitDef.customParams.slotcost) == 2

--Turning/Movement Locals
local TURRET_SPEED = info.turretTurnSpeed
local ELEVATION_SPEED = info.elevationSpeed
local BARREL_SPEED = info.barrelRecoilSpeed
local SPIN_WAIT_MULT = 5 -- how many times spinSpeed to wait
local RESTORE_DELAY = Spring.UnitScript.GetLongestReloadTime(unitID) * 2
local AMMO_RESTORE_WAIT = tonumber(unitDef.customParams.ammorestorewait) or (largeTurret and 25 or 10) * 1000 -- 10 seconds

local currLaunchPoint = 1
local noFiring = true
local GAIA_TEAM_ID = Spring.GetGaiaTeamID()

--piece defines
local base, turret = piece ("base", "turret")
local cockpit = piece ("cockpit")

-- Sniper artillery drum setting
local drumNum = 0
local drum = piece("drum")

local flares = {}
local mantlets = {}
local barrels = {}
local launchers = {}
local launcherDoors = {}
local launchPoints = {}
local missiles = {}
local numMissiles = info.numMissiles
local currPoints = {}
local spinners = {}

local playerDisabled = {}
for weaponID = 1, info.numWeapons do
	if missileWeaponIDs[weaponID] then
		if launcherIDs[weaponID] then
			launchers[weaponID] = piece("launcher_" .. weaponID)
			if launcherDoorIDs[weaponID] then
				launcherDoors[weaponID] = piece("launcherdoor_" .. weaponID)
			end
		end
		launchPoints[weaponID] = {}
		missiles[weaponID] = {}
		currPoints[weaponID] = 1
		for i = 1, burstLengths[weaponID] do
			launchPoints[weaponID][i] = piece("launchpoint_" .. weaponID .. "_" .. i)
			missiles[weaponID][i] = piece("missile_" .. weaponID .. "_" .. i)
		end	
	elseif weaponID then
		flares[weaponID] = piece ("flare_" .. weaponID)
	end
	if info.mantletIDs[weaponID] then
		mantlets[weaponID] = piece("mantlet_" .. weaponID)
	end
	if spinSpeeds[weaponID] then
		spinners[weaponID] = {
			pieceNum = piece("barrels_" .. weaponID),
			state = 0,
			wait = math.deg(spinSpeeds[weaponID]) * SPIN_WAIT_MULT,
		}
	elseif info.barrelIDs[weaponID] then
		barrels[weaponID] = piece("barrel_" .. weaponID)
	end
	playerDisabled[weaponID] = false
	SetUnitRulesParam(unitID, "weapon_" .. weaponID, "active")
	if amsIDs[weaponID] then
		--Spring.SetUnitWeaponState(unitID, weaponID, "reaimtime", 1)
		--Spring.SetUnitWeaponState(unitID, weaponID, "autoTargetRangeBoost", 100)
	end
end


-- Constants
local DROP_HEIGHT = 10000
local GRAVITY = 120/Game.gravity
local X, _, Z = Spring.GetUnitPosition(unitID)
local GY = Spring.GetGroundHeight(X, Z)
local FACING = 0

-- Variables
local stage = 1
local teamID

function TeamChange(newTeamID)
	teamID = newTeamID
	--if stage == 3 then -- only toggle noFiring once landed
		if teamID == GAIA_TEAM_ID then
			noFiring = true
		else
			noFiring = false
		end
	--end
end

local legs = {}
local breaks = {}
local exhausts = {}
local extend = piece("extend")

for i = 1, 6 do
	legs[i] = piece("leg_" .. i)
	breaks[i] = piece("break_" .. i)
	exhausts[i] = piece("exhaust_" .. i)
end

local SPEED = math.rad(150)
function TouchDown()
	stage = 3
	FACING = select(2, Spring.UnitScript.GetPieceRotation(base)) or 0
	GG.EmitSfxName(unitID, turret, "mech_jump_dust")
	PlaySound("stomp")
end

function RealBoy()
	StartThread(SmokeUnit, {base, turret})
	teamID = Spring.GetUnitTeam(unitID)
	if teamID ~= GAIA_TEAM_ID then
		noFiring = false
		Spring.SetUnitNeutral(unitID, false)
	end
	Spring.SetUnitStealth(unitID, false)
	Spring.SetUnitSensorRadius(unitID, "los", unitDef.losRadius)
	Spring.SetUnitSensorRadius(unitID, "airLos", unitDef.airLosRadius)
	Spring.SetUnitSensorRadius(unitID, "radar", unitDef.radarRadius)
end

function fx()
	while stage == 1 do
		Sleep(50)
	end
	if stage == 2 then
		for i = 1, #exhausts do
			GG.EmitLupsSfx(unitID, "dropship_vertical_exhaust", exhausts[i], {id = "turret_exhaust", width = 25, length = 70})
		end
	end
	while stage == 2 do
		Sleep(50)
	end
	if stage == 3 then -- for clarity only
		GG.RemoveLupsSfx(unitID, "turret_exhaust")
		if unitDef.customParams.hasbap then
			GG.PlaySoundForTeam(Spring.GetUnitTeam(unitID), "bb_bap_deployed", 1)
		else
			GG.PlaySoundForTeam(Spring.GetUnitTeam(unitID), "bb_turret_deployed", 1)
		end
		Sleep(1000)
		PlaySound("turret_deploy")
		for i = 1,#legs do
			if largeTurret then
				Turn(legs[i], x_axis, math.rad(-90), SPEED)
			else
				local axis = (i % 2 == 0 and z_axis) or x_axis -- even use z, odd use x
				local dir = (i == 1 or i == 4) and -1 or 1
				Turn(legs[i], axis, math.rad(dir * 83), SPEED)
			end
		end
		if legs[4] then -- TODO; shouldn't be needed on the new large turrets, here for garrison versions
			WaitForTurn(legs[4], z_axis)
		end
		if not largeTurret then
			for i = 1,#legs do
				local axis = (i % 2 == 0 and z_axis) or x_axis -- even use z, odd use x
				local dir = (i == 1 or i == 4) and -1 or 1
				Turn(legs[i], axis, math.rad(dir * 110), SPEED / 5)
			end
			local height = 0
			local angleDiff = math.rad(110 - 83)
			local hyp = 3.5 / math.sin(angleDiff)
			while height < 3.5 do
				local angle = angleDiff - (Spring.UnitScript.GetPieceRotation(legs[1]) - math.rad(250))
				height = math.sin(angle) * hyp
				Move(base, y_axis, height)
				Sleep(50)
			end
		end
		for weaponID, mantlet in pairs(mantlets) do
			Turn(mantlet, x_axis, 0, SPEED)
		end
		for weaponID, mantlet in pairs(mantlets) do
			WaitForTurn(mantlet, x_axis)
		end
		if extend then
			Move(barrels[1], z_axis, 0, 10)
			WaitForMove(barrels[1], z_axis)
		end
		-- Start acting like a real boy
		RealBoy()
	end
end

function script.Create()
	if unitDef.name == "hturret_cc" then
		GG.EnableAmmo(unitID, true, "lrm", "thunder")
	elseif unitDef.name == "hturret_arrow" then
		GG.EnableAmmo(unitID, true, "arrowiv", "homing")
		for i = 1, numWeapons do
			Spring.SetUnitWeaponState(unitID, i, "reloadTime", 3)
		end
	elseif unitDef.name == "hturret_ada" then
		for i = 1, numWeapons do
			Spring.SetUnitWeaponState(unitID, i, "reloadTime", 3)
		end
	end
	-- Pre-setup
	for weaponID, mantlet in pairs(mantlets) do
		Turn(mantlet, x_axis, math.rad(-90))
	end
	if largeTurret then
		if extend then
			Move(barrels[1], z_axis, -10)
		end
		for i = 1, #exhausts do
			Turn(exhausts[i], y_axis, math.rad(-60 * (i-1)-30))
			Turn(legs[i], y_axis, math.rad(-60 * (i-1)-30))
		end
	else
		for i = 1, #exhausts do
			Turn(exhausts[i], y_axis, math.rad(90*(i+1)))
		end
	end
		
	-- Orbital insertion anim
	Spring.MoveCtrl.Enable(unitID)
	Spring.MoveCtrl.SetPosition(unitID, X, GY + DROP_HEIGHT, Z)
	Spring.SetUnitAlwaysVisible(unitID, true)
	Spring.SetUnitNeutral(unitID, true)
	Spring.SetUnitStealth(unitID, true)
	Spring.SetUnitSensorRadius(unitID, "los", 0)
	Spring.SetUnitSensorRadius(unitID, "airLos", 0)
	Spring.SetUnitSensorRadius(unitID, "radar", 0)
	
	for i = 1,#exhausts do
		Turn(exhausts[i], x_axis, math.rad(70))
		--Spin(exhausts[i], z_axis, math.rad(360)) -- doesn't seem to be working?
	end

	Spin(base, y_axis, math.random(5,11))
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
	
	for i = 1,#breaks do
		Hide(breaks[i])
		Explode(breaks[i], SFX.FIRE + SFX.FALL)
		PlaySound("NavBeacon_Pop")
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
	--end
end

local function SpinBarrels(weaponID, start)
	local spinfo = spinners[weaponID]
	Signal(spinfo)
	SetSignalMask(spinfo)
	if start and spinfo.state == 0 then
		spinfo.state = 1
		Spin(spinfo.pieceNum, z_axis, spinSpeeds[weaponID], spinSpeeds[weaponID] / SPIN_WAIT_MULT)
		Sleep(spinfo.wait) -- spin up wait
		spinfo.state = 2
	elseif not start and spinfo.state > 0 then
		Sleep(spinfo.wait) -- spin down wait
		StopSpin(spinfo.pieceNum, z_axis, spinSpeeds[weaponID]/10)
		spinfo.state = 0
	end
end

function ChangeAmmo(ammoType, amount) 
	local newAmmoLevel = (currAmmo[ammoType] or 0) + (amount or 0) -- amount is a -ve to deduct
	if amount > 0 then -- restocking, reset the indicator
		SetUnitRulesParam(unitID, "outofammo", 0)
	end
	if not ammoType then Spring.Echo("debug report turret.lua L309", unitDef.name) return false end
	if newAmmoLevel <= maxAmmo[ammoType] then -- TODO: somehow one of these can be wrong type / nil?
		currAmmo[ammoType] = newAmmoLevel
		SetUnitRulesParam(unitID, "ammo_" .. ammoType, 100 * newAmmoLevel / maxAmmo[ammoType])
		return true -- Ammo was changed
	end
	return false -- Ammo was not changed
end

local function AwaitRestock()
	noFiring = true
	-- TODO: show some status icon?
	Sleep(AMMO_RESTORE_WAIT)
	for weaponID, weaponMissiles in pairs(missiles) do
		for i, missilePiece in pairs(weaponMissiles) do
			Show(missilePiece)
		end
	end
	for ammoType, amount in pairs(maxAmmo) do
		ChangeAmmo(ammoType, amount) 
	end
	noFiring = teamID == GAIA_TEAM_ID
end

local function WeaponCanFire(weaponID)
	if playerDisabled[weaponID] or weaponID == numWeapons + 1 then
		return false
	end
	--[[if mainTurretIDs[weaponID] and limbHPs["turret"] <= 0 then
		return false
	end]]
	if amsIDs[weaponID] then -- check AMS after limbs
		return true
	end
	--[[if jammableIDs[weaponID] and not activated then
		return false
	end]]
	local ammoType = ammoTypes[weaponID]
	if ammoType and (currAmmo[ammoType] or 0) < (burstLengths[weaponID] or 0) then
		if spinSpeeds[weaponID] then
			StartThread(SpinBarrels, weaponID, false)
		end
		SetUnitRulesParam(unitID, "outofammo", 1)
		StartThread(AwaitRestock)
		return false
	else
		if spinSpeeds[weaponID] then
			local spinState = spinners[weaponID].state
			if spinState < 1 then
				StartThread(SpinBarrels, weaponID, true)
				return false -- can't fire until spun up
			else
				return spinState == 2
			end
		end
		Sleep(info.chainFireDelays[weaponID])
		return true
	end
end
		
local function RestoreAfterDelay(delay, weaponID)
	Sleep(delay)
	if launcherDoors[weaponID] then
		local dir = (-1)^weaponID
		Turn(launcherDoors[weaponID], y_axis, 0, dir * TURRET_SPEED * 5)
	end
end

function script.AimWeapon(weaponID, heading, pitch)
	if noFiring then return false end
	Signal(2 ^ weaponID) -- 2 'to the power of' weapon ID
	SetSignalMask(2 ^ weaponID)

	Turn(turret, y_axis, heading - FACING, TURRET_SPEED)
	
	if mantlets[weaponID] then
		Turn(mantlets[weaponID], x_axis, -pitch, ELEVATION_SPEED)
	elseif missileWeaponIDs[weaponID] then -- yeah it happens if, in this case, launchpoint_1_# are attached to launcher_1 but launchpoint_2_# and 3 are attached to launcher_1 as well
		if launchers[weaponID] then
			Turn(launchers[weaponID], x_axis, -pitch, ELEVATION_SPEED)
			if launcherDoors[weaponID] then
				local dir = (-1)^(weaponID-1)
				Turn(launcherDoors[weaponID], y_axis, dir * (math.pi+0.0001), dir * TURRET_SPEED * 5)
			end
		elseif weaponID > 1 and launchers[1] then
			Turn(launchers[1], x_axis, -pitch, ELEVATION_SPEED)
		else
			for i = 1, burstLengths[weaponID] do
				Turn(launchPoints[weaponID][i], x_axis, -pitch, ELEVATION_SPEED)
			end
		end
	elseif flares[weaponID] then -- TODO: 'else' should be sufficient here
		Turn(flares[weaponID], x_axis, -pitch, ELEVATION_SPEED)
	end
	WaitForTurn(turret, y_axis)
	if mantlets[weaponID] then
		WaitForTurn(mantlets[weaponID], x_axis)
	end
	if launchers[weaponID] then
		WaitForTurn(launchers[weaponID], x_axis)
		if launcherDoors[weaponID] then
			WaitForTurn(launcherDoors[weaponID], y_axis)
		end
	end
	StartThread(RestoreAfterDelay, RESTORE_DELAY, weaponID)
	return WeaponCanFire(weaponID)
end

function script.BlockShot(weaponID, targetID, userTarget)
	if amsIDs[weaponID] then return false end
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
		if distance < minRange then 
			--Spring.Echo("Can't fire weapon " .. weaponID .. " as target is within minimum range")
			return true 
		end
	end
	local jammable = jammableIDs[weaponID]
	if jammable then
		if targetID then
			local jammed = GetUnitUnderJammer(targetID) and (not IsUnitNARCed(targetID)) and (not IsUnitTAGed(targetID))
			if jammed then
				--Spring.Echo("Can't fire weapon " .. weaponID .. " as target is jammed")
				Spring.SetUnitRulesParam(unitID, "MISSILE_TARGET_JAMMED", Spring.GetGameFrame(), {inlos = true})
				return true 
			else
				Spring.SetUnitRulesParam(targetID, "ENEMY_MISSILE_LOCK", Spring.GetGameFrame(), {inlos = true})
			end
			if largeTurret and unitDef.name == "hturret_arrow" then
				return not (IsUnitNARCed(targetID) or IsUnitTAGed(targetID))
			end
		end
	end
	--Spring.Echo(unitID, weaponID, "Weapon is allowed to fire by BlockShot")
	return false
end

function script.FireWeapon(weaponID)
	if barrels[weaponID] and barrelRecoils[weaponID] then
		Move(barrels[weaponID], z_axis, -barrelRecoils[weaponID], BARREL_SPEED)
		if extend then
			Move(extend, z_axis, -barrelRecoils[weaponID], BARREL_SPEED)
			Explode(piece("casing"), SFX.SMOKE + SFX.FALL)
			drumNum = drumNum + 1
			--Spring.Echo(drumNum)
			Turn(drum, z_axis, math.rad(drumNum * 45), 1)
			if drumNum == 8 then drumNum = 0 end
		end
		WaitForMove(barrels[weaponID], z_axis)
		Move(barrels[weaponID], z_axis, 0, 10)
		if extend then
			Move(extend, z_axis, 0, 10)
		end
	end
	local ammoType = ammoTypes[weaponID]
	if ammoType then
		ChangeAmmo(ammoType, -burstLengths[weaponID]) -- NB. modified burstlength is why I needed to give it 4x as much ammo
	end
	if not missileWeaponIDs[weaponID] and not flareOnShots[weaponID] then
		EmitSfx(flares[weaponID], SFX.CEG + weaponID)
	end
end

function script.Shot(weaponID)
	if missileWeaponIDs[weaponID] then
		EmitSfx(launchPoints[weaponID][currPoints[weaponID]] or launchPoints[weaponID][1], SFX.CEG + weaponID)
		if numMissiles then
			Hide(missiles[weaponID][currPoints[weaponID]])
		end
        currPoints[weaponID] = currPoints[weaponID] + 1
        if currPoints[weaponID] > burstLengths[weaponID] then 
			currPoints[weaponID] = 1
        end
	elseif flareOnShots[weaponID] and flares[weaponID] then
		EmitSfx(flares[weaponID], SFX.CEG + weaponID)
	end
end

function script.EndBurst(weaponID)
	if spinSpeeds[weaponID] then
		StartThread(SpinBarrels, weaponID, false)
	end
end

function script.AimFromWeapon(weaponID) 
	return weaponID == numWeapons + 1 and cockpit or turret
end

function script.QueryWeapon(weaponID) 
	if missileWeaponIDs[weaponID] then
		return launchPoints[weaponID][currPoints[weaponID]] or launchPoints[weaponID][1]
	elseif weaponID == numWeapons + 1 then -- Sight
		return cockpit
	else
		return flares[weaponID] or flares[1]
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
	GG.PlaySoundForTeam(Spring.GetUnitTeam(unitID), "bb_turret_destroyed", 1)
	return 1
end
