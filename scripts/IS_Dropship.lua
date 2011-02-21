-- Test Mech Script
-- useful global stuff
local ud = UnitDefs[Spring.GetUnitDefID(unitID)] -- unitID is available automatically to all LUS
local weapons = ud.weapons
local deg, rad = math.deg, math.rad

--piece defines
local hull, pad, beam = piece ("hull", "pad", "beam")
--Weapon 1 and 2, dual lasers
local turret1_joint, turret1, turret1_flare1, turret1_flare2 = piece ("turret1_joint", "turret1", "turret1_flare1", "turret1_flare2")
--Weapon 3 and 4, dual lasers
local turret2_joint, turret2, turret2_flare1, turret2_flare2 = piece ("turret2_joint", "turret2", "turret2_flare1", "turret2_flare2")
--Weapon 5 and 6, dual lasers
local turret3_joint, turret3, turret3_flare1, turret3_flare2 = piece ("turret3_joint", "turret3", "turret3_flare1", "turret3_flare2")
--Weapon 7 and 8, dual lasers
local turret4_joint, turret4, turret4_flare1, turret4_flare2 = piece ("turret4_joint", "turret4", "turret4_flare1", "turret4_flare2")
--Weapon 9, PPC
local ppc1_platform, ppc1_turret, ppc1_mantlet, ppc1_barrel, ppc1_flare = piece ("ppc1_platform", "ppc1_turret", "ppc1_mantlet", "ppc1_barrel", "ppc1_flare")
--Weapon 10, PPC
local ppc2_platform, ppc2_turret, ppc2_mantlet, ppc2_barrel, ppc2_flare = piece ("ppc2_platform", "ppc2_turret", "ppc2_mantlet", "ppc2_barrel", "ppc2_flare")
--Weapon 11, PPC
local ppc3_platform, ppc3_turret, ppc3_mantlet, ppc3_barrel, ppc3_flare = piece ("ppc3_platform", "ppc3_turret", "ppc3_mantlet", "ppc3_barrel", "ppc3_flare")
--Weapon 12, PPC
local ppc4_platform, ppc4_turret, ppc4_mantlet, ppc4_barrel, ppc4_flare = piece ("ppc4_platform", "ppc4_turret", "ppc4_mantlet", "ppc4_barrel", "ppc4_flare")
--Weapon 13, LRM
local launcher1_joint, launcher1 = piece ("launcher1_joint", "launcher1")
--Weapon 14, LRM
local launcher2_joint, launcher2 = piece ("launcher2_joint", "launcher2")
--Weapon 15, LRM
local launcher3_joint, launcher3 = piece ("launcher3_joint", "launcher3")
--Weapon 16, LRM
local launcher4_joint, launcher4 = piece ("launcher4_joint", "launcher4")
--ERMBLs
local laser1, laser2, laser3, laser4, laser5, laser6, laser7, laser8 = piece ("laser1", "laser2", "laser3", "laser4", "laser5", "laser6", "laser7", "laser8")
--LBLs
local laser9, laser10, laser11, laser12 = piece ("laser9", "laser10", "laser11", "laser12")

local missileWeaponIDs = {[13] = true, [14] = true, [15] = true, [16] = true}
 
local launchPoints = {}
local numPoints = {}
local currPoints = {}
 
--Turning/Movement Locals
local TURRET_SPEED = rad(100)
local ELEVATION_SPEED = rad(200)
local TURRET_SPEED_FAST = rad(500)

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
MEDIUM_MUZZLEFLASH = SFX.CEG+0
PPC_MUZZLEFLASH = SFX.CEG+1
MG_MUZZLEFLASH = SFX.CEG+2

