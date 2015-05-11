local IS_Rommel = LightTank:New{
	name              	= "Rommel",
	description         = "Heavy Brawler Tank",
	objectName        	= "IS_Rommel.s3o",
	corpse				= "IS_Rommel_X",
	maxDamage           = 11500,
	mass                = 6500,
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
			name	= "AC20",
		},
		[2] = {
			name	= "ERSBL",
		},
		[3] = {
			name	= "LRM5",
		},
	},
	
	customparams = {
		helptext		= "Armament: 1 x AC/20, 1 x ER Small Beam Laser, 1 x LRM-5 - Armor: 11.5 tons",
		heatlimit		= 20,
		turrettunspeed  = 85,
		elevationspeed  = 200,
		wheelspeed      = 200,
		maxammo 		= {ac20 = 30, lrm = 120},
		barrelrecoildist = {[1] = 4},
		squadsize 		= 3,
    },
}

return lowerkeys({
	["IS_Rommel"] = IS_Rommel,
})