local Ballista = LightTank:New{
	name              	= "Ballista",
	description         = "Artillery",
	
	weapons	= {	
		[1] = {
			name	= "Sniper",
			maxAngleDif = 180,
		},
	},
	
	customparams = {
		tonnage			= 80,
		variant         = "",
		speed			= 50,
		price			= 3920,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 7.5},
		maxammo 		= {sniper = 4},
		barrelrecoildist = {[1] = 5},
		squadsize 		= 1,
		artillery 		= true,
    },
}

return lowerkeys({
	--["CC_Ballista"] = Ballista:New(),
	--["DC_Ballista"] = Ballista:New(),
	--["FS_Ballista"] = Ballista:New(),
	--["FW_Ballista"] = Ballista:New(),
	--["LA_Ballista"] = Ballista:New(),
})