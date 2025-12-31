local Turret_PPC = Turret:New{
	description         = "Dual PPC",
	buildCostMetal      = 3500,
	maxDamage           = 2000,

	weapons = {	
		[1] = {
			name	= "ERPPC",
			OnlyTargetCategory = "notbeacon",
		},
		[2] = {
			name	= "ERPPC",
			OnlyTargetCategory = "notbeacon",
		},
	},
	customparams = {
		barrelrecoildist = {[1] = 5},
		turrettype = "energy",
    },
}

return lowerkeys({
	["Turret_PPC"] = Turret_PPC,
})