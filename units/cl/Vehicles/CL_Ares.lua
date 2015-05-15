local CL_Ares = LightTank:New{
	name              	= "Ares",
	description         = "Medium Sniper Tank",
	objectName        	= "CL_Ares.s3o",
	corpse				= "CL_Ares_X",
	maxDamage           = 8000,
	mass                = 4000,
	trackWidth			= 24,--width to render the decal
	buildCostEnergy     = 40,
	buildCostMetal      = 10530,
	maxVelocity		= 2.8, --86kph/30
	maxReverseVelocity= 1.6,
	acceleration    = 0.8,
	brakeRate       = 0.1,
	turnRate 		= 450,
	
	weapons = {	
		[1] = {
			name	= "CERLBL",
		},
		[2] = {
			name	= "ATM9",
		},
		[3] = {
			name	= "ATM9",
		},
	},
	customparams = {
		helptext		= "Armament: 1 x ER Large Beam Laser, 2 x ATM-9 - Armor: 4.5 tons",
		heatlimit		= 26,
		turretturnspeed = 75,
		elevationspeed  = 100,
		maxammo = {atm = 120},
		squadsize 		= 3,
    },
}

return lowerkeys({
	["CL_Ares"] = CL_Ares,
})