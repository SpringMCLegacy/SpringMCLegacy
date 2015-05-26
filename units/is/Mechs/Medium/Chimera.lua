local IS_Chimera = Medium:New{
	corpse				= "IS_Chimera_X",
	maxDamage           = 11200,
	mass                = 4000,
	buildCostEnergy     = 40,
	buildCostMetal        = 17270,
	maxVelocity		= 4.5, --90kph/20
	
	customparams = {
		heatlimit		= "20",
		torsoturnspeed	= "170",
		canjump			= "1",
    },
}

local CMA1S = IS_Chimera:New{
	name              	= "Chimera CMA-1S",
	description         = "Medium-class Mid Range Skirmisher",
	objectName        	= "IS_Chimera_CMA1S.s3o",
	weapons	= {	
		[1] = {
			name	= "ERLBL",
		},
		[2] = {
			name	= "ERMBL",
		},
		[3] = {
			name	= "MG",
		},
		[4] = {
			name	= "MRM20",
			OnlyTargetCategory = "ground",
		},
	},

	customparams = {
		helptext		= "Armament: 1 x ER Large Beam Laser, 1 x Medium Pulse Laser, 1 x Machinegun, 2 x MRM-10 - Armor: 7 tons Standard",
		maxammo 		= {mrm = 400},
    },
}

return lowerkeys({ 
	["IS_Chimera_CMA1S"] = CMA1S
})