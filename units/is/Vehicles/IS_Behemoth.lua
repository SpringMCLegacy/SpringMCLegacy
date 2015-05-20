local IS_Behemoth = Tank:New{
	name              	= "Behemoth",
	description         = "Assault Tank",
	objectName        	= "IS_Behemoth.s3o",
	corpse				= "IS_Behemoth_X",
	maxDamage           = 24000,
	mass                = 10000,
	trackWidth			= 32,--width to render the decal
	buildCostEnergy     = 100,
	buildCostMetal      = 23850,
	maxVelocity		= 1.06, --32kph/30
	maxReverseVelocity= 0.4,
	acceleration    = 0.6,
	brakeRate       = 0.1,
	turnRate 		= 425,
	
	moveState			= 0,
	
	weapons	= {	
		[1] = {
			name	= "AC10",
		},
		[2] = {
			name	= "AC10",
		},
		[3] = {
			name	= "LRM20",
		},
		[4] = {
			name	= "SRM6",
		},
		[5] = {
			name	= "SRM6",
		},
	},

	customparams = {
		helptext		= "Armament: 2 x AC/10, 1 x LRM-20, 2 x SRM-6 - Armor: 18 tons",
		heatlimit		= 20,
		turretturnspeed = 75,
		elevationspeed  = 200,
		wheelspeed      = 200,
		barrelrecoildist = {[1] = 3, [2] = 3},
		maxammo 		= {lrm = 400, ac10 = 80, srm = 120},
		squadsize 		= 1,
	},
}

return lowerkeys({
	["IS_Behemoth"] = IS_Behemoth,
})