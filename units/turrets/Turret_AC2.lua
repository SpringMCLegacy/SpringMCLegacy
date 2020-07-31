local Turret_AC2 = Tower:New{
	description         = "Quad AC/2",
	buildCostMetal      = 2200,

	weapons = {	
		[1] = {
			name	= "AC2_AA",
			OnlyTargetCategory = "notbeacon",
		},
		[2] = {
			name	= "AC2_AA",
			OnlyTargetCategory = "notbeacon",
		},
		[3] = {
			name	= "AC2_AA",
			OnlyTargetCategory = "notbeacon",
		},
		[4] = {
			name	= "AC2_AA",
			OnlyTargetCategory = "notbeacon",
		},
	},
	customparams = {
		helptext		= "A defensive turret for beacons.",
		barrelrecoildist = {2, 2, 2, 2},
		maxammo 		= {ac2 = 2},
		turretturnspeed = 450,
		elevationspeed  = 500,
		chainfiredelays = {[2] = 100, [3] = 200, [4] = 300},
		turrettype = "turret",
    },
	sounds = {
		select = "Turret",
	}
}

return lowerkeys({
	["Turret_AC2"] = Turret_AC2,
})