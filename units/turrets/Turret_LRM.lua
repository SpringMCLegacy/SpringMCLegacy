local Turret_LRM = Turret:New{
	description         = "LRM-20",
	buildCostMetal      = 4200,
	maxDamage           = 2000,

	weapons = {	
		[1] = {
			name	= "LRM20",
			OnlyTargetCategory = "notbeacon",
		},
	},
	customparams = {
		maxammo 		= {lrm = 1},
		turretturnspeed = 100,
		elevationspeed  = 200,
		turrettype = "ranged",
    },
}

return lowerkeys({
	["Turret_LRM"] = Turret_LRM,
})