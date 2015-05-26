local IS_Argus = Heavy:New{
	corpse				= "IS_Argus_X",
	maxDamage           = 19200,
	mass                = 6000,
	buildCostEnergy     = 65,
	buildCostMetal      = 28820,
	maxVelocity			= 4, --80kph/20
		
    customparams = {
		heatlimit		= "24",
		torsoturnspeed	= "140",
    },
}

local AGS4D = IS_Argus:New{
	name              	= "Argus AGS-4D",
	description         = "Heavy-class Mid Range Skirmisher",
	objectName        	= "IS_Argus_AGS4D.s3o",
	weapons = {	
		[1] = {
			name	= "RAC5",
		},
		[2] = {
			name	= "MG",
		},
		[3] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "LRM10",
		},
	},
		
    customparams = {
		helptext		= "Armament: 1 x RAC/5, 2 x ER Medium Beam Laser, 1 x LRM-10, 1 x Machinegun - Armor: 12 tons Standard",
		hasbap			= "true",
		maxammo 		= {ac5 = 200, lrm = 360},
    },
}

return lowerkeys({ 
	["IS_Argus_AGS4D"] = AGS4D,
})