local CL_Maddog = Heavy:New{
	corpse				= "CL_Maddog_X",
	maxDamage           = 16300,
	maxVelocity		= 4.3, --86kph/20
	maxReverseVelocity= 2.15,
	acceleration    = 1,
	brakeRate       = 0.2,
	turnRate 		= 700,

	customparams = {
		heatlimit		= 24,
		tonnage			= 60,
		torsoturnspeed	= 135,
		maxammo 		= {lrm = 180},
    },
}
	
local Prime = CL_Maddog:New{
	name              	= "Mad Dog (Vulture) Prime",
	description         = "Heavy Missile Support Mech",
	objectName        	= "CL_Maddog.s3o",
	weapons	= {	
		[1] = {
			name	= "LRM20", -- TODO: Artemis
		},
		[2] = {
			name	= "LRM20", -- TODO: Artemis
		},
		[3] = {
			name	= "CLPL",
		},
		[4] = {
			name	= "CLPL",
		},
		[5] = {
			name	= "CMPL",
		},
		[6] = {
			name	= "CMPL",
		},
		[7] = {
			name	= "AMS",
		},
	},
	
	customparams = {
		price      = 30810,
		helptext		= "Armament: 2 x LRM-20, 2 x Large Pulse Laser, 2 x Medium Pulse Laser - Armor: 8.5 tons Ferro-Fibrous",
    },
}

return lowerkeys({ 
	["CL_Maddog_Prime"] = Prime,
})