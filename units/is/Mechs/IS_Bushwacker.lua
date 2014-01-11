local IS_Bushwacker = Medium:New{
	corpse				= "IS_Bushwacker_X",
	maxDamage           = 16100,
	mass                = 5500,
	buildCostEnergy     = 55,
	buildCostMetal        = 20100,
	maxVelocity		= 4, --80kph/20

	customparams = {
		barrelrecoildist = {[1] = 5},
		heatlimit		= "22",
		torsoturnspeed	= "160",
    },
}

local BSWS2 = IS_Bushwacker:New{
	name              	= "Bushwacker BSW-S2",
	description         = "Medium-class Close Range Brawler",
	objectName        	= "IS_Bushwacker_BSWS2.s3o",
	weapons = {	
		[1] = {
			name	= "LBX10",
		},
		[2] = {
			name	= "ERLBL",
			OnlyTargetCategory = "ground",
		},
		[3] = {
			name	= "SRM4",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "SRM4",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "AMS",
		},
	},
		

    customparams = {
		helptext		= "Armament: 1 x LBX/10, 1 x ER Large Beam Laser, 2 x Small Pulse Laser, 2 x SRM-4 - Armor: 9 tons Ferro-Fibrous",
		maxammo 		= {srm = 120, ac10 = 40},
    },
}

local BSWX1 = IS_Bushwacker:New{
	name              	= "Bushwacker BSW-X1",
	description         = "Medium-class Mid Range Fire Support",
	objectName        	= "IS_Bushwacker_BSWX1.s3o",
	weapons = {	
		[1] = {
			name	= "AC10",
			OnlyTargetCategory = "notbeacon",
		},
		[2] = {
			name	= "ERLBL",
			OnlyTargetCategory = "ground",
		},
		[3] = {
			name	= "MG",
			OnlyTargetCategory = "ground",
		},
		[4] = {
			name	= "MG",
			OnlyTargetCategory = "ground",
		},
		[5] = {
			name	= "LRM5",
			OnlyTargetCategory = "notbeacon",
		},
		[6] = {
			name	= "LRM5",
			OnlyTargetCategory = "notbeacon",
		},
	},
		
    customparams = {
		helptext		= "Armament: 1 x AC/10, 1 x Large Beam Laser, 2 x Machinegun, 2 x LRM-5 - Armor: 9 tons Ferro-Fibrous",
		maxammo 		= {lrm = 180, ac10 = 20},
    },
}

return lowerkeys({
	["IS_Bushwacker_BSWS2"] = BSWS2,
	["IS_Bushwacker_BSWX1"] = BSWX1,
})