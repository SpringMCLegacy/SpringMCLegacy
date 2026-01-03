local HTurret_Arrow = HeavyTurret:New{
	description         = "Arrow IV Artillery (Homing) Launcher",
	buildCostMetal      = 7300,
	maxDamage           = 2000,

	weapons	= {	
		[1] = {
			name	= "ArrowIV_Turret",
		},
		[2] = {
			name	= "ArrowIV_Turret",
			SlaveTo = 1,
		},
	},
	customparams = {
		maxammo 			= {arrow = 1.6 * 4}, -- needs to be multiplied by fake burstLength for the script
		turretturnspeed 	= 50,
		elevationspeed  	= 50,
    },
}

return lowerkeys({
	["HTurret_Arrow"] = HTurret_Arrow,
})