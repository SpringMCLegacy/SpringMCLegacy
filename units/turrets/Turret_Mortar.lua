local Turret_Mortar = Turret:New{
	description         = "Auto-Mortar",
	buildCostMetal      = 3500,
	maxDamage           = 2000,

	weapons = {	
		[1] = {
			name	= "Mortar",
			OnlyTargetCategory = "ground",
		},
		[2] = {
			name	= "Mortar",
			SlaveTo = 1,
			OnlyTargetCategory = "ground",
		},
		[3] = {
			name	= "Mortar",
			SlaveTo = 1,
			OnlyTargetCategory = "ground",
		},
	},
	customparams = {
		barrelrecoildist = {[1] = 3, [2] = 3, [3] = 3},
		turrettype = "turret",
		maxammo 		= {mortar = 2},
		chainfiredelays = {[2] = 200, [3] = 400},
    },
}

return lowerkeys({
	["Turret_Mortar"] = Turret_Mortar,
})