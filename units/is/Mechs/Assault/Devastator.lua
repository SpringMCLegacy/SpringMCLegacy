local IS_Devastator = Assault:New{
	corpse				= "IS_Devastator_X",
	maxDamage           = 29600,
	mass                = 10000,
	buildCostEnergy     = 100, -- in tons
	buildCostMetal        = 36100,
	maxVelocity		= 2.5, --50kph/20
	
	customparams = {
		heatlimit		= "28",
		torsoturnspeed	= "100",
    },
}

local DVS2 = IS_Devastator:New{
	name              	= "Devastator DVS2",
	description         = "Assault-class Long Range Fire Support/Sniper",
	objectName        	= "IS_Devastator_DVS2.s3o",
	weapons = {	
		[1] = {
			name	= "Gauss",
		},
		[2] = {
			name	= "Gauss",
		},
		[3] = {
			name	= "PPC",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "PPC",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[6] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[7] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
		[8] = {
			name	= "MBL",
			OnlyTargetCategory = "ground",
		},
	},
		
	customparams = {
		helptext		= "Armament: 2 x Gauss Rifle, 2 x PPC, 4 x Medium Beam Laser - Armor: 18.5 tons Standard",
		maxammo 		= {gauss = 60},
    },
}

return lowerkeys({
	["IS_Devastator_DVS2"] = DVS2,
})