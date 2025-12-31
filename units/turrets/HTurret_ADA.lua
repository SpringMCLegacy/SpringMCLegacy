local HTurret_ADA = HeavyTurret:New{
	description         = "Air Defense Arrow",
	buildCostMetal      = 7300,
	maxDamage           = 2000,

	weapons	= {	
		[1] = {
			name	= "ADArrow",
			onlyTargetCategory = "air",
		},
	},
	customparams = {
		maxammo 		= {arrow = 1},
		turretturnspeed = 90,
		elevationspeed  = 90,
    },
}

return lowerkeys({
	["HTurret_ADA"] = HTurret_ADA,
})