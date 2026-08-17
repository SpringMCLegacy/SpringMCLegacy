local HTurret_RAC = HeavyTurret:New{
	description         = "Quad RAC/5",
	buildCostMetal      = 20000,

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
		maxammo 		= {ac5 = 4},
		faction			= "fs",
    },
}

return lowerkeys({
	["HTurret_FS"] = HTurret_RAC,
})