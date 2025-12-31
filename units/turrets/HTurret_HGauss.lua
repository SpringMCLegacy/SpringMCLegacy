local HTurret_HGauss = HeavyTurret:New{
	description         = "Dual Heavy Gauss",
	buildCostMetal      = 20000,

	weapons	= {	
		[1] = {
			name	= "HeavyGauss",
			OnlyTargetCategory = "notbeacon",
		},
		[2] = {
			name	= "HeavyGauss",
			OnlyTargetCategory = "notbeacon",
			SlaveTo = 1,
		},
	},
	customparams = {
		barrelrecoildist = {5, 5},
		turretturnspeed = 100,
		elevationspeed  = 150,
		maxammo 		= {hvgauss = 2},
		faction			= "la",
    },
}

return lowerkeys({
	["HTurret_LA"] = HTurret_HGauss,
})