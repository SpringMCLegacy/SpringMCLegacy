local IS_Mauler = Assault:New{
	corpse				= "IS_Mauler_X",
	maxDamage           = 20600,
	mass                = 9000,
	buildCostEnergy     = 90,
	buildCostMetal        = 28200,
	maxVelocity		= 2.5, --50kph/20

	customparams = {
		torsoturnspeed	= "120",
    },	
}
		
local MAL1R = IS_Mauler:New{
	name              	= "Mauler MAL-1R",
	description         = "Assault-class Long Range Fire Support",
	objectName        	= "IS_Mauler_MAL1R.s3o",
	weapons	= {	
		[1] = {
			name	= "ERLBL",
		},
		[2] = {
			name	= "ERLBL",
		},
		[3] = {
			name	= "AC2",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "AC2",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "AC2",
			OnlyTargetCategory = "ground",
		},
		[6] = {
			name	= "AC2",
			OnlyTargetCategory = "ground",
		},
		[7] = {
			name	= "LRM15",
		},
		[8] = {
			name	= "LRM15",
		},
	},
		
	customparams = {
		helptext		= "Armament: 2 x ER Large Beam Laser, 4 x AC/2, 2 x LRM-15 - Armor: 11.5 tons Ferro-Fibrous",
		heatlimit		= "22",
		maxammo 		= {lrm = 720, ac2 = 300},
    },
}

local MAL3R = IS_Mauler:New{
	name              	= "Mauler MAL-3R",
	description         = "Assault-class Close Range Brawler",
	objectName        	= "IS_Mauler_MAL3R.s3o",
	weapons	= {	
		[1] = {
			name	= "LBX10",
		},
		[2] = {
			name	= "LBX10",
		},
		[3] = {
			name	= "SBL",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "LRM15",
		},
		[5] = {
			name	= "LRM15",
		},
	},
		
	customparams = {
		helptext		= "Armament: 2 x LBX/10, 1 x Small Beam Laser, 2 x LRM-15 - Armor: 16 tons Ferro-Fibrous",
		heatlimit		= "20",
		maxammo 		= {lrm = 720, ac10 = 60},
    },
}
	
return lowerkeys({
	["IS_Mauler_MAL1R"] = MAL1R,
	["IS_Mauler_MAL3R"] = MAL3R,
})