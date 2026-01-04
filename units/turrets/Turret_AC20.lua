local Turret_AC20 = Turret:New{
	description         = "Ultra Autocannon/20",
	buildCostMetal      = 4200,
	maxDamage           = 2000,

	weapons	= {	
		[1] = {
			name	= "AC20",
			OnlyTargetCategory = "notbeacon",
		},
	},
	customparams = {
		barrelrecoildist = {[1] = 5},
		maxammo 		= {ac20 = 1},
		turretturnspeed = 100,
		elevationspeed  = 150,
		turrettype = "turret",
    },
}

return lowerkeys({
	["Turret_AC20"] = Turret_AC20,
})