local CL_Donar = VTOL:New{
	name              	= "Donar",
	description         = "Attack VTOL",
	corpse				= "CL_Donar_X",
	maxDamage           = 3600,
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
		helptext		= "Armament: 1 x ER Large Laser, 2 x SSRM-2- Armor: 3 tons FF",
		heatlimit		= 24,
		maxammo = {srm = 120},
		squadsize 		= 2,
    },
}

return lowerkeys({
	["CL_Donar"] = CL_Donar,
})