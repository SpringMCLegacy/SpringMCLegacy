-- Test Tank Script
-- useful global stuff
local ud = UnitDefs[Spring.GetUnitDefID(unitID)] -- unitID is available automatically to all LUS
local weapons = ud.weapons
--defines
local body, turret, launcher = piece ("body", "turret", "launcher")
local floatr, floatl = piece ("floatr", "floatl")
local smokePieces = {body, turret}

-- superfluous for this unit but you may have units which are mixed! 
-- Note you could also just loop through the weapons looking for the right tags...
local missileWeaponIDs = {1, 2} 
 
local launchPoints = {}
local numPoints = {}
local currPoints = {}
 
for _, weaponID in pairs(missileWeaponIDs) do
        launchPoints[weaponID] = {}
        currPoints[weaponID] = 1
        numPoints[weaponID] = WeaponDefs[weapons[weaponID].weaponDef].salvoSize
        for i = 1, numPoints[weaponID] do
                launchPoints[weaponID][i] = piece("launchpoint_" .. weaponID .. "_" .. i)
        end
end

local rad = math.rad

-- constants
local SIG_AIM = 2
local RESTORE_DELAY = Spring.UnitScript.GetLongestReloadTime(unitID) * 2

-- includes
include "smokeunit.lua"

--SFX defines
SMALL_MUZZLEFLASH = SFX.CEG+0

local function Hover()
	while true do
--		EmitSfx(body, SFX.WAKE1) -- Well this doesn't fucking work, why not?!
--		Move(body, y_axis, 10, 5)
--		WaitForMove(body, y_axis)
--		Move(body, y_axis, 0, 5)
--		WaitForMove(body, y_axis)
	end
end

function script.Create()
	StartThread(Hover())
	StartThread(SmokeUnit())
end

function script.StartMoving()
end

function script.StopMoving()
end

local function RestoreAfterDelay(unitID)
	Sleep(RESTORE_DELAY)
	Turn(turret, y_axis, 0, math.rad(50))
	Turn(launcher, x_axis, 0, math.rad(100))
end

function script.AimWeapon(weaponID,heading, pitch)
        Signal(SIG_AIM ^ weaponID) -- this is 2 'to the power of' weapon ID, so 2, 4, 8 etc
        SetSignalMask(SIG_AIM ^ weaponID)
        -- may be a bad idea for all weapons to turn the same turret, but we shall see
	Turn(turret, y_axis, heading, rad(100))
	Turn(launcher, x_axis, -pitch, rad(200))
	WaitForTurn(turret, y_axis)
	StartThread(RestoreAfterDelay)
	return true
end

function script.FireWeapon(weaponID)
end

function script.Shot(weaponID)
        EmitSfx(launchPoints[weaponID][currPoints[weaponID]], SMALL_MUZZLEFLASH)
        currPoints[weaponID] = currPoints[weaponID] + 1
        if currPoints[weaponID] > numPoints[weaponID] then 
                currPoints[weaponID] = 1
        end
end

function script.AimFromWeapon(weaponID) 
	return turret 
end

function script.QueryWeapon(weaponID) 
        return launchPoints[weaponID][currPoints[weaponID]]
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
