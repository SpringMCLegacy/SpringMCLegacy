local CL_Epona = Hover:New{
	name              	= "Epona",
	description         = "Medium Brawler Hovercraft",
	objectName        	= "CL_Epona.s3o",
	corpse				= "CL_Epona_X",
	maxDamage           = 6500,
	mass                = 5000,
	buildCostEnergy     = 50,
	buildCostMetal      = 15400,
	maxVelocity		= 6.5, --130kph/30
	maxReverseVelocity= 3.25,
	acceleration    = 1.8,
	brakeRate       = 0.1,
	turnRate 		= 450,
	
	weapons 		= {	
		[1] = {
			name	= "CMPL",
		},
		[2] = {
			name	= "CMPL",
		},
		[3] = {
			name	= "CMPL",
		},
		[4] = {
			name	= "CMPL",
		},
		[5] = {
			name	= "SSRM4",
		},
	},
	customparams = {
		helptext		= "Armament: 4 x Medium Pulse Laser, 1 x SSRM-4 - Armor: 5 tons",
		heatlimit		= 25,
		turretturnspeed = 75,
		elevationspeed  = 200,
		maxammo = {srm = 80},
		squadsize 		= 3,
    },
}

return lowerkeys({
	["CL_Epona"] = CL_Epona,
})