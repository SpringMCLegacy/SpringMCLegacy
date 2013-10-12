local CL_Firemoth = Light:New{
	corpse				= "CL_Firemoth_X",
	maxDamage           = 3800,
	mass                = 2000,
	buildCostEnergy     = 20,
	buildCostMetal      = 10000,
	maxVelocity		= 8.1, --162kph/30
	maxReverseVelocity= 4.0,
	acceleration    = 2.0,
	brakeRate       = 0.1,
	turnRate 		= 1000,
	
	customparams = {
		heatlimit		= 20,
		torsoturnspeed	= 200,
    },
}
	
local Prime = CL_Firemoth:New{
	name              	= "Fire Moth (Dasher) Prime",
	description         = "Light-class Close Range Harasser",
	objectName        	= "CL_Firemoth_Prime.s3o",
	weapons = {	
		[1] = {
			name	= "CERMBL",
		},
		[2] = {
			name	= "CERMBL",
		},
		[3] = {
			name	= "SRM4",
		},
		[4] = {
			name	= "SRM6",
		},
	},

	customparams = {
		helptext		= "Armament: 2 x ER Medium Beam Laser, 1 x SRM-4, 1 x SRM-6 - Armor: 2 tons Ferro-Fibrous",
		maxammo 		= {srm = 180},
    },
}

local A = CL_Firemoth:New{
	name              	= "Fire Moth (Dasher) A",
	description         = "Light-class Electronic Warfare Scout",
	objectName        	= "CL_Firemoth_A.s3o",
	weapons	= {	
		[1] = {
			name	= "TAG",
		},
		[2] = {
			name	= "SRM4",
		},
	},

	customparams = {
		helptext		= "Armament: 1 x SRM-4, 1 x TAG Laser - Armor: 2 tons Ferro-Fibrous",
		maxammo 		= {srm = 120},
    },
}

return lowerkeys({
	["CL_Firemoth_Prime"] = Prime,
	["CL_Firemoth_A"] = A,
})