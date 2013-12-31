local Turret_PPC = Tower:New{
	description         = "Dual PPC",
	objectName        	= "Turret_PPC.s3o",
	--buildCostMetal      = 0,

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