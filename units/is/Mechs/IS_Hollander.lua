local IS_Hollander = Medium:New{
	corpse				= "IS_Hollander_X",
	maxDamage           = 7100,
	mass                = 3500,
	buildCostEnergy     = 35,
	buildCostMetal      = 14900,
	maxVelocity		= 4, --80kph/20

	customparams = {
		heatlimit		= "10",
		torsoturnspeed	= "140",
    },
}

local BZKF3 = IS_Hollander:New{
	name              	= "Hollander BZK-F3",
	description         = "Light-class Long Range Fire Support/Sniper",
	objectName        	= "IS_Hollander_BZKF3.s3o",
	weapons	= {	
		[1] = {
			name	= "Gauss",
			OnlyTargetCategory = "ground",
		},
	},
	
    customparams = {
		helptext		= "Armament: 1 x Gauss Rifle - Armor: 4 tons Ferro-Fibrous",
		maxammo 		= {gauss = 16},
    },
}

local BZKG1 = IS_Hollander:New{
	name              	= "Hollander BZK-G1",
	description         = "Light-class Close Range Brawler",
	objectName        	= "IS_Hollander_BZKG1.s3o",
	weapons = {	
		[1] = {
			name	= "LBX10",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "MBL",
		},
	},
	
	customparams = {
		helptext		= "Armament: 1 x LBX-10, 2 x Medium Laser - Armor: 6 tons Ferro-Fibrous",
		maxammo 		= {ac10 = 20},
    },	
}

return lowerkeys({ 
	["IS_Hollander_BZKF3"] = BZKF3,
	["IS_Hollander_BZKG1"] = BZKG1,
})