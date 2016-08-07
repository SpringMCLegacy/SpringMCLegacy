local Garrison_LRM = Tower:New{
	description         = "Quad LRM-20",
	buildCostMetal      = 20000,

	weapons	= {	
		[1] = {
			name	= "LRM20",
			OnlyTargetCategory = "notbeacon",
		},
		[2] = {
			name	= "LRM20",
			OnlyTargetCategory = "notbeacon",
			SlaveTo = 1,
		},
		[3] = {
			name	= "LRM20",
			OnlyTargetCategory = "notbeacon",
			SlaveTo = 1,
		},
		[4] = {
			name	= "LRM20",
			OnlyTargetCategory = "notbeacon",
			SlaveTo = 1,
		},
	},
	customparams = {
		--barrelrecoildist = {[1] = 5},
		turretturnspeed = 100,
		elevationspeed  = 150,
    },
}

return lowerkeys({
	["Garrison_LRM"] = Garrison_LRM,
})