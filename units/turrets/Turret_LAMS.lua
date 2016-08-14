local Turret_LAMS = Tower:New{
	description         = "Laser Anti-Missile System",
	buildCostMetal      = 3000,

	weapons = {	
		[1] = {
			name	= "LAMS",
		},
	},
	customparams = {
		turretturnspeed = 300,
		elevationspeed  = 300,
    },
}

return lowerkeys({
	["Turret_LAMS"] = Turret_LAMS,
})