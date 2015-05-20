local CL_Hachiman = LightTank:New{
	name              	= "Hachiman",
	description         = "Medium Support Tank",
	objectName        	= "CL_Hachiman.s3o",
	corpse				= "CL_Hachiman_X",
	maxDamage           = 8400,
	mass                = 5000,
	trackWidth			= 24,--width to render the decal
	buildCostEnergy     = 50,
	buildCostMetal      = 13500,
	maxVelocity		= 2.1, --65kph/30
	maxReverseVelocity= 1.5,
	acceleration    = 0.8,
	brakeRate       = 0.1,
	turnRate 		= 450,
	
	weapons = {	
		[1] = {
			name	= "LRM20",
		},
		[2] = {
			name	= "LRM20",
		},
		[3] = {
			name	= "CERMBL",
		},
		[4] = {
			name	= "CERMBL",
		},
	},
	customparams = {
		helptext		= "Armament: 2 x LRM-20, 2 x ER Medium Beam Laser - Armor: 7 tons FF",
		heatlimit		= 22,
		turretturnspeed = 75,
		elevationspeed  = 100,
		maxammo = {lrm = 700},
		squadsize 		= 1,
    },
}

return lowerkeys({
	["CL_Hachiman"] = CL_Hachiman,
})