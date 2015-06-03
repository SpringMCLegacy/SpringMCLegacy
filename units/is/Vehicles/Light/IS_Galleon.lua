local IS_Galleon = LightTank:New{
	name              	= "Galleon",
	description         = "Medium Skirmish Tank",
	objectName        	= "IS_Galleon.s3o",
	corpse				= "IS_Galleon_X",
	sightDistance       = 1200,
	radarDistance      	= 2000,
	maxDamage           = 3500,
	mass                = 4500,
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
			name	= "ERMBL",
		},
		[2] = {
			name	= "ERMBL",
		},
		[3] = {
			name	= "ERMBL",
		},
	},
	
	customparams = {
		helptext		= "Armament: 3 x ER Medium Beam Laser - Armor: 3.5 tons",
		heatlimit		= 20,
		turrettunspeed  = 200,
		elevationspeed  = 200,
		wheelspeed      = 200,
		squadsize 		= 4,
    },
}

return lowerkeys({
	["IS_Galleon"] = IS_Galleon,
})