-- Test Mech Script
-- useful global stuff
unitDefID = Spring.GetUnitDefID(unitID)
unitDef = UnitDefs[unitDefID]
weapons = unitDef.weapons
info = GG.lusHelper[unitDefID]
-- the following have to be non-local for the walkscript include to find them
rad = math.rad
walking = false

-- includes
include "smokeunit.lua"
include ("walks/" .. unitDef.name .. "_walk.lua")

--piece defines
local pelvis, torso = piece ("pelvis", "torso")
local rupperarm, rlowerarm, lupperarm, llowerarm = piece ("rupperarm", "rlowerarm", "lupperarm", "llowerarm")

-- Info from lusHelper gadget
local missileWeaponIDs = info.missileWeaponIDs
local burstLengths = info.burstLengths

local flares = {}
local launchPoints = {}
local currPoints = {}
local currLaunchPoint = 1
 
--Turning/Movement Locals
-- TODO: Generalise from unitdef customParams
local TORSO_SPEED = rad(125)
local ELEVATION_SPEED = rad(165)

for weaponID = 1, #weapons do
	if missileWeaponIDs[weaponID] then
		launchPoints[weaponID] = {}
		currPoints[weaponID] = 1
		for i = 1, burstLengths[weaponID] do
			launchPoints[weaponID][i] = piece("launchpoint_" .. weaponID .. "_" .. i)
		end	
	else
		flares[weaponID] = piece ("flare" .. weaponID) -- NB: Currently relies on missiles being the final weapons!
	end
end

-- constants

local RESTORE_DELAY = Spring.UnitScript.GetLongestReloadTime(unitID) * 2

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
	
	-- TODO: Generalise
	Turn(llowerarm, x_axis, 0, ELEVATION_SPEED)
	Turn(rlowerarm, x_axis, 0, ELEVATION_SPEED)
end

function script.AimWeapon(weaponID, heading, pitch)
	Signal(2 ^ weaponID) -- 2 'to the power of' weapon ID
	SetSignalMask(2 ^ weaponID)
	-- TODO: Generalise
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
	if burstLengths[weaponID] == 1 then
		EmitSfx(flares[weaponID], SFX.CEG + weaponID - 1)
	end
end

function script.Shot(weaponID)
	if missileWeaponIDs[weaponID] then
		EmitSfx(launchPoints[weaponID][currPoints[weaponID]], SFX.CEG + weaponID - 1)
        currPoints[weaponID] = currPoints[weaponID] + 1
        if currPoints[weaponID] > burstLengths[weaponID] then 
			currPoints[weaponID] = 1
        end
	elseif burstLengths[weaponID] > 1 then
		EmitSfx(flares[weaponID], SFX.CEG + weaponID - 1)
	end
end

function script.AimFromWeapon(weaponID) 
	return torso
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
