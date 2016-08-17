local Turret_AC10 = Tower:New{
	description         = "Dual AC/10",
	buildCostMetal      = 4000,
	
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
		chainfiredelays = {[2] = 200},
    },
	sounds = {
	select = "Turret",
	}
}

return lowerkeys({
	["Turret_AC10"] = Turret_AC10,
})