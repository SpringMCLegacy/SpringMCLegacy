local Outpost_Artillery = Outpost:New{
	name              	= "Sniper Artillery Platform",
	description         = "Deploys a long-range heavy artillery platform",
	iconType			= "outpost_artillery",
	maxDamage           = 5000,
	mass                = 5000,
	buildCostMetal      = 10000,
	
	radarDistance		= 0,
	radarDistanceJam	= 0,
	
	weapons = {
		[1] = {
			name	= "Sniper",
		},
	},
	
	customparams = {
		helptext		= "A big artillery",
		--maxammo 		= {sniper = 20},
		barrelrecoildist = {[1] = 6},
    },
	sounds = {
		select = "Seismic",
	}
}

return lowerkeys({ ["outpost_artillery"] = Outpost_Artillery })