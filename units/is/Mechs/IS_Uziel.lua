local IS_Uziel = Medium:New{
	corpse				= "IS_Uziel_X",
	maxDamage           = 8000,
	mass                = 5000,
	buildCostEnergy     = 50,
	buildCostMetal        = 17270,
	maxVelocity		= 4.5, --90kph/20
	
	customparams = {
		heatlimit		= "20",
		torsoturnspeed	= "170",
		canjump			= "1",
    },
}

local UZL2S = IS_Uziel:New{
	name              	= "Uziel UZL-2S",
	description         = "Medium-class Sniper",
	objectName        	= "IS_Uziel_UZL2S.s3o",
	weapons	= {	
		[1] = {
			name	= "PPC",
		},
		[2] = {
			name	= "PPC",
		},
		[3] = {
			name	= "SRM6",
		},
		[4] = {
			name	= "MG",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "MG",
			OnlyTargetCategory = "ground",
		},
	},

	customparams = {
		helptext		= "Armament: 2 x PPC, 2 x MG, 1 x SRM-6 - Armor: 5 tons Standard",
		maxammo 		= {srm = 120},
    },
}

return lowerkeys({ 
	["IS_Uziel_UZL2S"] = UZL2S
})