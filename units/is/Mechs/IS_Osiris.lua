local IS_Osiris = Light:New{
	corpse				= "IS_Osiris_X",
	maxDamage           = 8000,
	mass                = 3000,
	buildCostEnergy     = 30,
	buildCostMetal        = 12780,
	maxVelocity		= 6, --120kph/20

	customparams = {
		heatlimit		= "20",
		torsoturnspeed	= "190",
		canjump			= "1",
    },	
}

local OSR3D = IS_Osiris:New{
	name              	= "Osiris OSR-3D",
	description         = "Light-class Close Range Skirmisher",
	objectName        	= "IS_Osiris_OSR3D.s3o",
	weapons = {	
		[1] = {
			name	= "ERMBL",
		},
		[2] = {
			name	= "ERMBL",
		},
		[3] = {
			name	= "ERMBL",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "ERMBL",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "ERMBL",
			OnlyTargetCategory = "ground",
		},
		[6] = {
			name	= "MG",
			OnlyTargetCategory = "ground",
		},
		[7] = {
			name	= "SRM6",
			OnlyTargetCategory = "ground",
		},
	},
		
	customparams = {
		helptext		= "Armament: 5 x Medium Beam Laser, 1 x Machinegun, 1 x SRM-6 - Armor: 4.5 tons Ferro-Fibrous",
		maxammo 		= {srm = 120},
    },
}

local OSR4D = IS_Osiris:New{
	name              	= "Osiris OSR-4D",
	description         = "Light-class Mid Range Skirmisher",
	objectName        	= "IS_Osiris_OSR4D.s3o",
	weapons = {	
		[1] = {
			name	= "MPL",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "ERMBL",
			OnlyTargetCategory = "ground",
		},
		[3] = {
			name	= "ERMBL",
		},
		[4] = {
			name	= "ERMBL",
		},
		[5] = {
			name	= "ERMBL",
		},
		[6] = {
			name	= "ERMBL",
		},
	},
		
	customparams = {
		helptext		= "Armament: 5 x Medium Beam Laser, 1 x Medium Pulse Laser - Armor: 5.5 tons Ferro-Fibrous",
    },
}

return lowerkeys({
	["IS_Osiris_OSR3D"] = OSR3D,
	["IS_Osiris_OSR4D"] = OSR4D,
})