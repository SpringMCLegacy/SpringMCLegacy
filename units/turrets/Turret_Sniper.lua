local Turret_Sniper = Tower:New{
	description         = "Sniper Artillery",
	buildCostMetal      = 9700,
	maxDamage           = 2500,
	footprintX			= 5,
	footprintZ 			= 5,

	weapons	= {	
		[1] = {
			name	= "Sniper",
			OnlyTargetCategory = "notbeacon",
		},
	},
	customparams = {
		barrelrecoildist = {[1] = 6},
		maxammo 		= {sniper = 2},
		turretturnspeed = 30,
		elevationspeed  = 50,
		turrettype = "ranged",
    },
	sounds = {
		select = "Turret",
	}
}

return lowerkeys({
	["Turret_Sniper"] = Turret_Sniper,
})