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
			name	= "LAMS_Shield",
		},
	},
	customparams = {
		turretturnspeed = 9000,
		elevationspeed  = 9000,
		turrettype = "missile",
    },
	sounds = {
		select = "Turret",
	}
}

return lowerkeys({
	["Turret_LAMS"] = Turret_LAMS,
})