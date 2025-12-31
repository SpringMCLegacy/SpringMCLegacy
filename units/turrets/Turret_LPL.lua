local Turret_LPL = Turret:New{
	description         = "Quad Large Pulse Laser",
	buildCostMetal      = 3500,
	maxDamage           = 2500,

	weapons = {	
		[1] = {
			name	= "LPL",
			OnlyTargetCategory = "notbeacon",
		},
		[2] = {
			name	= "LPL",
			OnlyTargetCategory = "notbeacon",
		},
		[3] = {
			name	= "LPL",
			OnlyTargetCategory = "notbeacon",
		},
		[4] = {
			name	= "LPL",
			OnlyTargetCategory = "notbeacon",
		},
	},
	customparams = {
		turretturnspeed = 175,
		elevationspeed  = 250,
		turrettype = "energy",
    },
}

return lowerkeys({
	["Turret_LPL"] = Turret_LPL,
})