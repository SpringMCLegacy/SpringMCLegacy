local IS_Hawkmoth = VTOL:New{
	name              	= "Hawk Moth",
	description         = "Light Attack VTOL",
	objectName        	= "IS_Hawkmoth.s3o",
	corpse				= "IS_Hawkmoth_X",
	sightDistance       = 1200,
	radarDistance      	= 2000,
	maxDamage           = 3500,
	mass                = 2000,
	buildCostEnergy     = 20,
	buildCostMetal      = 8000,
	maxVelocity		= 8.6,
	acceleration	= 0.2,
	brakeRate 		= 1600,
	turnRate 		= 800,
	verticalSpeed	= 1,

	weapons	= {	
		[1] = {
			name	= "Gauss",
			OnlyTargetCategory = "notbeacon",
			maxAngleDif = 180,
		},
	},
	
	customparams = {
		helptext		= "Armament: 1 x Gauss Rifle - Armor: 2 tons",
		heatlimit		= "15",
		maxammo 		= {gauss = 30},
    },
}

return lowerkeys({
	["IS_Hawkmoth"] = IS_Hawkmoth,
})