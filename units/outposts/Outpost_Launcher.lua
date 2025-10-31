local Outpost_Launcher = Outpost:New{
	name              	= "Cruise Missile Launcher",
	description         = "A tactical missile launching platform (cruise missiles sold separately)",
	iconType			= "outpost_launcher",
	maxDamage           = 6000,
	mass                = 4000,
	buildCostMetal      = 50000,
	
	weapons = {
		[1] = {
			name	= "CruiseMissile",
		},
	},
	
	customparams = {
		normaltex		= "unittextures/normals/Outpost_Weapon_Normals.dds",
    },
	sounds = {
		select = "Seismic",
	}
}

return lowerkeys({ ["outpost_launcher"] = Outpost_Launcher })