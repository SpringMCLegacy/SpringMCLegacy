local IS_Schrek = Tank:New{
	name              	= "Schrek",
	description         = "Medium Sniper Tank",
	objectName        	= "IS_Schrek.s3o",
	corpse				= "IS_Schrek_X",
	maxDamage           = 7000,
	mass                = 8000,
	trackWidth			= 23,--width to render the decal
	buildCostEnergy     = 80,
	buildCostMetal      = 12780,
	maxVelocity		= 1.8, --54kph/30
	maxReverseVelocity= 1.6,
	acceleration    = 0.6,
	brakeRate       = 0.1,
	turnRate 		= 300,

	weapons	= {	
		[1] = {
			name	= "PPC",
		},
		[2] = {
			name	= "PPC",
		},
		[3] = {
			name	= "PPC",
		},
	},
	
	customparams = {
		helptext		= "Armament: 3 x Particle Projector Cannon - Armor: 7 tons",
		heatlimit		= 30,
		turretturnspeed = 40,
		elevationspeed  = 100,
		barrelrecoildist = {[1] = 5, [2] = 5, [3] = 5},
		wheelspeed      = 200,
		squadsize 		= 2,
    },
}

return lowerkeys({
	["IS_Schrek"] = IS_Schrek,
})