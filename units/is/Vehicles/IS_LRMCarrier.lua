local IS_LRMCarrier = LightTank:New{
	name              	= "LRM Carrier",
	description         = "Missile Support Vehicle",
	objectName        	= "IS_LRMCarrier.s3o",
	corpse				= "IS_LRMCarrier_X",
	maxDamage           = 8000,
	mass                = 6000,
	trackWidth			= 23,--width to render the decal
	buildCostEnergy     = 60,
	buildCostMetal      = 10800,
	maxVelocity		= 1.8, --54kph/30
	maxReverseVelocity= 0.9,
	acceleration    = 0.6,
	brakeRate       = 0.1,
	turnRate 		= 300,
	
	weapons	= {	
		[1] = {
			name	= "LRM20",
		},
		[2] = {
			name	= "LRM20",
		},
	},
	
	customparams = {
		helptext		= "Armament: 2 x LRM-20 - Armor: 2 tons",
		heatlimit		= 26,
		turretturnspeed = 25,
		elevationspeed  = 50,
		wheelspeed      = 200,
		maxammo 		= {lrm = 720},
    },
}

return lowerkeys({
	["IS_LRMCarrier"] = IS_LRMCarrier,
})