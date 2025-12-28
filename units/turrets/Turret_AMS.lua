local Turret_AMS = Tower:New{
	description         = "Heavy Anti-Missile System",
	buildCostMetal      = 3300,
	airSightDistance 		= 1500,
	maxDamage           = 1000,

	weapons = {	
		[1] = {
			name	= "HAMS",
		},
	},
	customparams = {
		turretturnspeed = 9000,
		elevationspeed  = 9000,
		turrettype = "turret",
    },
	sounds = {
		select = "Turret",
	}
}

return lowerkeys({
	["Turret_AMS"] = Turret_AMS,
})