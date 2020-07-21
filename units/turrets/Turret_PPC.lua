local Turret_PPC = Tower:New{
	description         = "Dual PPC",
	buildCostMetal      = 3000,

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
	sounds = {
		select = "Turret",
	}
}

return lowerkeys({
	["Turret_PPC"] = Turret_PPC,
})