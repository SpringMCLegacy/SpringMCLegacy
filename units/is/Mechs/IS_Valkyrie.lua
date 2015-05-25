local IS_Valkyrie = Light:New{
	corpse				= "IS_Valkyrie_X",
	maxDamage           = 10500,
	mass                = 3500,
	buildCostEnergy     = 35,
	buildCostMetal        = 15500,
	maxVelocity		= 4, --80kph/20

	customparams = {
		heatlimit		= "10",
		torsoturnspeed	= "195",
    },
}

local VLKQD = IS_Valkyrie:New{
	name              	= "Valkyrie JVN-11B",
	description         = "Light-class LRM Support",
	objectName        	= "IS_Valkyrie_VLKQD.s3o",
	weapons	= {	
		[1] = {
			name	= "LRM10",
		},
		[2] = {
			name	= "MPL",
		},
	},
		
	customparams = {
		helptext		= "Armament: 1 x LRM-10, 1 x MPL - Armor: 6 tons Ferro-Fibrous",
		maxammo 		= {lrm = 120},
    },
}

return lowerkeys({
	["IS_Valkyrie_VLKQD"] = VLKQD,
})