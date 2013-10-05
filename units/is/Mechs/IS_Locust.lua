local IS_Locust = Light:New{
	corpse				= "IS_Locust_X",
	maxDamage           = 5300,
	mass                = 2000,
	buildCostEnergy     = 20,
	buildCostMetal        = 0,--      = 9200,
	maxVelocity		= 6, --120kph/20
	
	customparams = {
		heatlimit		= "10",
		torsoturnspeed	= "195",
    },
}

local LCT3M = IS_Locust:New{
	name              	= "Locust LCT-3M",
	description         = "Light-class Close Range Scout",
	objectName        	= "IS_Locust_LCT3M.s3o",
	weapons = {	
		[1] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "SBL",
			OnlyTargetCategory = "notbeacon",
		},
		[3] = {
			name	= "SBL",
			OnlyTargetCategory = "notbeacon",
		},
		[4] = {
			name	= "SBL",
			OnlyTargetCategory = "notbeacon",
		},
		[5] = {
			name	= "SBL",
			OnlyTargetCategory = "notbeacon",
		},
		[6] = {
			name	= "AMS",
		},
	},
		
	customparams = {
		helptext		= "Armament: 1 x Medium Beam Laser, 4 x Small Beam Laser - Armor: 3 tons",
    },
}

local LCT5M = IS_Locust:New{
	name              	= "Locust LCT-5M",
	description         = "Light-class Mid Range Scout",
	objectName        	= "IS_Locust_LCT5M.s3o",
	weapons	= {	
		[1] = {
			name	= "ERMBL",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "ERSBL",
			OnlyTargetCategory = "notbeacon",
		},
		[3] = {
			name	= "ERSBL",
			OnlyTargetCategory = "notbeacon",
		},
		[4] = {
			name	= "ERSBL",
			OnlyTargetCategory = "notbeacon",
		},
		[5] = {
			name	= "ERSBL",
			OnlyTargetCategory = "notbeacon",
		},
	},
		
	customparams = {
		helptext		= "Armament: 1 x ER Medium Beam Laser, 4 x ER Small Beam Laser - Armor: 4 tons",
    },
}

return lowerkeys({
	["IS_Locust_LCT3M"] = LCT3M,
	["IS_Locust_LCT5M"] = LCT5M,
})