local IS_Flea = Light:New{
	corpse				= "IS_Flea_X",
	sightDistance       = 800,
	radarDistance      	= 1500,
	maxDamage           = 4800,
	mass                = 2000,
	buildCostEnergy     = 20,
	buildCostMetal        = 0,--      = 9200,
	maxVelocity		= 6, --120kph/20

	customparams = {
		heatlimit		= "10",
		torsoturnspeed	= "195",
    },
}

local FLE17 = IS_Flea:New{
	name              	= "Flea FLE-17",
	description         = "Light-class Close Range Harasser",
	objectName        	= "IS_Flea_FLE17.s3o",
	weapons	= {	
		[1] = {
			name	= "MPL",
		},
		[2] = {
			name	= "MPL",
		},
		[3] = {
			name	= "SBL",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "SBL",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "Flamer",
			OnlyTargetCategory = "ground",
		},
	},
		
	customparams = {
		helptext		= "Armament: 2 x Medium Pulse Laser, 2 x Small Beam Laser, 1 x Flamer - Armor: 3 tons Standard",
    },
}

return lowerkeys({
	["IS_Flea_FLE17"] = FLE17,
})