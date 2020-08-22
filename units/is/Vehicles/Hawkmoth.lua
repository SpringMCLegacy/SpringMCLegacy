local Hawkmoth = VTOL:New{
	name              	= "Hawk Moth",
	description         = "Light Sniper VTOL",
	verticalSpeed	= 2,

	weapons	= {	
		[1] = {
			name	= "LightGauss",
			maxAngleDif = 180,
		},
	},
	
	customparams = {
		tonnage			= 25,
		variant         = "",
		speed			= 230,
		price			= 3340,
		heatlimit 		= 10,
		armor			= 1.5,
		maxammo 		= {ltgauss = 2},
		squadsize 		= 2,
		mods			= {"ferrofibrousarmour"},
    },
}

return lowerkeys({
	["CC_Hawkmoth"] = Hawkmoth:New{},
	["DC_Hawkmoth"] = Hawkmoth:New{},
	["FS_Hawkmoth"] = Hawkmoth:New{},
	["FW_Hawkmoth"] = Hawkmoth:New{},
	["LA_Hawkmoth"] = Hawkmoth:New{},
})