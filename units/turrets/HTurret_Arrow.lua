local HTurret_Arrow = HeavyTurret:New{
	description         = "Arrow IV Artillery (Homing) Launcher",
	buildCostMetal      = 7300,
	maxDamage           = 2000,

	weapons	= {	
		[1] = {
			name	= "ArrowIV",
		},
		--[[[2] = {
			name	= "ArrowIV",
		},]]
	},
	customparams = {
		maxammo 		= {arrow = 2},
		turretturnspeed = 90,
		elevationspeed  = 90,
    },
}

return lowerkeys({
	["HTurret_Arrow"] = HTurret_Arrow,
})