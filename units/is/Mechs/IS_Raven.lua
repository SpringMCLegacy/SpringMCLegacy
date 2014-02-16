local IS_Raven = Light:New{
	corpse				= "IS_Raven_X",
	radardistanceJam	= 500,
	maxDamage           = 8000,
	mass                = 3500,
	buildCostEnergy     = 35,
	buildCostMetal        = 13260,
	maxVelocity		= 4.5, --90kph/30

	customparams = {
		heatlimit		= "11",
		torsoturnspeed	= "180",
		hasbap			= "true",
		hasecm			= "true",
    },
}

local RVN3L = IS_Raven:New{
	name              	= "Raven RVN-3L",
	description         = "Light-class Electronic Warfare Scout",
	objectName        	= "IS_Raven_RVN3L.s3o",
	weapons	= {	
		[1] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "NARC",
			OnlyTargetCategory = "narctag",
		},
		[4] = {
			name	= "SRM6",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "TAG",
			OnlyTargetCategory = "narctag",
		},
	},
		
	customparams = {
		helptext		= "Armament: 2 x Medium Beam Laser, 1 x SRM-6, 1 x NARC Launcher, 1 x TAG Laser - Armor: 4.5 tons Ferro-Fibrous",
		maxammo 		= {narc = 20, srm = 120},
    },
}

local RVN4L = IS_Raven:New{
	name              	= "Raven RVN-4L",
	description         = "Light-class Electronic Warfare Scout",
	objectName        	= "IS_Raven_RVN4L.s3o",
	weapons = {	
		[1] = {
			name	= "ERMBL",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "ERMBL",
		},
		[3] = {
			name	= "NARC",
		},
		[4] = {
			name	= "SRM6",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "TAG",
		},
	},

	customparams = {
		helptext		= "Armament: 2 x ER Medium Beam Laser, 1 x SRM-6, 1 x NARC Launcher, 1 x TAG Laser - Armor: 6 tons Standard",
		maxammo 		= {narc = 20, srm = 120},
    },
}

return lowerkeys({
	["IS_Raven_RVN3L"] = RVN3L,
	["IS_Raven_RVN4L"] = RVN4L,
})