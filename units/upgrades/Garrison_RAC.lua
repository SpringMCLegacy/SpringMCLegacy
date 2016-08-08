local Garrison_RAC = Tower:New{
	description         = "Quad RAC/5",
	buildCostMetal      = 19000,

	weapons	= {	
		[1] = {
			name	= "RAC5",
			OnlyTargetCategory = "notbeacon",
		},
		[2] = {
			name	= "RAC5",
			OnlyTargetCategory = "notbeacon",
			SlaveTo = 1,
		},
		[3] = {
			name	= "RAC5",
			OnlyTargetCategory = "notbeacon",
			SlaveTo = 1,
		},
		[4] = {
			name	= "RAC5",
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
	["Garrison_FS"] = Garrison_RAC,
})