local Turret_AC10 = Tower:New{
	description         = "Dual AC/10",
	objectName        	= "Turret_AC10.s3o",
	buildCostMetal      = 0,
	
	weapons	= {	
		[1] = {
			name	= "AC10",
			OnlyTargetCategory = "notbeacon",
		},
		[2] = {
			name	= "AC10",
			OnlyTargetCategory = "notbeacon",
		},
	},
	customparams = {
		barrelrecoildist = {5, 5},
		turretturnspeed = 150,
		elevationspeed  = 200,
    },
}

return lowerkeys({
	["Turret_AC10"] = Turret_AC10,
})