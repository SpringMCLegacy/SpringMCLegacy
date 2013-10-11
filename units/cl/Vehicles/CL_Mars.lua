local CL_Mars = Tank:New{
	name              	= "Mars",
	description         = "Heavy Strike Tank",
	objectName        	= "CL_Mars.s3o",
	corpse				= "CL_Mars_X",
	maxDamage           = 26800,
	mass                = 10000,
	trackType			= "Mars",--hueg like xbox
	trackWidth			= 28,--width to render the decal
	buildCostEnergy     = 100,
	buildCostMetal      = 31500,
	maxVelocity		= 1.06, --32kph/30
	maxReverseVelocity= 1.5,
	acceleration    = 0.8,
	brakeRate       = 0.1,
	turnRate 		= 400,

	weapons = {	
		[1] = {
			name	= "Gauss",
			OnlyTargetCategory = "notbeacon",
		},
		[2] = {
			name	= "CERLBL",
			OnlyTargetCategory = "notbeacon",
		},
		[3] = {
			name	= "LBX10",
			maxAngleDif = 35,
			OnlyTargetCategory = "notbeacon",
		},
		[4] = {
			name	= "LRM15",
			maxAngleDif = 180,
			OnlyTargetCategory = "notbeacon",
		},
		[5] = {
			name	= "LRM15",
			maxAngleDif = 180,
			OnlyTargetCategory = "notbeacon",
			SlaveTo = 4,
		},
		[6] = {
			name	= "LRM15",
			maxAngleDif = 180,
			OnlyTargetCategory = "notbeacon",
			SlaveTo = 4,
		},
		[7] = {
			name	= "MG",
			OnlyTargetCategory = "notbeacon",
		},
		[8] = {
			name	= "MG",
			OnlyTargetCategory = "notbeacon",
		},
	},
	customparams = {
		helptext		= "Armament: 1 x Gauss Rifle, 1 x ER Large Beam Laser, 1 x LBX/10, 3 x LRM-15 - Armor: 15 tons",
		heatlimit		= 36,
		wheelspeed      = 50,
		turretturnspeed = 50,
		elevationspeed  = 100,
		barrelrecoildist = {[1] = 5, [3] = 5},
		barrelrecoilspeed = 100,
		turrets = {[3] = 3},
    },
}

return lowerkeys({
	["CL_Mars"] = CL_Mars,
})