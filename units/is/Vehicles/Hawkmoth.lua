local Hawkmoth = VTOL:New{
	name              	= "Hawk Moth",
	description         = "Light Sniper VTOL",
	verticalSpeed	= 1,

	weapons	= {	
		[1] = {
			name	= "LightGauss",
			maxAngleDif = 180,
		},
	},
	
	customparams = {
		tonnage			= 25,
		variant         = "",
		speed			= 130,
		price			= 3340,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 1.5},
		maxammo 		= {ltgauss = 2},
		squadsize 		= 2,
    },
}

return lowerkeys({
	["FW_Hawkmoth"] = Hawkmoth,
})