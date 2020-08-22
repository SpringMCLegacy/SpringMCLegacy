local Nova = Medium:New{
	name				= "Nova",
	
	customparams = {
		tonnage		= 50,
		cockpitheight	= 12,
		mods			= {"ferrofibrousarmour", "doubleheatsinks"},
		omni			= true,
    },
}

local Prime = Nova:New{
	description         = "Medium Multirole",
	
	weapons = {	
		-- put these in via a loop
	},

	customparams = {
		variant         = "Prime",
		speed			= 80,
		price			= 26630,
		heatlimit 		= 24,
		armor			= 10,
		jumpjets		= 5,
    },
}
for i = 1, 12 do -- yep that's 12 ERMBLs, count 'em!
	Prime.weapons[i] = {name = "CERMBL"}
end

return lowerkeys({
	["WF_Nova_Prime"] = Prime:New(),
})