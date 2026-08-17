local HTurret_ADA = HeavyTurret:New{
	description         = "Air Defense Arrow",
	buildCostMetal      = 14600,
	maxDamage           = 2000,

	weapons	= {	
		[1] = {
			name	= "ADArrow",
			onlyTargetCategory = "air",
		},
		[2] = {
			name	= "ADArrow",
			onlyTargetCategory = "air",
			SlaveTo = 1,
		},
	},
	customparams = {
		maxammo 			= {arrow = 1.2 * 3}, -- needs to be multiplied by fake burstLength for the script
		turretturnspeed	 	= 90,
		elevationspeed  	= 90,
    },
}

return lowerkeys({
	["HTurret_ADA"] = HTurret_ADA,
})