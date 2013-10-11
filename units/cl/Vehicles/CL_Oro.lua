local CL_Oro = Tank:New{
	mass                = 6500,
	trackWidth			= 24,--width to render the decal
	buildCostEnergy     = 65,
	maxVelocity		= 2.13, --64kph/10/2
	maxReverseVelocity= 1.5,
	acceleration    = 0.8,
	brakeRate       = 0.1,
	turnRate 		= 400,

	customparams = {
		turretturnspeed = 85,
		elevationspeed  = 200,
		wheelspeed      = 200,
    },
}

local Oro_HAG = CL_Oro:New{
	name              	= "Oro (HAG/30)",
	description         = "Heavy Strike Tank",
	objectName        	= "CL_Oro_HAG.s3o",
	buildCostMetal      = 5500,
	maxDamage           = 19700,
	weapons 		= {	
		[1] = {
			name	= "HAG30",
			OnlyTargetCategory = "notbeacon",
		},
		[2] = {
			name	= "CLPL",
			OnlyTargetCategory = "notbeacon",
		},
	},
	customparams = {
		helptext		= "Armament: 1 x Hyper Assault Gauss 30, 1 x Large Pulse Laser - Armor: 11 tons",
		heatlimit		= 20,
		barrelrecoildist = {[1] = 5},
    },
}

local Oro_LBX = CL_Oro:New{
	name              	= "Oro (LBX/20)",
	description         = "Medium Brawler Tank",
	objectName        	= "CL_Oro_LBX.s3o",
	buildCostMetal      = 12150,
	maxDamage           = 9800,
	weapons = {	
		[1] = {
			name	= "LBX20",
			OnlyTargetCategory = "notbeacon",
		},
		[2] = {
			name	= "CLPL",
			OnlyTargetCategory = "notbeacon",
		},
		[3] = {
			name	= "CERMBL",
			OnlyTargetCategory = "notbeacon",
		},
	},
	customparams = {
		helptext		= "Armament: 1 x LBX Autocannon/20, 1 x Large Pulse Laser, 1 x ER Medium Beam Laser - Armor: 11 tons",
		heatlimit		= 15,
		barrelrecoildist = {[1] = 5},
    },
}

return lowerkeys({
	["CL_Oro_HAG"] = Oro_HAG,
	["CL_Oro_LBX"] = Oro_LBX,
})