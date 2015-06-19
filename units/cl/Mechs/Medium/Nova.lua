local Nova = Medium:New{
	name				= "Nova",
	
	customparams = {
		tonnage		= 50,
    },
}

local Prime = Nova:New{
	description         = "Medium Striker",
	
	weapons = {	
		-- put these in via a loop
	},

	customparams = {
		variant         = "Prime",
		speed			= 80,
		price			= 26630,
		heatlimit 		= 36,
		armor			= {type = "standard", tons = 10},
		jumpjets		= 5,
    },
}
for i = 1, 12 do -- yep that's 12 ERMBLs, count 'em!
	Prime.weapons[i] = {name = "CERMBL"}
end

return lowerkeys({
	["HH_Nova_Prime"] = Prime:New(),
	["WF_Nova_Prime"] = Prime:New(),
})