function script.Create()
	StartThread(SmokeUnit, {hull})
	--Turning offset turrets to their positions
	Turn(turret1, y_axis, 0, TURRET_SPEED_FAST)
	Turn(turret2, y_axis, rad(-90), TURRET_SPEED_FAST)
	Turn(turret3, y_axis, rad(180), TURRET_SPEED_FAST)
	Turn(turret4, y_axis, rad(90), TURRET_SPEED_FAST)
	Turn(ppc1_turret, y_axis, 0, TURRET_SPEED_FAST)
	Turn(ppc2_turret, y_axis, rad(-90), TURRET_SPEED_FAST)
	Turn(ppc3_turret, y_axis, rad(180), TURRET_SPEED_FAST)
	Turn(ppc4_turret, y_axis, rad(90), TURRET_SPEED_FAST)
	Turn(launcher1, y_axis, rad(-45), TURRET_SPEED_FAST)
	Turn(launcher2, y_axis, rad(-135), TURRET_SPEED_FAST)
	Turn(launcher3, y_axis, rad(135), TURRET_SPEED_FAST)
	Turn(launcher4, y_axis, rad(45), TURRET_SPEED_FAST)
	Turn(laser1, y_axis, 0, TURRET_SPEED_FAST)
	Turn(laser2, y_axis, 0, TURRET_SPEED_FAST)
	Turn(laser3, y_axis, rad(-90), TURRET_SPEED_FAST)
	Turn(laser4, y_axis, rad(-90), TURRET_SPEED_FAST)
	Turn(laser5, y_axis, rad(180), TURRET_SPEED_FAST)
	Turn(laser6, y_axis, rad(180), TURRET_SPEED_FAST)
	Turn(laser7, y_axis, rad(90), TURRET_SPEED_FAST)
	Turn(laser8, y_axis, rad(90), TURRET_SPEED_FAST)
	Turn(laser9, y_axis, rad(-45), TURRET_SPEED_FAST)
	Turn(laser10, y_axis, rad(-135), TURRET_SPEED_FAST)
	Turn(laser11, y_axis, rad(135), TURRET_SPEED_FAST)
	Turn(laser12, y_axis, rad(45), TURRET_SPEED_FAST)
end

function script.Activate()
	SetUnitValue(COB.YARD_OPEN, 1)
	SetUnitValue(COB.INBUILDSTANCE, 1)
	SetUnitValue(COB.BUGGER_OFF, 1)
	--StartThread(build_animation)
	return 1
end

function script.Deactivate()
	SetUnitValue(COB.YARD_OPEN, 0)
	SetUnitValue(COB.INBUILDSTANCE, 0)
	SetUnitValue(COB.BUGGER_OFF, 0)
	return 0
end

function QueryBuildInfo() 
	return pad
end

function QueryNanopiece() 
	return beam 
end

local function RestoreAfterDelay(unitID)
	Sleep(RESTORE_DELAY)
	Turn(turret1, y_axis, 0, TURRET_SPEED)
	Turn(turret1, x_axis, 0, TURRET_SPEED)
	Turn(turret2, y_axis, rad(-90), TURRET_SPEED)
	Turn(turret2, x_axis, 0, TURRET_SPEED)
	Turn(turret3, y_axis, rad(180), TURRET_SPEED)
	Turn(turret3, x_axis, 0, TURRET_SPEED)
	Turn(turret4, y_axis, rad(90), TURRET_SPEED)
	Turn(turret4, x_axis, 0, TURRET_SPEED)
	Turn(ppc1_turret, y_axis, 0, TURRET_SPEED)
	Turn(ppc1_mantlet, x_axis, 0, TURRET_SPEED)
	Turn(ppc2_turret, y_axis, rad(-90), TURRET_SPEED)
	Turn(ppc2_mantlet, x_axis, 0, TURRET_SPEED)
	Turn(ppc3_turret, y_axis, rad(180), TURRET_SPEED)
	Turn(ppc3_mantlet, x_axis, 0, TURRET_SPEED)
	Turn(ppc4_turret, y_axis, rad(90), TURRET_SPEED)
	Turn(ppc4_mantlet, x_axis, 0, TURRET_SPEED)
	Turn(launcher1, y_axis, rad(-45), TURRET_SPEED)
	Turn(launcher1, x_axis, 0, TURRET_SPEED)
	Turn(launcher2, y_axis, rad(-135), TURRET_SPEED)
	Turn(launcher2, x_axis, 0, TURRET_SPEED)
	Turn(launcher3, y_axis, rad(135), TURRET_SPEED)
	Turn(launcher3, x_axis, 0, TURRET_SPEED)
	Turn(launcher4, y_axis, rad(45), TURRET_SPEED)
	Turn(launcher4, x_axis, 0, TURRET_SPEED)
	Turn(laser1, y_axis, 0, TURRET_SPEED)
	Turn(laser2, y_axis, 0, TURRET_SPEED)
	Turn(laser3, y_axis, rad(-90), TURRET_SPEED)
	Turn(laser4, y_axis, rad(-90), TURRET_SPEED)
	Turn(laser5, y_axis, rad(180), TURRET_SPEED)
	Turn(laser6, y_axis, rad(180), TURRET_SPEED)
	Turn(laser7, y_axis, rad(90), TURRET_SPEED)
	Turn(laser8, y_axis, rad(90), TURRET_SPEED)
	Turn(laser9, y_axis, rad(-45), TURRET_SPEED)
	Turn(laser10, y_axis, rad(-135), TURRET_SPEED)
	Turn(laser11, y_axis, rad(135), TURRET_SPEED)
	Turn(laser12, y_axis, rad(45), TURRET_SPEED)
