local Turret_LRM = Tower:New{
	description         = "LRM-20",
	buildCostMetal      = 2000,

	weapons = {	
		[1] = {
			name	= "LRM20",
			OnlyTargetCategory = "notbeacon",
		},
	},
	customparams = {
		turretturnspeed = 100,
		elevationspeed  = 200,
    },
}

return lowerkeys({
	["Turret_LRM"] = Turret_LRM,
})