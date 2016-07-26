local Turret_AC2 = Tower:New{
	description         = "Quad AC/2",
	buildCostMetal      = 4000,

	weapons = {	
		[1] = {
			name	= "AC2",
			OnlyTargetCategory = "notbeacon",
		},
		[2] = {
			name	= "AC2",
			OnlyTargetCategory = "notbeacon",
		},
		[3] = {
			name	= "AC2",
			OnlyTargetCategory = "notbeacon",
		},
		[4] = {
			name	= "AC2",
			OnlyTargetCategory = "notbeacon",
		},
	},
	customparams = {
		helptext		= "A defensive turret for beacons.",
		barrelrecoildist = {2, 2, 2, 2},
		turretturnspeed = 250,
		elevationspeed  = 300,
    },
}

return lowerkeys({
	["Turret_AC2"] = Turret_AC2,
})