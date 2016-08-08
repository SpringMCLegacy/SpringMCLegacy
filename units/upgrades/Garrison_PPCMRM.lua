local Garrison_PPCMRM = Tower:New{
	description         = "Dual ERPPC & MRM-30",
	buildCostMetal      = 15000,

	weapons	= {	
		[1] = {
			name	= "ERPPC",
			OnlyTargetCategory = "notbeacon",
		},
		[2] = {
			name	= "ERPPC",
			OnlyTargetCategory = "notbeacon",
			SlaveTo = 1,
		},
		[3] = {
			name	= "MRM30",
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
	["Garrison_DC"] = Garrison_PPCMRM,
})