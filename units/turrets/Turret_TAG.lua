local Turret_TAG = Turret:New{
	description         = "TAG Laser",
	buildCostMetal      = 3500,
	maxDamage           = 2000,

	weapons = {	
		[1] = {
			name	= "TAG",
			OnlyTargetCategory = "ground",
		},
	},
	customparams = {
		turrettype = "energy",
    },
}

return lowerkeys({
	["Turret_TAG"] = Turret_TAG,
})