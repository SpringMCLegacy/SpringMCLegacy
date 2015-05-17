local IS_Manteuffel = LightTank:New{
	name              	= "Manteuffel",
	description         = "Heavy Brawler Tank",
	objectName        	= "IS_Manteuffel.s3o",
	corpse				= "IS_Manteuffel_X",
	radarDistanceJam    = 500,
	maxDamage           = 14000,
	mass                = 7500,
	trackWidth			= 23,--width to render the decal
	buildCostEnergy     = 75,
	buildCostMetal      = 19900,
	maxVelocity		= 2.86, --65kph/30
	maxReverseVelocity= 1.6,
	acceleration    = 0.8,
	brakeRate       = 0.1,
	turnRate 		= 450,
	
	weapons	= {	
		[1] = {
			name	= "RAC5",
		},
		[2] = {
			name	= "ERMBL",
		},
		[3] = {
			name	= "ERMBL",
		},
		[4] = {
			name	= "ERMBL",
		},
	},
	
	customparams = {
		helptext		= "Armament: 1 x Rotary AC/5, 3 x ER Medium Beam Laser - Armor: 11.5 tons",
		heatlimit		= 10,
		turrettunspeed  = 85,
		elevationspeed  = 200,
		wheelspeed      = 200,
		maxammo 		= {ac5 = 300},
		squadsize 		= 2,
    },
}

return lowerkeys({
	["IS_Manteuffel"] = IS_Manteuffel,
})