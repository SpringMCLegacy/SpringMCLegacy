local IS_Chevalier = LightTank:New{
	name              	= "Chevalier",
	description         = "Light Strike Tank",
	objectName        	= "IS_Chevalier.s3o",
	corpse				= "IS_Chevalier_X",
	maxDamage           = 6500,
	mass                = 3500,
	trackWidth			= 23,--width to render the decal
	buildCostEnergy     = 45,
	buildCostMetal      = 10710,
	maxVelocity		= 3.2, --96kph/30
	maxReverseVelocity= 1.6,
	acceleration    = 0.8,
	brakeRate       = 0.1,
	turnRate 		= 450,

	weapons	= {	
		[1] = {
			name	= "ERLBL",
		},
		[2] = {
			name	= "SSRM2",
		},
		[3] = {
			name	= "SSRM2",
		},
	},
	
	customparams = {
		helptext		= "Armament: 1 x ER Large Beam Laser, 2 x Streak SRM-2 - Armor: 6.5 tons",
		heatlimit		= 20,
		turrettunspeed  = 200,
		elevationspeed  = 200,
		wheelspeed      = 200,
		maxammo 		= {srm = 120},
		squadsize 		= 2,
    },
}

return lowerkeys({
	["IS_Chevalier"] = IS_Chevalier,
})