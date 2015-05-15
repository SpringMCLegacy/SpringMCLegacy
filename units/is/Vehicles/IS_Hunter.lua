local IS_Hunter = LightTank:New{
	name              	= "Hunter",
	description         = "Missile Support Vehicle",
	objectName        	= "IS_Hunter.s3o",
	corpse				= "IS_Hunter_X",
	maxDamage           = 2000,
	mass                = 3500,
	trackWidth			= 23,--width to render the decal
	buildCostEnergy     = 40,
	buildCostMetal      = 7000,
	maxVelocity		= 2.8, --86kph/30
	maxReverseVelocity= 1.2,
	acceleration    = 0.8,
	brakeRate       = 0.1,
	turnRate 		= 350,
	
	weapons	= {	
		[1] = {
			name	= "LRM20",
		},
	},
	
	customparams = {
		helptext		= "Armament: 1 x LRM-20 - Armor: 2 tons",
		heatlimit		= 26,
		turretturnspeed = 25,
		elevationspeed  = 50,
		wheelspeed      = 200,
		maxammo 		= {lrm = 520},
		squadsize 		= 1,
    },
}

return lowerkeys({
	["IS_Hunter"] = IS_Hunter,
})