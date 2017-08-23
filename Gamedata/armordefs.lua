local armorDefs = {
	dropship = {
	},
	beacons = {
		"beacon",
	},
	infantry = {},
	light = {},
	medium = {},
	heavy = {},
	assault = {},
    vehicle = {},
	aero = {},
	vtol = {},
	tower = {},
	walls = {},
	outpost = {},
}

local DEFS = _G.DEFS
for unitName, unitDef in pairs(DEFS.unitDefs) do
	local cp = unitDef.customparams
	local basicType = cp.baseclass

	local typeString
	if basicType == "mech" then
		-- sort into light, medium, heavy, assault
		local mass = unitDef.mass
		local light = mass < 40 * 100
		local medium = not light and mass < 60 * 100
		local heavy = not light and not medium and mass < 80 * 100
		local assault = not light and not medium and not heavy
		local weight = light and "light" or medium and "medium" or heavy and "heavy" or "assault"
		typeString = weight
	elseif basicType then
		typeString = basicType
	elseif cp.dropship then
		typeString = "dropship"
	end
	--Spring.Echo(unitName, typeString)
	if typeString then
		table.insert(armorDefs[typeString], unitName)
	end
end


local system = VFS.Include('gamedata/system.lua')  

return system.lowerkeys(armorDefs)
