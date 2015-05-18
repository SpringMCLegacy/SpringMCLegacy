local CL_Nacon = LightTank:New{
	name              	= "Nacon",
	description         = "Light Brawler Tank",
	objectName        	= "CL_Nacon.s3o",
	corpse				= "CL_Nacon_X",
	maxDamage           = 3000,
	mass                = 2000,
	trackWidth			= 23,--width to render the decal
	buildCostEnergy     = 20,
	buildCostMetal      = 10710,
	maxVelocity		= 5.4, --130kph/30
	maxReverseVelocity= 2.5,
	acceleration    = 1.8,
	brakeRate       = 0.5,
	turnRate 		= 550,

	weapons	= {	
		[1] = {
			name	= "ATM6",
		},
	},
	
	customparams = {
		helptext		= "Armament: 1 x ATM-6 Armor: ",
		heatlimit		= 20,
		turrettunspeed  = 75,
		elevationspeed  = 200,
		wheelspeed      = 300,
		maxammo 		= {atm = 120},
		squadsize 		= 2,
    },
}

return lowerkeys({
	["CL_Nacon"] = CL_Nacon,
})