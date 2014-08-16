local IS_Sparrowhawk = Aero:New{
	name              	= "Sparrowhawk",
	description         = "Light Interceptor ASF",
	objectName        	= "IS_Sparrowhawk.s3o",
	sightDistance       = 1200,
	radarDistance      	= 1500,
	maxDamage           = 350,
	mass                = 2000,
	buildCostEnergy     = 20,
	buildCostMetal      = 4500,
	turnRadius		= 1000,
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
			name	= "MBL",
			maxAngleDif = 35,
		},
		[2] = {
			name	= "MBL",
			maxAngleDif = 35,
		},
		[3] = {
			name	= "ERSBL",
			maxAngleDif = 35,
		},
		[4] = {
			name	= "ERSBL",
			maxAngleDif = 35,
		},
	},
	
	customparams = {
		helptext		= "Armament: 2 x Medium Pulse Laser, 2 x ER Small Beam Laser - Armor: 2 tons",
		heatlimit		= "15",
		squadsize 		= 2,
    },
}

return lowerkeys({ 
	["IS_Sparrowhawk"] = IS_Sparrowhawk,
})