local CL_Direwolf = Assault:New{
	corpse				= "CL_Direwolf_X",
	maxDamage           = 30400,
	mass                = 10000,
	buildCostEnergy     = 100,
	buildCostMetal      = 48660,
	maxVelocity		= 2.7, --54kph/30
	maxReverseVelocity= 1.35,
	acceleration    = .80,
	brakeRate       = 0.1,
	turnRate 		= 600,

	customparams = {
		heatlimit		= 44,
		torsoturnspeed	= 100,
		maxammo 		= {ac5 = 100, lrm = 120},
    },
}

local Prime = CL_Direwolf:New{
	name              	= "Dire Wolf (Daishi) Prime",
	description         = "Assault-class Strike Mech",
	objectName        	= "CL_Direwolf.s3o",
	weapons = {	
		[1] = {
			name	= "CERLBL",
		},
		[2] = {
			name	= "CERLBL",
		},
		[3] = {
			name	= "CERLBL",
		},
		[4] = {
			name	= "CERLBL",
		},
		[5] = {
			name	= "CMPL",
		},
		[6] = {
			name	= "CMPL",
		},
		[7] = {
			name	= "CMPL",
		},
		[8] = {
			name	= "CMPL",
		},
		[9] = {
			name	= "UAC5",
		},
		[10] = {
			name	= "UAC5",
		},
		[11] = {
			name	= "LRM10",
		},
	},

	customparams = {
		helptext		= "Armament: 4 x ER Large Beam Laser, 4 x ER Medium Beam Laser, 2 x UAC/5, 1 x ATM-9 - Armor: 19 tons",
    },
}

return lowerkeys({
	["CL_Direwolf_Prime"] = Prime,
})