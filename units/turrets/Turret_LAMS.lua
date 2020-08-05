local Turret_LAMS = Tower:New{
	description         = "Laser Anti-Missile System",
	buildCostMetal      = 3300,
	airSightDistance 		= 1500,
	maxDamage           = 1000,

	weapons = {	
		[1] = {
			name	= "LAMS",
		},
		[2] = {
			name	= "LAMS",
		},
		[3] = {
			name	= "LAMS",
		},
		[4] = {
			name	= "LAMS",
		},
	},
	customparams = {
		turretturnspeed = 3000,
		elevationspeed  = 3000,
		turrettype = "missile",
    },
	sounds = {
		select = "Turret",
	}
}

return lowerkeys({
	--["Turret_LAMS"] = Turret_LAMS,
})