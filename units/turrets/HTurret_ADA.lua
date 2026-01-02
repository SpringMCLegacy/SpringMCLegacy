local HTurret_ADA = HeavyTurret:New{
	description         = "Air Defense Arrow",
	buildCostMetal      = 7300,
	maxDamage           = 2000,

	weapons	= {	
		[1] = {
			name	= "ADArrow_Turret",
			onlyTargetCategory = "air",
		},
		[2] = {
			name	= "ADArrow_Turret",
			onlyTargetCategory = "air",
			SlaveTo = 1,
		},
	},
	customparams = {
		maxammo 			= {arrow = 1.2 * 3}, -- needs to be multiplied by fake burstLength for the script
		ammorestoreamount	= 3,
		turretturnspeed	 	= 90,
		elevationspeed  	= 90,
    },
}

return lowerkeys({
	["HTurret_ADA"] = HTurret_ADA,
})