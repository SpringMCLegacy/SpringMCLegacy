local IS_Po = LightTank:New{
	name              	= "Po",
	description         = "Medium Strike Tank",
	objectName        	= "IS_Po.s3o",
	corpse				= "IS_Po_X",
	maxDamage           = 10500,
	mass                = 6000,
	trackWidth			= 23,--width to render the decal
	buildCostEnergy     = 60,
	buildCostMetal      = 10710,
	maxVelocity		= 2.16, --65kph/30
	maxReverseVelocity= 1.6,
	acceleration    = 0.8,
	brakeRate       = 0.1,
	turnRate 		= 450,

	weapons	= {	
		[1] = {
			name	= "AC10",
		},
		[2] = {
			name	= "MG",
		},
		[3] = {
			name	= "MG",
		},
	},
	
	customparams = {
		helptext		= "Armament: 1 x AC/10, 2 x Machinegun - Armor: 10.5 tons",
		heatlimit		= 20,
		turrettunspeed  = 85,
		elevationspeed  = 200,
		wheelspeed      = 200,
		maxammo 		= {ac10 = 60},
		barrelrecoildist = {[1] = 5},
		squadsize 		= 3,
    },
}

return lowerkeys({
	["IS_Po"] = IS_Po,
})