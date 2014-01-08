local CL_Stormcrow = Medium:New{
	corpse				= "CL_Stormcrow_X",
	maxDamage           = 18200,
	mass                = 5500,
	buildCostEnergy     = 55,
	buildCostMetal      = 27040,
	maxVelocity		= 4.85, --97kph/30
	maxReverseVelocity= 2.43,
	acceleration    = 1.5,
	brakeRate       = 0.1,
	turnRate 		= 800,
	
	customparams = {
		heatlimit		= 20,
		torsoturnspeed	= 160,
    },
}
	
local A = CL_Stormcrow:New{
	name              	= "Stormcrow (Ryoken) A",
	description         = "Medium Missile Support Mech",
	objectName        	= "CL_Stormcrow.s3o",
	weapons	= {	
		[1] = {
			name	= "ArtemisLRM20",
		},
		[2] = {
			name	= "CMPL",
		},
		[3] = {
			name	= "CMPL",
		},
		[4] = {
			name	= "CMPL",
		},
		[5] = {
			name	= "CMPL",
		},
		[6] = {
			name	= "SRM4",
		},
		[7] = {
			name	= "SRM4",
		},
	},

	customparams = {
		helptext		= "Armament: 1 x LRM-20, 4 x Medium Pulse Laser, 2 x SRM-4 - Armor: 9.5 tons",
    },
}

return lowerkeys({
	["CL_Stormcrow_A"] = A,
})