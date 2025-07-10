local Outpost_Launcher = Outpost:New{
	name              	= "Cruise Missile Launcher",
	description         = "Deploys a Tactical Missile Launcher platform for firing Cruise Missiles",
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
		helptext		= "A BIGGER artillery",
    },
	sounds = {
		select = "Seismic",
	}
}

return lowerkeys({ ["outpost_launcher"] = Outpost_Launcher })