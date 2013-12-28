local IS_Awesome = Assault:New{
	corpse				= "IS_Awesome_X",
	maxDamage           = 24000,
	mass                = 8500,
	buildCostEnergy     = 85,
	buildCostMetal        = 35160,
	maxVelocity		= 2.5, --50kph/20

	customparams = {
		torsoturnspeed	= "100",
    },
}
	
local AWS8Q = IS_Awesome:New{
	name              	= "Awesome AWS-8Q",
	description         = "Assault-class Mid Range Fire Support",
	objectName        	= "IS_Awesome_AWS8Q.s3o",
	weapons	= {	
		[1] = {
			name	= "PPC",
		},
		[2] = {
			name	= "PPC",
			OnlyTargetCategory = "ground",
		},
		[3] = {
			name	= "PPC",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "SBL",
			OnlyTargetCategory = "ground",
		},
	},
		
    customparams = {
		helptext		= "Armament: 3 x PPC, 1 x SBL - Armor: 15.5 tons Standard",
		heatlimit		= "28",
    },
}

local AWS9M = IS_Awesome:New{
	name              	= "Awesome AWS-9M",
	description         = "Assault-class Long Range Fire Support/Sniper",
	objectName        	= "IS_Awesome_AWS9M.s3o",
	weapons	= {	
		[1] = {
			name	= "ERPPC",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "ERPPC",
			OnlyTargetCategory = "ground",
		},
		[3] = {
			name	= "ERPPC",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "SPL",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "MPL",
			OnlyTargetCategory = "ground",
		},
		[6] = {
			name	= "SSRM4",
		},
	},
		
    customparams = {
		helptext		= "Armament: 3 x ERPPC, 1 x MPL, 1 x SPL, 1 x SSRM-4 - Armor: 15.5 tons Standard",
		heatlimit		= "38",
		maxammo 		= {srm = 120},
    },
}
	
return lowerkeys({ 
	["IS_Awesome_AWS8Q"] = AWS8Q,
	["IS_Awesome_AWS9M"] = AWS9M,
})