end

function script.AimWeapon(weaponID, heading, pitch)
	Signal(SIG_AIM ^ weaponID) -- 2 'to the power of' weapon ID
    SetSignalMask(SIG_AIM ^ weaponID)
		if weaponID == 1 then
			Turn(turret1, y_axis, heading, TURRET_SPEED)
			Turn(turret1, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(turret1, y_axis)
		elseif weaponID == 2 then	
			Turn(turret1, y_axis, heading, TURRET_SPEED)
			Turn(turret1, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(turret1, y_axis)
		elseif weaponID == 3 then
			Turn(turret2, y_axis, heading, TURRET_SPEED)
			Turn(turret2, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(turret2, y_axis)
		elseif weaponID == 4 then
			Turn(turret2, y_axis, heading, TURRET_SPEED)
			Turn(turret2, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(turret2, y_axis)
		elseif weaponID == 5 then
			Turn(turret3, y_axis, heading, TURRET_SPEED)
			Turn(turret3, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(turret3, y_axis)
		elseif weaponID == 6 then
			Turn(turret3, y_axis, heading, TURRET_SPEED)
			Turn(turret3, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(turret3, y_axis)
		elseif weaponID == 7 then
			Turn(turret4, y_axis, heading, TURRET_SPEED)
			Turn(turret4, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(turret4, y_axis)
		elseif weaponID == 8 then
			Turn(turret4, y_axis, heading, TURRET_SPEED)
			Turn(turret4, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(turret4, y_axis)
		elseif weaponID == 9 then
			Turn(ppc1_turret, y_axis, heading, TURRET_SPEED)
			Turn(ppc1_mantlet, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(ppc1_turret, y_axis)
		elseif weaponID == 10 then
			Turn(ppc2_turret, y_axis, heading, TURRET_SPEED)
			Turn(ppc2_mantlet, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(ppc2_turret, y_axis)
		elseif weaponID == 11 then
			Turn(ppc3_turret, y_axis, heading, TURRET_SPEED)
			Turn(ppc3_mantlet, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(ppc3_turret, y_axis)
		elseif weaponID == 12 then
			Turn(ppc4_turret, y_axis, heading, TURRET_SPEED)
			Turn(ppc4_mantlet, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(ppc4_turret, y_axis)
		elseif weaponID == 13 then
			Turn(launcher1, y_axis, heading, TURRET_SPEED)
			Turn(launcher1, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(launcher1, y_axis)
		elseif weaponID == 14 then
			Turn(launcher2, y_axis, heading, TURRET_SPEED)
			Turn(launcher2, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(launcher2, y_axis)
		elseif weaponID == 15 then
			Turn(launcher3, y_axis, heading, TURRET_SPEED)
			Turn(launcher3, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(launcher3, y_axis)
		elseif weaponID == 16 then
			Turn(launcher4, y_axis, heading, TURRET_SPEED)
			Turn(launcher4, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(launcher4, y_axis)	
		elseif weaponID == 17 then
			Turn(laser1, y_axis, heading, TURRET_SPEED)
			Turn(laser1, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(laser1, y_axis)
		elseif weaponID == 18 then	
			Turn(laser2, y_axis, heading, TURRET_SPEED)
			Turn(laser2, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(laser2, y_axis)
		elseif weaponID == 19 then
			Turn(laser3, y_axis, heading, TURRET_SPEED)
			Turn(laser3, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(laser3, y_axis)
		elseif weaponID == 20 then
			Turn(laser4, y_axis, heading, TURRET_SPEED)
			Turn(laser4, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(laser4, y_axis)
		elseif weaponID == 21 then
			Turn(laser5, y_axis, heading, TURRET_SPEED)
			Turn(laser5, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(laser5, y_axis)
		elseif weaponID == 22 then
			Turn(laser6, y_axis, heading, TURRET_SPEED)
			Turn(laser6, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(laser6, y_axis)
		elseif weaponID == 23 then
			Turn(laser7, y_axis, heading, TURRET_SPEED)
			Turn(laser7, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(laser7, y_axis)
		elseif weaponID == 24 then
			Turn(laser8, y_axis, heading, TURRET_SPEED)
			Turn(laser8, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(laser8, y_axis)
		elseif weaponID == 25 then
			Turn(laser9, y_axis, heading, TURRET_SPEED)
			Turn(laser9, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(laser9, y_axis)
		elseif weaponID == 26 then
			Turn(laser10, y_axis, heading, TURRET_SPEED)
			Turn(laser10, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(laser10, y_axis)
		elseif weaponID == 27 then
			Turn(laser11, y_axis, heading, TURRET_SPEED)
			Turn(laser11, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(laser11, y_axis)
		elseif weaponID == 28 then
			Turn(laser12, y_axis, heading, TURRET_SPEED)
			Turn(laser12, x_axis, -pitch, ELEVATION_SPEED)
			WaitForTurn(laser12, y_axis)
		end
	StartThread(RestoreAfterDelay)
	return true
end

function script.FireWeapon(weaponID)
		if weaponID == 1 then
			EmitSfx(turret1_flare1, MEDIUM_MUZZLEFLASH)
		elseif weaponID == 2 then
			EmitSfx(turret1_flare2, MEDIUM_MUZZLEFLASH)
		elseif weaponID == 3 then
			EmitSfx(turret2_flare1, MEDIUM_MUZZLEFLASH)
		elseif weaponID == 4 then
			EmitSfx(turret2_flare2, MEDIUM_MUZZLEFLASH)
		elseif weaponID == 5 then
			EmitSfx(turret3_flare1, MEDIUM_MUZZLEFLASH)
		elseif weaponID == 6 then
			EmitSfx(turret3_flare2, MEDIUM_MUZZLEFLASH)
		elseif weaponID == 7 then
			EmitSfx(turret4_flare1, MEDIUM_MUZZLEFLASH)
		elseif weaponID == 8 then
			EmitSfx(turret4_flare2, MEDIUM_MUZZLEFLASH)
		elseif weaponID == 9 then
			EmitSfx(ppc1_flare, PPC_MUZZLEFLASH)
		elseif weaponID == 10 then
			EmitSfx(ppc2_flare, PPC_MUZZLEFLASH)
		elseif weaponID == 11 then
			EmitSfx(ppc3_flare, PPC_MUZZLEFLASH)
		elseif weaponID == 12 then
			EmitSfx(ppc4_flare, PPC_MUZZLEFLASH)
		elseif weaponID == 17 then
			EmitSfx(laser1, MG_MUZZLEFLASH)
		elseif weaponID == 18 then
			EmitSfx(laser2, MG_MUZZLEFLASH)
		elseif weaponID == 19 then
			EmitSfx(laser3, MG_MUZZLEFLASH)
		elseif weaponID == 20 then
			EmitSfx(laser4, MG_MUZZLEFLASH)
		elseif weaponID == 21 then
			EmitSfx(laser5, MG_MUZZLEFLASH)
		elseif weaponID == 22 then
			EmitSfx(laser6, MG_MUZZLEFLASH)
		elseif weaponID == 23 then
			EmitSfx(laser7, MG_MUZZLEFLASH)
		elseif weaponID == 24 then
			EmitSfx(laser8, MG_MUZZLEFLASH)
		elseif weaponID == 25 then
			EmitSfx(laser9, MG_MUZZLEFLASH)
		elseif weaponID == 26 then
			EmitSfx(laser10, MG_MUZZLEFLASH)
		elseif weaponID == 27 then
			EmitSfx(laser11, MG_MUZZLEFLASH)
		elseif weaponID == 28 then
			EmitSfx(laser12, MG_MUZZLEFLASH)
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
	return hull
end

function script.QueryWeapon(weaponID) 
	if missileWeaponIDs[weaponID] then
		return launchPoints[weaponID][currPoints[weaponID]]
	else
		if weaponID == 1 then
			return turret1_flare1
		elseif weaponID == 2 then
			return turret1_flare2
		elseif weaponID == 3 then
			return turret2_flare1
		elseif weaponID == 4 then
			return turret2_flare2
		elseif weaponID == 5 then
			return turret3_flare1
		elseif weaponID == 6 then
			return turret3_flare2
		elseif weaponID == 7 then
			return turret4_flare1
		elseif weaponID == 8 then
			return turret4_flare2
		elseif weaponID == 9 then
			return ppc1_flare
		elseif weaponID == 10 then
			return ppc2_flare
		elseif weaponID == 11 then
			return ppc3_flare
		elseif weaponID == 12 then
			return ppc4_flare
		elseif weaponID == 17 then
			return laser1
		elseif weaponID == 18 then
			return laser2
		elseif weaponID == 19 then
			return laser3
		elseif weaponID == 20 then
			return laser4
		elseif weaponID == 21 then
			return laser5
		elseif weaponID == 22 then
			return laser6
		elseif weaponID == 23 then
			return laser7
		elseif weaponID == 24 then
			return laser8
		elseif weaponID == 25 then
			return laser9
		elseif weaponID == 26 then
			return laser10
		elseif weaponID == 27 then
			return laser11
		elseif weaponID == 28 then
			return laser12
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
