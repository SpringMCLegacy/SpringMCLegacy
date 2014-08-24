local CL_Elemental = Light:New{
	corpse				= "CL_Elemental_X",
	maxDamage           = 400,
	mass                = 3500,
	buildCostEnergy     = 35,
	buildCostMetal      = 16920,
	maxVelocity		= 4.3, --86kph/20
	maxReverseVelocity= 2.15,
	acceleration    = 1.7,
	brakeRate       = 0.1,
	turnRate 		= 3000,

	customparams = {
		helptext		= "Armament: Small Pulse Laser, SRM-2, Microlaser",
		heatlimit		= 20,
		torsoturnspeed	= 380,
		maxammo 		= {srm = 40},
		canjump			= "1",
    },
}
	
local Prime = CL_Elemental:New{
	name              	= "Elemental",
	description         = "Battle Armour",
	objectName        	= "CL_Elemental.s3o",
	weapons 		= {	
		[1] = {
			name	= "CSPL",
		},
		[2] = {
			name	= "SRM2",
		},
		[3] = {
			name	= "Microlaser",
		},
	},
}
return lowerkeys({
	["CL_Elemental_Prime"] = Prime,
})