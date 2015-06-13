local LRMCarrier = LightTank:New{
	name              	= "LRM Carrier",
	description         = "HeavyMissile Support",
	trackWidth			= 23,--width to render the decal
	weapons	= {	
		[1] = {
			name	= "LRM20",
		},
		[2] = {
			name	= "LRM20",
		},
		[3] = {
			name	= "LRM20",
		},
	},
	
	customparams = {
		tonnage			= 60,
		variant         = "",
		speed			= 50,
		price			= 8330,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 2},
		maxammo 		= {lrm = 2},
		squadsize 		= 1,
    },
}

return lowerkeys({
	["FW_LRMCarrier"] = LRMCarrier,
})