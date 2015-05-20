local IS_Corsair = Aero:New{
	name              	= "Corsair",
	description         = "Air Superiority ASF",
	objectName        	= "IS_Corsair.s3o",
	sightDistance       = 1200,
	radarDistance      	= 1500,
	maxDamage           = 3000,
	mass                = 2000,
	buildCostEnergy     = 20,
	buildCostMetal      = 4500,
	turnRadius		= 2000,
	maxAcc			= 0.22,
	maxBank			= 0.0006,
	maxPitch		= 0.0006,
	maxAileron		= 0.004,
	maxElevator		= 0.004,
	maxRudder		= 0.002,
	wingAngle		= 0.1,
	wingDrag		= 0.07,
	myGravity		= 0.8,
	
	weapons = {	
		[1] = {
			name	= "LBL",
			maxAngleDif = 35,
		},
		[2] = {
			name	= "LBL",
			maxAngleDif = 35,
		},
		[3] = {
			name	= "ERMBL",
			maxAngleDif = 35,
		},
		[4] = {
			name	= "ERMBL",
			maxAngleDif = 35,
		},
		[5] = {
			name	= "ERSBL",
			maxAngleDif = 35,
		},
		[6] = {
			name	= "ERSBL",
			maxAngleDif = 35,
		},
		[7] = {
			name	= "ERSBL",
			maxAngleDif = 35,
		},
		[8] = {
			name	= "ERSBL",
			maxAngleDif = 35,
		},
	},
	
	customparams = {
		helptext		= "Armament: 2 x Large Beam Laser, 2 x ER Medium Beam Laser, 4 x ER Small Beam Laser - Armor: 3 tons",
		heatlimit		= "20",
		squadsize 		= 2,
    },
}

return lowerkeys({ 
	["IS_Corsair"] = IS_Corsair,
})