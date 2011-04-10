-- Outpost - VehicleDepot Script
-- useful global stuff
local ud = UnitDefs[Spring.GetUnitDefID(unitID)] -- unitID is available automatically to all LUS
local deg, rad = math.deg, math.rad
local currUnitDefID = nil

--piece defines
local base = piece ("base")
local doors = {}
for i = 1, 4 do
	doors[i] = piece ("door" .. i)
end

-- Constants
local DOOR_SPEED = 4

function GetUnitDef(unitDefID)
	currUnitDefID = unitDefID
end

function Doors(open)
	Signal(2)
	SetSignalMask(2)
	local position = 9 * open
	if open == 1 then 
		for i = #doors, 1, -1 do
			Move(doors[i], x_axis, position, DOOR_SPEED)
			WaitForMove(doors[i], x_axis)
		end
	else
		for i = 1, #doors do
			Move(doors[i], x_axis, position, DOOR_SPEED)
			WaitForMove(doors[i], x_axis)
		end
	end
	SetUnitValue(COB.YARD_OPEN, open)
	SetUnitValue(COB.INBUILDSTANCE, open)
	SetUnitValue(COB.BUGGER_OFF, open)
end

function script.Activate()
	StartThread(Doors, 1)
	return 1
end

function script.Deactivate()
	StartThread(Doors, 0)
	return 0
end

function script.QueryBuildInfo() 
	return base
end

function script.QueryNanopiece() 
	return base 
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
