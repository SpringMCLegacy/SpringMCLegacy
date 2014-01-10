local CL_Iceferret = Medium:New{
	corpse				= "CL_Iceferret_X",
	sightDistance       = 1200,
	radarDistance      	= 2000,
	maxDamage           = 11400,
	mass                = 4500,
	buildCostEnergy     = 45,
	buildCostMetal      = 20020,
	maxVelocity		= 6.5, --130kph/30
	maxReverseVelocity= 3.25,
	acceleration    = 1.8,
	brakeRate       = 0.1,
	turnRate 		= 850,
	
	customparams = {
		heatlimit		= 24,
		torsoturnspeed	= 190,
		maxammo 		= {srm = 120},
    },
}
	
local D = CL_Iceferret:New{
	name              	= "Ice Ferret (Fenris) D",
	description         = "Medium Brawler Mech",
	objectName        	= "CL_Iceferret.s3o",
	weapons	= {	
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
			name	= "SRM6",
		},
		[6] = {
			name	= "AMS",
		},
	},
	customparams = {
		helptext		= "Armament: 4 x Medium Pulse Laser, 1 x SRM-6 - Armor: 7.5 tons Ferro-Fibrous",
    },
}

return lowerkeys({
	["CL_Iceferret_D"] = D,
})