local HTurret_LAMS = HeavyTurret:New{
	description         = "Laser Anti-Missile System",
	buildCostMetal      = 17000,
	airSightDistance 		= 1750,
	maxDamage           = 2000,

	weapons = {	
		[1] = {
			name	= "LAMS",
		},
	},
	customparams = {
		turretturnspeed = 9000,
		elevationspeed  = 9000,
		turrettype = "turret",
    },
}

return lowerkeys({
	["HTurret_LAMS"] = HTurret_LAMS,
})