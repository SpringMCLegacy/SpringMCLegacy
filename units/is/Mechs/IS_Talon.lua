local IS_Talon = Light:New{
	corpse				= "IS_Talon_X",
	maxDamage           = 11900,
	mass                = 3500,
	buildCostEnergy     = 35,
	buildCostMetal        = 15000,
	maxVelocity		= 6, --120kph/20

	customparams = {
		heatlimit 		= "22",
		torsoturnspeed	= "185",
    },
}

local TLN5W = IS_Talon:New{
	name              	= "Talon TLN-5W",
	description         = "Light-class Long Range Fire Support/Sniper",
	objectName        	= "IS_Talon_TLN5W.s3o",
	weapons = {	
		[1] = {
			name	= "ERPPC",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "MBL",
		},
	},
		
	customparams = {
		helptext		= "Armament: 1 x ER PPC, 2 x Medium Beam Laser - Armor: 7.5 tons Standard",
    },
}

local TLN5Z = IS_Talon:New{
	name              	= "Talon TLN-5Z",
	description         = "Light-class Long Range Fire Support",
	objectName        	= "IS_Talon_TLN5Z.s3o",
	maxVelocity			= 5.5, --110kph/20
	buildCostMetal      = 14500,
	weapons = {	
		[1] = {
			name	= "ERLBL",
		},
		[2] = {
			name	= "ERLBL",
		},
	},
		
	customparams = {
		helptext		= "Armament: 2 x ER Large Beam Laser - Armor: 7 tons Ferro-Fibrous",
		heatlimit		= "20",
    },
}

return lowerkeys({
	["IS_Talon_TLN5W"] = TLN5W,
	["IS_Talon_TLN5Z"] = TLN5Z,
})