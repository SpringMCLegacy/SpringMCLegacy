local IS_Avatar = Heavy:New{
	corpse				= "IS_Avatar_X",
	maxDamage           = 19200,
	mass                = 6000,
	buildCostEnergy     = 65,
	buildCostMetal        = 28820,
	maxVelocity		= 3, --60kph/20
	
	customparams = {
		heatlimit		= "20",
		torsoturnspeed	= "140",
	},
}

local AV10 = IS_Avatar:New{
	name              	= "Avatar AV1-O",
	description         = "Heavy-class Mid Range Fire Support",
	objectName        	= "IS_Avatar_AV1O.s3o",
	weapons	= {	
		[1] = {
			name	= "LBX10",
		},
		[2] = {
			name	= "MPL",
		},
		[3] = {
			name	= "MPL",
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
			name	= "LRM10",
		},
		[7] = {
			name	= "LRM10",
		},
	},

    customparams = {
		helptext		= "Armament: 1 x LBX-10, 2 x Medium Pulse Laser, 2 x Medium Beam Laser, 2 x LRM-10 - Armor: 12 tons Standard",
		hasbap			= "true",
		maxammo 		= {ac10 = 50, lrm = 360},
    },
}

local AV10A = IS_Avatar:New{
	name              	= "Avatar AV1-OA",
	description         = "Heavy-class Short Range Brawler",
	objectName        	= "IS_Avatar_AV1OA.s3o",
	
	weapons 		= {	
		[1] = {
			name	= "AC20",
		},
		[2] = {
			name	= "ERLBL",
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
			name	= "SRM6",
			OnlyTargetCategory = "ground",
		},
		[6] = {
			name	= "SRM6",
			OnlyTargetCategory = "ground",
		},
	},

    customparams = {
		helptext		= "Armament: 1 x AC/20, 1 x ER Large Beam Laser, 2 x Medium Beam Laser, 2 x LRM-10 - Armor: 12 tons Standard",
		hasbap			= "true",
		maxammo 		= {ac20 = 20, srm= 240},
    },
}

return lowerkeys({
	["IS_Avatar_AV1O"] = AV1O,
	["IS_Avatar_AV1OA"] = AV1OA,
})