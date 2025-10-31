local Outpost_Artillery = Outpost:New{
	name              	= "Longtom Artillery Platform",
	description         = "A superheavy artillery platform for long-range bombardment",
	iconType			= "outpost_artillery",
	maxDamage           = 5000,
	mass                = 5000,
	buildCostMetal      = 40000,
	
	radarDistance		= 0,
	radarDistanceJam	= 0,
	
	weapons = {
		[1] = {
			name	= "LongTom",
			badTargetCategory = "mech tank air",
		},
	},
	
	customparams = {
		--maxammo 		= {sniper = 20},
		barrelrecoildist = {[1] = 6},
		normaltex		= "unittextures/normals/Outpost_Weapon_Normals.dds",
	},
	sounds = {
		select = "Seismic",
	}
}

return lowerkeys({ ["outpost_artillery"] = Outpost_Artillery })