local Turret_PPC = Tower:New{
	description         = "Dual PPC",

	weapons = {	
		[1] = {
			name	= "PPC",
			OnlyTargetCategory = "notbeacon",
		},
		[2] = {
			name	= "PPC",
			OnlyTargetCategory = "notbeacon",
		},
	},
	customparams = {
		barrelrecoildist = {[1] = 5},
    },
}

return lowerkeys({
	["Turret_PPC"] = Turret_PPC,
})