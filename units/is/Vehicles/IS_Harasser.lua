local IS_Harasser = Hover:New{
	name              	= "Harraser",
	description         = "Light Skirmish Hovercraft",
	objectName        	= "IS_Harasser.s3o",
	corpse				= "IS_Harasser_X",
	maxDamage           = 2400,
	mass                = 2500,
	buildCostEnergy     = 25,
	buildCostMetal      = 4320,
	maxVelocity		= 8.1, --162kph/30
	maxReverseVelocity= 4.0,
	acceleration    = 2.0,
	brakeRate       = 0.1,
	turnRate 		= 500,
	
	weapons 		= {	
		[1] = {
			name	= "SRM6",
			OnlyTargetCategory = "notbeacon",
		},
		[2] = {
			name	= "SRM6",
			OnlyTargetCategory = "notbeacon",
		},
	},
	
	customparams = {
		helptext		= "Armament: 2 x SRM-6 - Armor: 1.5 tons",
		heatlimit		= "10",
		turretturnspeed = "100",
		elevationspeed  = "200",
		maxammo 		= {srm = 120},
    },
}

return lowerkeys({
	["IS_Harasser"] = IS_Harasser,
})