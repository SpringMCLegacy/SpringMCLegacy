local Garrison_LGauss = Tower:New{
	description         = "Quad Light Gauss",
	buildCostMetal      = 18000,

	weapons	= {	
		[1] = {
			name	= "LightGauss",
			OnlyTargetCategory = "notbeacon",
		},
		[2] = {
			name	= "LightGauss",
			OnlyTargetCategory = "notbeacon",
			SlaveTo = 1,
		},
		[3] = {
			name	= "LightGauss",
			OnlyTargetCategory = "notbeacon",
			SlaveTo = 1,
		},
		[4] = {
			name	= "LightGauss",
			OnlyTargetCategory = "notbeacon",
			SlaveTo = 1,
		},
	},
	customparams = {
		barrelrecoildist = {5, 5, 5, 5},
		turretturnspeed = 100,
		elevationspeed  = 150,
    },
}

return lowerkeys({
	["Garrison_LGauss"] = Garrison_LGauss,
})