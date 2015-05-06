local CL_Tyr = Hover:New{
	name              	= "Tyr",
	description         = "Hover APC",
	objectName        	= "CL_Tyr.s3o",
	corpse				= "CL_Tyr_X",
	sightDistance       = 1200,
	radarDistance      	= 2000,
	radarDistanceJam    = 500,
	maxDamage           = 6500,
	mass                = 4500,
	buildCostEnergy     = 30,
	buildCostMetal      = 9270,
	maxVelocity		= 6.5, --130kph/30
	maxReverseVelocity= 3.25,
	acceleration    = 1.8,
	brakeRate       = 0.1,
	turnRate 		= 450,
	
	weapons 		= {	
		[1] = {
			name	= "CERLBL",
		},
		[2] = {
			name	= "SSRM4",
		},
		[3] = {
			name	= "SSRM4",
		},
	},
	customparams = {
		helptext		= "Armament: 1 x ER Large Laser, 2 x SSRM-4 - Armor: 6.5 tons",
		heatlimit		= 25,
		turretturnspeed = 75,
		elevationspeed  = 200,
		maxammo = {srm = 80},
		squadsize 		= 2,
    },
}

return lowerkeys({
	["CL_Tyr"] = CL_Tyr,
})