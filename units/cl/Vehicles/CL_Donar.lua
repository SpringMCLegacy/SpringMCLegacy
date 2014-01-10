local CL_Donar = VTOL:New{
	name              	= "Donar",
	description         = "Attack VTOL",
	objectName        	= "CL_Donar.s3o",
	corpse				= "CL_Donar_X",
	maxDamage           = 5300,
	mass                = 2500,
	buildCostEnergy     = 20,
	buildCostMetal      = 9500,
	airStrafe		= false,
	maxVelocity		= 8.6,
	acceleration	= 0.2,
	brakeRate 		= 1600,
	turnRate 		= 800,
	verticalSpeed	= 1,
	weapons	= {	
		[1] = {
			name	= "CERLBL",
			maxAngleDif = 90,
		},
		[2] = {
			name	= "SSRM2",
			maxAngleDif = 90,
		},
		[3] = {
			name	= "SSRM2",
			maxAngleDif = 90,
		},
	},
	customparams = {
		helptext		= "Armament: 1 x Large Pulse Laser, 2 x SSRM-2- Armor: 3 tons",
		heatlimit		= 24,
		maxmmo = {srm = 120},
    },
}

return lowerkeys({
	["CL_Donar"] = CL_Donar,
})