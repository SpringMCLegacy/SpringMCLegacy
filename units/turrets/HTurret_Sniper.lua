local HTurret_Sniper = HeavyTurret:New{
	description         = "Sniper Artillery",
	buildCostMetal      = 19400,
	maxDamage           = 2500,

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
    },
}

return lowerkeys({
	["HTurret_Sniper"] = HTurret_Sniper,
})