local Turret_AC10 = Tower:New{
	description         = "Dual AC/10",
	buildCostMetal      = 3500,
	maxDamage           = 1500,
	
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
		maxammo 		= {ac10 = 2},
		turretturnspeed = 150,
		elevationspeed  = 200,
		chainfiredelays = {[2] = 200},
		turrettype = "turret",
    },
	sounds = {
		select = "Turret",
	}
}

return lowerkeys({
	["Turret_AC10"] = Turret_AC10,
})