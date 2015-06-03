local CL_Ku = LightTank:New{
	name              	= "Ku",
	description         = "Medium Brawler Tank",
	objectName        	= "CL_Ku.s3o",
	corpse				= "CL_Ku_X",
	maxDamage           = 8400,
	mass                = 5000,
	trackWidth			= 24,--width to render the decal
	buildCostEnergy     = 50,
	buildCostMetal      = 18120,
	maxVelocity		= 2.2, --97kph/30
	maxReverseVelocity= 1.2,
	acceleration    = 0.9,
	brakeRate       = 0.1,
	turnRate 		= 500,
	
	weapons 		= {	
		[1] = {
			name	= "UAC10",
		},
		[2] = {
			name	= "CERLBL",
		},
		[3] = {
			name	= "SSRM4",
		},
	},
	customparams = {
		helptext		= "Armament: 1 x Ultra AC/10, 1 x ER Large Beam Laser, 1 x SSRM-4 - Armor: 7 tons FF",
		heatlimit		= 22,
		turretturnspeed = 100,
		elevationspeed  = 150,
		maxammo = {ac10 = 50, srm = 120},
		barrelrecoildist = {[2] = 5},
		squadsize 		= 3,
    },
}

return lowerkeys({
	["CL_Ku"] = CL_Ku,
})