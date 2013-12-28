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
		helptext		= "Armament: 1 x ER PPC, 2 x Medium Beam Laser - Armor: 7.5 tons Stabdard",
    },
}

return lowerkeys({
	["IS_Talon_TLN5W"] = TLN5W,
})