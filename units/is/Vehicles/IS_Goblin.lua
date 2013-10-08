local IS_Goblin = LightTank:New{
	name              	= "Goblin",
	description         = "Medium Brawler Tank",
	objectName        	= "IS_Goblin.s3o",
	corpse				= "IS_Goblin_X",
	maxDamage           = 9600,
	mass                = 4500,
	trackWidth			= 23,--width to render the decal
	buildCostEnergy     = 45,
	buildCostMetal      = 10710,
	maxVelocity		= 2.16, --65kph/30
	maxReverseVelocity= 1.6,
	acceleration    = 0.8,
	brakeRate       = 0.1,
	turnRate 		= 450,

	weapons	= {	
		[1] = {
			name	= "LPL",
			OnlyTargetCategory = "notbeacon",
		},
		[2] = {
			name	= "SRM6",
			OnlyTargetCategory = "notbeacon",
		},
		[3] = {
			name	= "MG",
			OnlyTargetCategory = "notbeacon",
		},
		[4] = {
			name	= "MG",
			OnlyTargetCategory = "notbeacon",
		},
		[5] = {
			name	= "AMS",
		},
	},
	
	customparams = {
		helptext		= "Armament: 1 x Large Pulse Laser, 1 x SRM-6, 2 x Machinegun, Laser Anti-Missile System - Armor: 8 tons",
		heatlimit		= 20,
		turrettunspeed  = 75,
		elevationspeed  = 200,
		wheelspeed      = 200,
		maxammo 		= {srm = 120},
    },
}

return lowerkeys({
	["IS_Goblin"] = IS_Goblin,
})