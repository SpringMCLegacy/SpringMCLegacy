local IS_Demolisher = Tank:New{
	name              	= "Demolisher",
	description         = "Heavy Brawler Tank",
	objectName        	= "IS_Demolisher.s3o",
	corpse				= "IS_Demolisher_X",
	maxDamage           = 22400,
	mass                = 8000,
	trackWidth			= 28,--width to render the decal
	buildCostEnergy     = 80,
	buildCostMetal      = 23760,
	maxVelocity		= 1.8, --54kph/30
	maxReverseVelocity= 1.3,
	acceleration    = 0.6,
	brakeRate       = 0.1,
	turnRate 		= 425,
	
	weapons = {	
		[1] = {
			name	= "AC20",
		},
		[2] = {
			name	= "AC20",
		},
	},

	customparams = {
		helptext		= "Armament: 2 x AC/20 - Armor: 13 tons",
		heatlimit		= 10,
		turretturnspeed = 75,
		elevationspeed  = 200,
		wheelspeed      = 200,
		barrelrecoildist = {[1] = 5, [2] = 5},
		maxammo 		= {ac20 = 40},
		squadsize 		= 2,
    },
}

return lowerkeys({
	["IS_Demolisher"] = IS_Demolisher,
})