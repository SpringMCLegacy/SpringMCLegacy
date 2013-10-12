local CL_Timberwolf = Heavy:New{
	corpse				= "CL_Timberwolf_X",
	maxDamage           = 23000,
	mass                = 7500,
	buildCostEnergy     = 75,
	buildCostMetal      = 37200,
	maxVelocity		= 4.3, --86kph/20
	maxReverseVelocity= 2.15,
	acceleration    = 1,
	brakeRate       = 0.2,
	turnRate 		= 700,
	
	customparams = {
		heatlimit		= 34,
		torsoturnspeed	= 130,
    },
}
	
local E = CL_Timberwolf:New{
	name              	= "Timber Wolf (Mad Cat) E",
	description         = "Heavy Strike Mech",
	objectName        	= "CL_Timberwolf.s3o",
	weapons	= {	
		[1] = {
			name	= "CERLBL",
		},
		[2] = {
			name	= "CERLBL",
		},
		[3] = {
			name	= "CERMBL",
		},
		[4] = {
			name	= "CERMBL",
		},
		[5] = {
			name	= "CSPL",
		},
		[6] = {
			name	= "CSPL",
		},
		[7] = {
			name	= "MG",
		},
		[8] = {
			name	= "MG",
		},
		[9] = {
			name	= "ATM9",
		},
		[10] = {
			name	= "ATM9",
		},
	},
	customparams = {
		helptext		= "Armament: 2 x ER Large Beam Laser, 2x ER Medium Beam Laser, 2x Small Pulse Laser, 2x MG, 2 x ATM-9 - Armor: ?? tons Ferro-Fibrous",
    },
}

return lowerkeys({
	["CL_Timberwolf_E"] = E,
})