local Hunter = LightTank:New{
	name              	= "Hunter",
	description			= "LRM Support Tank",
	trackWidth			= 23,--width to render the decal
	
	weapons	= {	
		[1] = {
			name	= "LRM15",
		},
		[2] = {
			name	= "LRM15",
		},
	},
	
	customparams = {
		tonnage			= 35,
		variant         = "Upgrade",
		speed			= 60,
		price			= 6410,
		heatlimit 		= 10,
		armor			= {type = "ferro", tons = 4},
		maxammo 		= {lrm = 1},
		squadsize 		= 1,
    },
}

return lowerkeys({
	["CC_Hunter"] = Hunter:New(),
	["DC_Hunter"] = Hunter:New(),
	["FS_Hunter"] = Hunter:New(),
	["FW_Hunter"] = Hunter:New(),
	["LA_Hunter"] = Hunter:New(),
})