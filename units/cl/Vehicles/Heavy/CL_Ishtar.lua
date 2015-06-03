local CL_Ishtar = LightTank:New{
	name              	= "Ishtar",
	description         = "Heavy Strike Tank",
	objectName        	= "CL_Ishtar.s3o",
	corpse				= "CL_Ishtar_X",
	maxDamage           = 9000,
	mass                = 6500,
	trackWidth			= 28,--width to render the decal
	buildCostEnergy     = 65,
	buildCostMetal      = 22120,
	maxVelocity		= 1.8, --54kph/30
	maxReverseVelocity= 0.8,
	acceleration    = 0.9,
	brakeRate       = 0.1,
	turnRate 		= 700,
	
	weapons 		= {	
		[1] = {
			name	= "LBX10",
		},
		[2] = {
			name	= "UAC10",
		},
		[3] = {
			name	= "CERMBL",
		},
		[4] = {
			name	= "CERMBL",
		},
		[5] = {
			name	= "LRM15",
		},
		[6] = {
			name	= "AMS",
		},
	},
	customparams = {
		helptext		= "Armament: 1 x LBX-10, 1 x Ultra AC/10, 2 x ER Medium Beam Laser, 1 x LRM-15 - Armor: 7.5 tons FF",
		heatlimit		= 22,
		turretturnspeed = 100,
		elevationspeed  = 150,
		maxammo = {ac10 = 80, lrm = 150},
		barrelrecoildist = {[1] = 1},
		squadsize 		= 2,
    },
}

return lowerkeys({
	["CL_Ishtar"] = CL_Ishtar,
})