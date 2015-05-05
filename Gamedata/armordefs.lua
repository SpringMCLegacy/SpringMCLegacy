local armorDefs = {
	dropships = {
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
	upgrades = {},
}

local DEFS = _G.DEFS
for unitName, unitDef in pairs(DEFS.unitDefs) do
	local cp = unitDef.customparams
	local basicType = cp.unittype
	local towerType = cp.towertype
	if basicType or towerType then
		local typeString = ""
		if basicType == "mech" then
			-- sort into light, medium, heavy, assault
			local mass = unitDef.mass
			local light = mass < 40 * 100
			local medium = not light and mass < 60 * 100
			local heavy = not light and not medium and mass < 80 * 100
			local assault = not light and not medium and not heavy
			local weight = light and "light" or medium and "medium" or heavy and "heavy" or "assault"
			typeString = weight
		elseif basicType == "vehicle" or basicType == "apc" then
			-- sort into vehicle, vtol, aero
			local vtol = unitDef.hoverAttack
			local aero = unitDef.canFly and not vtol
			typeString = vtol and "vtol" or aero and "aero" or "vehicle"
		elseif towerType then
			typeString = "tower"
		elseif basicType == "infantry" then
			typeString = basicType
		end
		--Spring.Echo(unitName, typeString)
		table.insert(armorDefs[typeString], unitName)
	elseif cp.dropship then
		table.insert(armorDefs["dropships"], unitName)
	elseif cp.upgrade then
		table.insert(armorDefs["upgrades"], unitName)
	elseif cp.wall then
		table.insert(armorDefs["walls"], unitName)
	end
end


local system = VFS.Include('gamedata/system.lua')  

return system.lowerkeys(armorDefs)
