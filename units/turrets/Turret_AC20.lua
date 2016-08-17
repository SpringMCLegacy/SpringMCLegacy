local Turret_AC20 = Tower:New{
	description         = "Ultra Autocannon/20",
	buildCostMetal      = 4000,

	weapons	= {	
		[1] = {
			name	= "AC20",
			OnlyTargetCategory = "notbeacon",
		},
	},
	customparams = {
		barrelrecoildist = {[1] = 5},
		turretturnspeed = 100,
		elevationspeed  = 150,
    },
	sounds = {
	select = "Turret",
	}
}

return lowerkeys({
	["Turret_AC20"] = Turret_AC20,
})