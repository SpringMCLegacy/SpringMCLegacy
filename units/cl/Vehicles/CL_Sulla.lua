local CL_Sulla = Aero:New{
	name              	= "Sulla",
	description         = "Superiority ASF",
	objectName        	= "CL_Sulla.s3o",
	sightDistance       = 1200,
	radarDistance      	= 1500,
	maxDamage           = 2750,
	mass                = 2000,
	buildCostEnergy     = 20,
	buildCostMetal      = 4500,
	turnRadius		= 2000,
	maxAcc			= 0.18,
	maxBank			= 0.0007,
	maxPitch		= 0.0007,
	maxAileron		= 0.0045,
	maxElevator		= 0.004,
	maxRudder		= 0.002,
	wingAngle		= 0.1,
	wingDrag		= 0.07,
	myGravity		= 0.8,
	
	weapons = {	
		[1] = {
			name	= "Gauss",
			maxAngleDif = 35,
		},
		[2] = {
			name	= "CERPPC",
			maxAngleDif = 35,
		},
		[3] = {
			name	= "CERPPC",
			maxAngleDif = 35,
		},
	},
	
	customparams = {
		helptext		= "Armament: 1 x Gauss Rifle, 2 x PPC - Armor: 2 tons",
		heatlimit		= "15",
		maxammo 		= {gauss = 15},
		squadsize 		= 1,
    },
}

return lowerkeys({ 
	["CL_Sulla"] = CL_Sulla,
})