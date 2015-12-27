local Turret_LPL = Tower:New{
	description         = "Quad Medium Pulse Laser",
	buildCostMetal      = 5000,

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
    },
}

return lowerkeys({
	["Turret_LPL"] = Turret_LPL,
})