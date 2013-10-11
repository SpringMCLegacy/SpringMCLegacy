local IS_Scorpion = LightTank:New{
	maxDamage           = 3200,
	mass                = 2500,
	trackWidth			= 20,--width to render the decal
	buildCostEnergy     = 25,
	buildCostMetal      = 300,
	maxVelocity		= 2.16, --65kph/20
	maxReverseVelocity= 1.6,
	acceleration    = 1.0,
	brakeRate       = 0.1,
	turnRate 		= 500,

	customparams = {
		heatlimit		= 10,
		turretturnspeed = 75,
		elevationspeed  = 200,
		wheelspeed      = 200,
    },
}
		
local Scorpion_AC5 = IS_Scorpion:New{
	name              	= "Scorpion (AC/5)",
	description         = "Light Strike Tank",
	objectName        	= "IS_Scorpion_AC5.s3o",
	weapons	= {	
		[1] = {
			name	= "AC5",
		},
		[2] = {
			name	= "MG",
		},
		[3] = {
			name	= "MG",
		},
	},
		
    customparams = {
		helptext		= "Armament: 1 x Autocannon/5, 2 x Machinegun - Armor: 2 tons",
		barrelrecoildist = {[1] = 3},
		maxammo 		= {ac5 = 80},
    },
}

local Scorpion_LGauss = {
	name              	= "Scorpion (Light Gauss)",
	description         = "Light Sniper Tank",
	objectName        	= "IS_Scorpion_LGauss.s3o",
	weapons	= {	
		[1] = {
			name	= "LightGauss",
		},
		[2] = {
			name	= "MG",
		},
		[3] = {
			name	= "MG",
		},
	},
		
	customparams = {
		helptext		= "Armament: 1 x Light Gauss Rifle, 2 x Machinegun - Armor: 2 tons",
		barrelrecoildist = {[1] = 3},
		maxammo 		= {gauss = 30},
    },
}

return lowerkeys({ 
	["IS_Scorpion_AC5"] = Scorpion_AC5,
	["IS_Scorpion_LGauss"] = Scorpion_LGauss,
})