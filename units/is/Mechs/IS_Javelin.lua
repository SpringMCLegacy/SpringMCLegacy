local IS_Javelin = Light:New{
	corpse				= "IS_Javelin_X",
	sightDistance       = 800,
	radarDistance      	= 1500,
	maxDamage           = 8900,
	mass                = 3000,
	buildCostEnergy     = 30,
	buildCostMetal        = 12500,
	maxVelocity		= 4.5, --90kph/20

	customparams = {
		heatlimit		= "10",
		torsoturnspeed	= "195",
		hasbap			= "true",
		hasecm			= "true"
    },
}

local JVN11B = IS_Javelin:New{
	name              	= "Javelin JVN-11B",
	description         = "Light-class E-War Scout",
	objectName        	= "IS_Javelin_JVN11B.s3o",
	weapons	= {	
		[1] = {
			name	= "SRM4",
		},
		[2] = {
			name	= "SRM4",
		},
		[3] = {
			name	= "TAG",
			OnlyTargetCategory = "ground",
		},
	},
		
	customparams = {
		helptext		= "Armament: 2 x SRM-4, 1 x TAG Laser - Armor: 5 tons Standard",
		maxammo 		= {srm = 52},
    },
}

return lowerkeys({
	["IS_Javelin_JVN11B"] = JVN11B,
})