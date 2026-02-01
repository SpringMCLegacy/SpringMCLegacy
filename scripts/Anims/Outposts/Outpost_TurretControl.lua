-- Turret Control pieces
local hatch = {}
for i = 1, 4 do
	hatch[i] = piece("hatch" .. i)
end
local pole = {}
for i = 1, 4 do
	pole[i] = piece("pole" .. i)
end

function Deploy()
	for i = 1,4 do
		local signX = i <= 2 and 1 or -1
		local signZ = (i > 1 and i < 4) and -1 or 1
		Move(hatch[i], x_axis, 6 * signX, CRATE_SPEED * 4)
		Move(hatch[i], z_axis, 6 * signZ, CRATE_SPEED * 4)
		WaitForMove(hatch[4], z_axis)
	end
	local poleHeights = {4, 3.25, 10.5, 15.5}
	 for i = 1, #pole do
		Move(pole[i], y_axis, poleHeights[i], CRATE_SPEED * 5)
	end
	WaitForMove(pole[#pole], y_axis)
	Spin(pole[1], y_axis, math.rad(20), math.rad(5))
	SetUnitValue(COB.INBUILDSTANCE, 1)
	-- use our own location, not beaconID
	local x, y, z = Spring.GetUnitPosition(unitID)
	GG.BuildMaskCircle(x, z, 460 * 1.5, 2)
	GG.UpdateTurretSlots(unitID, teamID, 4)
	Spring.UnitScript.SetUnitValue(COB.ACTIVATION, 1)
end
