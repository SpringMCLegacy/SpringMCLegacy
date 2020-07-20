local Turret_Sniper = Tower:New{
	description         = "Sniper Artillery",
	buildCostMetal      = 4000,

	weapons	= {	
		[1] = {
			name	= "Sniper",
			OnlyTargetCategory = "notbeacon",
		},
	},
	customparams = {
		barrelrecoildist = {[1] = 6},
		maxammo 		= {sniper = 2},
		turretturnspeed = 100,
		elevationspeed  = 150,
		turrettype = "turret",
    },
	sounds = {
	select = "Turret",
	}
}

return lowerkeys({
	["Turret_Sniper"] = Turret_Sniper,
})