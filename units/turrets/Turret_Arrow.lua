local Turret_Arrow = Tower:New{
	description         = "Air Defense Arrow",
	buildCostMetal      = 7300,
	footprintX			= 5,
	footprintZ 			= 5,

	weapons	= {	
		[1] = {
			name	= "ADArrow",
			onlyTargetCategory = "air",
		},
	},
	customparams = {
		maxammo 		= {arrow = 1},
		turretturnspeed = 90,
		elevationspeed  = 90,
		turrettype = "ranged",
    },
	sounds = {
		select = "Turret",
	}
}

return lowerkeys({
	["Turret_Arrow"] = Turret_Arrow,
})