local IS_Striker = LightTank:New{
	name              	= "Striker",
	description         = "Light Skirmish Tank",
	objectName        	= "IS_Striker.s3o",
	corpse				= "IS_Striker_X",
	maxDamage           = 3500,
	mass                = 3500,
	trackWidth			= 18,--width to render the decal
	buildCostEnergy     = 45,
	buildCostMetal      = 10710,
	maxVelocity		= 4.2, --who cares
	maxReverseVelocity= 1.6,
	acceleration    = 0.8,
	brakeRate       = 0.1,
	turnRate 		= 450,

	weapons	= {	
		[1] = {
			name	= "LRM15",
		},
		[2] = {
			name	= "SSRM4",
		},
	},
	
	customparams = {
		helptext		= "Armament: 1 x LRM-15, 1 x Streak SRM-4 - Armor: 3 tons",
		heatlimit		= 20,
		turrettunspeed  = 350,
		elevationspeed  = 200,
		wheelspeed      = 200,
		maxammo 		= {lrm = 300, srm = 80},
		squadsize 		= 2,
    },
}

return lowerkeys({
	["IS_Striker"] = IS_Striker,
})