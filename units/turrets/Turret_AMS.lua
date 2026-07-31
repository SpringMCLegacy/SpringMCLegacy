local Turret_AMS = Turret:New{
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
		normaltex		= "unittextures/normals/TurretsB_Normals.dds",
    },
}

return lowerkeys({
	["Turret_AMS"] = Turret_AMS,
})