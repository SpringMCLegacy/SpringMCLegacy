local HollanderII = Medium:New{
	name				= "Hollander II",
	customparams = {
		cockpitheight	= 6,
		tonnage			= 45,
    },
}

local BZKF7 = HollanderII:New{
	description         = "Medium Sniper",
	weapons	= {	
		[1] = {
			name	= "HeavyGauss",
			OnlyTargetCategory = "ground",
		},
	},
	
    customparams = {
		variant         = "BZK-F7",
		speed			= 80,
		price			= 11920,
		heatlimit 		= 10,
		armor			= 5.5,
		maxammo 		= {hvgauss = 3},
		barrelrecoildist = {[1] = 4},
		mods			= {"ferrofibrousarmour"},
    },
}

return lowerkeys({ 
	["LA_HollanderII_BZKF7"] = BZKF7:New(),
})