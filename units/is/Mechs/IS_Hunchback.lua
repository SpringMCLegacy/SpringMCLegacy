local IS_Hunchback = Medium:New{
	corpse				= "IS_Hunchback_X",
	maxDamage           = 16000,
	mass                = 5000,
	buildCostEnergy     = 55,
	buildCostMetal        = 0,--      = 21100,
	maxVelocity		= 3, --60kph/20

	customparams = {
		torsoturnspeed	= "160",
    },	
}

local HBK4G = IS_Hunchback:New{
	name              	= "Hunchback HBK-4G",
	description         = "Medium-class Close Range Brawler",
	objectName        	= "IS_Hunchback_HBK4G.s3o",
	weapons	= {	
		[1] = {
			name	= "AC20",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "MBL",
			OnlyTargetCategory = "notbeacon",
		},
		[3] = {
			name	= "MBL",
			OnlyTargetCategory = "notbeacon",
		},
		[4] = {
			name	= "SBL",
			OnlyTargetCategory = "ground",
		},
	},
		
	customparams = {
		helptext		= "Armament: 1 x AC/20, 2 x Medium Beam Laser, 1 x Small Beam Laser - Armor: 10 tons Standard",
		heatlimit		= "13",
		maxammo 		= {ac20 = 16},
    },
}

local HBK4P = IS_Hunchback:New{
	name              	= "Hunchback HBK-4P",
	description         = "Medium-class Mid Range Fire Support",
	objectName        	= "IS_Hunchback_HBK4P.s3o",
	weapons = {	
		[1] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
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
		[7] = {
			name	= "MBL",
			OnlyTargetCategory = "notbeacon",
		},
		[8] = {
			name	= "MBL",
			OnlyTargetCategory = "notbeacon",
		},
	},
		
	customparams = {
		helptext		= "Armament: 8 x Medium Beam Laser - Armor: 10 tons Standard",
		heatlimit		= "23",
    },
}

return lowerkeys({
	["IS_Hunchback_HBK4G"] = HBK4G,
	["IS_Hunchback_HBK4P"] = HBK4P,
})