local IS_Catapult = Heavy:New{
	corpse				= "IS_Catapult_X",
	maxDamage           = 16000,
	mass                = 6500,
	buildCostEnergy     = 65,
	buildCostMetal        = 28820,
	maxVelocity		= 3, --60kph/20

	customparams = {
		canjump			= "1",
		torsoturnspeed	= "125",
    },
}
	
local CPLTC1 = IS_Catapult:New{
	name              	= "Catapult CPLT-C1",
	description         = "Heavy-class Long Range Missile Support",
	objectName        	= "IS_Catapult_CPLTC1.s3o",
	weapons	= {	
		[1] = {
			name	= "LRM15",
		},
		[2] = {
			name	= "LRM15",
		},
		[3] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[6] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
	},
		
	customparams = {
		helptext		= "Armament: 2 x LRM-15, 4 x Medium Beam Laser - Armor: 10 tons Standard",
		heatlimit		= "15",
		maxammo 		= {lrm = 360},
    },
}

local CPLTC4 = IS_Catapult:New{
	name              	= "Catapult CPLT-C4",
	description         = "Heavy-class Long Range Missile Support",
	objectName        	= "IS_Catapult_CPLTC4.s3o",
	weapons 		= {	
		[1] = {
			name	= "LRM20",
		},
		[2] = {
			name	= "LRM20",
		},
		[3] = {
			name	= "ERSBL",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "ERSBL",
			OnlyTargetCategory = "ground",
		},
	},

	customparams = {
		helptext		= "Armament: 2 x LRM-20, 2 x Medium Beam Laser - Armor: 10 tons Standard",
		heatlimit		= "20",
		maxammo 		= {lrm = 720},
    },
}
	
return lowerkeys({
	["IS_Catapult_CPLTC1"] = CPLTC1,
	["IS_Catapult_CPLTC4"] = CPLTC4,
})