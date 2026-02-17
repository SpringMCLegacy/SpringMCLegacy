weaponDef = {
	avoidfeature = false,
	craterareaofeffect = 0,
	craterboost = 0,
	cratermult = 0,
	edgeeffectiveness = 0.15,
	name = "LAMS Shield",
	weapontype = "Shield",
	shield = {
		alpha = 0.2,
		armortype = "shields",
		intercepttype = 4,
		power = 3000,
		powerregen = 500,
		radius = 500,
		smart = true,
		--visible = true,
		startingpower = 3000,
		badcolor = {
			[1] = 1,
			[2] = 0.2,
			[3] = 0.2,
			[4] = 0.2,
		},
		goodcolor = {
			[1] = 0.2,
			[2] = 1,
			[3] = 0.2,
			[4] = 0.17,
		},
	},
}

return lowerkeys({ LAMS_Shield = weaponDef })