local IS_Badger = LightTank:New{
	name              	= "Badger",
	description         = "APC",
	objectName        	= "IS_Badger.s3o",
	corpse				= "IS_Badger_X",
	maxDamage           = 5000,
	mass                = 3000,
	trackWidth			= 23,--width to render the decal
	buildCostEnergy     = 45,
	buildCostMetal      = 10710,
	maxVelocity		= 3.2, --96kph/30
	maxReverseVelocity= 1.6,
	acceleration    = 0.8,
	brakeRate       = 0.1,
	turnRate 		= 450,

	transportCapacity		= 5,
	transportSize = 1,
	
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
		[4] = {
			name	= "SSRM2",
		},
	},
	
	customparams = {
		helptext		= "Armament: 3 x Medium Beam Laser, 1 x SSRM-2 - Armor: 3.5 tons",
		heatlimit		= 20,
		turrettunspeed  = 500,
		elevationspeed  = 200,
		wheelspeed      = 200,
		unittype 		= "apc",
		maxammo = {srm = 60},
		squadsize 		= 1,
    },
}

return lowerkeys({
	["IS_Badger"] = IS_Badger,
})