local Warhawk = Assault:New{
	name				= "Warhawk",
	
	--[[leaveTracks			= true,	
	trackType			= "Warhawk",
	trackOffset			= 6,
	trackWidth			= 46,
	trackStretch 		= 2,]]
	
	customparams = {
		tonnage			= 85,
		cockpitheight	= 8.2,
		mods			= {"ferrofibrousarmour", "doubleheatsinks", "xlengine", "targetingcomputer"},
		omni			= true,
    },	
}

local Prime = Warhawk:New{
	description         = "Assault Sniper",
	weapons	= {	
		[1] = {
			name	= "CERPPC",
		},
		[2] = {
			name	= "CERPPC",
			SlaveTo = 1,
		},
		[3] = {
			name	= "CERPPC",
			SlaveTo = 1,
		},
		[4] = {
			name	= "CERPPC",
			SlaveTo = 1,
		},
		[5] = {
			name	= "ALRM10",
		},
	},
		
	customparams = {
		variant			= "Prime",
		speed			= 64,
		price			= 31940,
		heatlimit 		= 20,
		armor			= 13.5,
		maxammo 		= {lrm = 1},
    },
}

return lowerkeys({
	["SJ_Warhawk_P"] = Prime:New(),
})