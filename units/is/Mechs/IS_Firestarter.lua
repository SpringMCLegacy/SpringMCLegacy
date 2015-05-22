local IS_Firestarter = Light:New{
	corpse				= "IS_Firestarter_X",
	maxDamage           = 8800,
	mass                = 3500,
	buildCostEnergy     = 35,
	buildCostMetal        = 12000,
	maxVelocity		= 4.5, --90kph/20

	customparams = {
		heatlimit 		= "10",
		torsoturnspeed	= "225",
		canjump			= "1",
    },
}

local FS9S = IS_Firestarter:New{
	name              	= "Firestarter FS9-S",
	description         = "Light Scout/Skirmisher",
	objectName        	= "IS_Firestarter_FS9S.s3o",
	weapons = {	
		[1] = {
			name	= "Flamer",
		},
		[2] = {
			name	= "Flamer",
		},
		[3] = {
			name	= "Flamer",
		},
		[4] = {
			name	= "Flamer",
		},
		[5] = {
			name	= "MBL",
		},
		[6] = {
			name	= "MBL",
		},
		[7] = {
			name	= "SBL",
		},
		[8] = {
			name	= "AMS",
		},
	},
		
	customparams = {
		helptext		= "Armament: 4 x Flamer, 4 x Medium Beam Laser - Armor: 5.5 tons Standard",
		hasbap 			= "true",
    },
}

return lowerkeys({
	["IS_Firestarter_FS9S"] = FS9S,
})