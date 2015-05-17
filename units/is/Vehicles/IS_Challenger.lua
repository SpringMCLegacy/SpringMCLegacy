local IS_Challenger = Tank:New{
	name              	= "Challenger",
	description         = "Heavy Strike Tank",
	objectName        	= "IS_Challenger.s3o",
	corpse				= "IS_Challenger_X",
	maxDamage           = 22400,
	mass                = 9000,
	trackWidth			= 32,--width to render the decal
	buildCostEnergy     = 70,
	buildCostMetal      = 23850,
	maxVelocity		= 1.8, --54kph/30
	maxReverseVelocity= 1.3,
	acceleration    = 0.6,
	brakeRate       = 0.1,
	turnRate 		= 425,
	
	moveState			= 0,
	
	weapons	= {	
		[1] = {
			name	= "LBX10",
		},
		[2] = {
			name	= "Gauss",
		},
		[3] = {
			name	= "LRM10",
		},
		[4] = {
			name	= "MPL",
		},
		[5] = {
			name	= "MPL",
		},
		[6] = {
			name	= "SSRM2",
		},
		[7] = {
			name	= "SSRM2",
		},
		[8] = {
			name	= "AMS",
		},
	},

	customparams = {
		helptext		= "Armament: 1 x Gauss Rifle, 1 x LBX/10, 1 x LRM-10, 2 x Medium Pulse Laser, 2 x SSRM-2 - Armor: 14 tons",
		heatlimit		= 20,
		turretturnspeed = 75,
		elevationspeed  = 200,
		wheelspeed      = 200,
		barrelrecoildist = {[1] = 5, [2] = 5},
		maxammo 		= {lrm = 180, ac10 = 30, gauss = 30, srm = 80},
		squadsize 		= 2,
	},
}

return lowerkeys({
	["IS_Challenger"] = IS_Challenger,
})