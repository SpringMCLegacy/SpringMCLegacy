local IS_Warhammer = Heavy:New{
	corpse				= "IS_Warhammer_X",
	maxDamage           = 16000,
	mass                = 7000,
	buildCostEnergy     = 70,
	buildCostMetal        = 0,--      = 24000,
	maxVelocity		= 3, --60kph/2
	
	customparams = {
		torsoturnspeed	= "120",
    },
}

local WHM6R = IS_Warhammer:New{
	name              	= "Warhammer WHM-6R",
	description         = "Heavy-class Mid Range Fire Support",
	objectName        	= "IS_Warhammer_WHM6R.s3o",
	weapons = {	
		[1] = {
			name	= "PPC",
		},
		[2] = {
			name	= "PPC",
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
			name	= "SBL",
			OnlyTargetCategory = "ground",
		},
		[6] = {
			name	= "SBL",
			OnlyTargetCategory = "ground",
		},
		[7] = {
			name	= "MG",
			OnlyTargetCategory = "ground",
		},
		[8] = {
			name	= "MG",
			OnlyTargetCategory = "ground",
		},
		[9] = {
			name	= "SRM6",
			OnlyTargetCategory = "ground",
		},
	},
		
	customparams = {
		helptext		= "Armament: 2 x PPC, 2 x Medium Beam Laser, 2 x Small Beam Laser, 2 x Machinegun, 1 x SRM-6 - Armor: 10 tons Standard",
		heatlimit		= "18",
		maxammo 		= {srm = 120},
    },
}

local WHM7A = IS_Warhammer:New{
	name              	= "Warhammer WHM-7A",
	description         = "Heavy-class Long Range Fire Support",
	objectName        	= "IS_Warhammer_WHM7A.s3o",
	weapons = {	
		[1] = {
			name	= "ERPPC",
		},
		[2] = {
			name	= "ERPPC",
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
			name	= "ERMBL",
			OnlyTargetCategory = "ground",
		},
		[7] = {
			name	= "SPL",
			OnlyTargetCategory = "ground",
		},
		[8] = {
			name	= "SPL",
			OnlyTargetCategory = "ground",
		},
		[9] = {
			name	= "SRM6",
			OnlyTargetCategory = "ground",
		},
	},
		
	customparams = {
		helptext		= "Armament: 2 x ER PPC, 4 x ER Medium Beam Laser, 2 x Small Pulse Laser, 1 x SRM-6 - Armor: 10 tons Standard",
		heatlimit		= "32",
		maxammo 		= {srm = 120},
    },
}

return lowerkeys({
	["IS_Warhammer_WHM6R"] = WHM6R,
	["IS_Warhammer_WHM7A"] = WHM7A,
})