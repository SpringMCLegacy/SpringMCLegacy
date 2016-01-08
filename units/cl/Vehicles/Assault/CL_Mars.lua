local CL_Mars = Tank:New{
	name              	= "Mars",
	description         = "Heavy Strike Tank",
	objectName        	= "CL_Mars.s3o",
	corpse				= "CL_Mars_X",
	maxDamage           = 13800,
	mass                = 10000,
	radarDistanceJam    = 500,
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
			name	= "CERLBL",
		},
		[2] = {
			name	= "Gauss",
		},
		[3] = {
			name	= "LBX10",
			maxAngleDif = 80,
		},
		[4] = {
			name	= "LRM15",
			maxAngleDif = 180,
		},
		[5] = {
			name	= "LRM15",
			maxAngleDif = 180,
			SlaveTo = 4,
		},
		[6] = {
			name	= "LRM15",
			maxAngleDif = 180,
			SlaveTo = 4,
		},
		[7] = {
			name	= "MG",
		},
		[8] = {
			name	= "MG",
		},
		[9] = {
			name	= "SSRM6",
			mainDir = [[-1 0 0]],
			maxAngleDif = 180,
		},
		[10] = {
			name	= "SSRM6",
			mainDir = [[1 0 0]],
			maxAngleDif = 180,
		},
	},
	customparams = {
		helptext		= "Armament: 1 x Gauss Rifle, 1 x ER Large Beam Laser, 1 x LBX/10, 3 x LRM-15, 2 x Streak SRM-6, 2 x Machinegun - Armor: 11.5 tons FF",
		heatlimit		= 36,
		wheelspeed      = 50,
		turretturnspeed = 50,
		elevationspeed  = 100,
		barrelrecoildist = {[1] = 5, [3] = 5},
		barrelrecoilspeed = 100,
		maxammo = {gauss = 20, ac10 = 40, lrm = 180, srm = 120},
		squadsize 		= 2,
    },
}

return lowerkeys({
	["CL_Mars"] = CL_Mars,
})