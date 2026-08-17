local HTurret_PPCMRM = HeavyTurret:New{
	description         = "Dual ERPPC & MRM-30",
	buildCostMetal      = 20000,

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
		chainfiredelays = {[2] = 200},
		turretturnspeed = 100,
		elevationspeed  = 150,
		maxammo 		= {mrm = 3},
		faction			= "dc",
    },
}

return lowerkeys({
	["HTurret_DC"] = HTurret_PPCMRM,
})