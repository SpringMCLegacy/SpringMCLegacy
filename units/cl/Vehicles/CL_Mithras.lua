local CL_Mithras = LightTank:New{
	name              	= "Mithras",
	description         = "Light Strike Tank",
	objectName        	= "CL_Mithras.s3o",
	corpse				= "CL_Mithras_X",
	maxDamage           = 3000,
	mass                = 2500,
	trackWidth			= 24,--width to render the decal
	buildCostEnergy     = 55,
	buildCostMetal      = 15120,
	maxVelocity		= 3.23, --97kph/30
	maxReverseVelocity= 1.6,
	acceleration    = 0.9,
	brakeRate       = 0.1,
	turnRate 		= 500,
	
	weapons 		= {	
		[1] = {
			name	= "AC2",
		},
		[2] = {
			name	= "CERMBL",
		},
		[3] = {
			name	= "CERMBL",
		},
	},
	customparams = {
		helptext		= "Armament: 1 x Ultra AC/2, 2 x Clan ER Medium Beam Laser - Armor: 3 tons",
		heatlimit		= 28,
		turretturnspeed = 100,
		elevationspeed  = 150,
		maxammo = {ac2 = 300},
		barrelrecoildist = {[1] = 3},
		squadsize 		= 4,
    },
}

return lowerkeys({
	["CL_Mithras"] = CL_Mithras,
})