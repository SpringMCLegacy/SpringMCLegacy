local IS_Myrmidon = LightTank:New{
	name              	= "Myrmidon",
	description         = "Medium Sniper Tank",
	objectName        	= "IS_Myrmidon.s3o",
	corpse				= "IS_Myrmidon_X",
	maxDamage           = 5000,
	mass                = 6000,
	trackWidth			= 23,--width to render the decal
	buildCostEnergy     = 45,
	buildCostMetal      = 10710,
	maxVelocity		= 2.8, --86kph/30
	maxReverseVelocity= 1.9,
	acceleration    = 0.8,
	brakeRate       = 0.1,
	turnRate 		= 450,

	weapons	= {	
		[1] = {
			name	= "PPC",
		},
		[2] = {
			name	= "SRM6",
		},
	},
	
	customparams = {
		helptext		= "Armament: 1 x PPC, 1 x SRM-6 - Armor: 5 tons",
		heatlimit		= 20,
		turrettunspeed  = 85,
		elevationspeed  = 200,
		wheelspeed      = 200,
		maxammo 		= {srm = 120},
		barrelrecoildist = {[1] = 5},
		squadsize 		= 2,
    },
}

return lowerkeys({
	["IS_Myrmidon"] = IS_Myrmidon,
})