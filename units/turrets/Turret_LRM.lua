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
		maxammo 		= {lrm = 2},
		turretturnspeed = 100,
		elevationspeed  = 200,
		turrettype = "ranged",
    },
	sounds = {
	select = "Turret",
	}
}

return lowerkeys({
	["Turret_LRM"] = Turret_LRM,
})