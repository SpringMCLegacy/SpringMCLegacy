local Pilum = LightTank:New{
	name              	= "Pilum",
	description         = "Heavy Missile Support",
	trackWidth			= 23,--width to render the decal
	weapons	= {	
		[1] = {
			name	= "ALRM15",
		},
		[2] = {
			name	= "ALRM15",
		},
		[3] = {
			name	= "SSRM2",
			SlaveTo = 1,
		},
		[4] = {
			name	= "SSRM2",
			SlaveTo = 1,
		},
		[5] = {
			name	= "MPL",
			maxAngleDif = 60,
		},
		[6] = {
			name	= "MPL",
			maxAngleDif = 60,
		},
	},
	
	customparams = {
		tonnage			= 70,
		variant         = "",
		speed			= 60,
		price			= 11210,
		heatlimit 		= 20,
		armor			= {type = "ferro", tons = 10},
		maxammo 		= {lrm = 3, srm = 1},
		squadsize 		= 1,
		replaces		= "fs_lrmcarrier",
		wheels			= true,
    },
}

local PilumArrow = Pilum:New{
	description         = "Artillery Support",

	weapons	= {	
		[1] = {
			name	= "ArrowIV",
		},
		[2] = {
			name	= "ArrowIV",
		},
		[3] = {
			name	= "SSRM2",
			SlaveTo = 1,
		},
		[4] = {
			name	= "SSRM2",
			SlaveTo = 1,
		},
		[5] = {
			name	= "MPL",
			maxAngleDif = 60,
		},
		[6] = {
			name	= "MPL",
			maxAngleDif = 60,
		},
	},
	
	customparams = {
		variant         = "(Arrow)",
		price			= 11020,
		maxammo 		= {arrow = 3, srm = 1},
		replaces		= "fs_marksman",
		wheels			= true,
    },
}

return lowerkeys({
	["FS_Pilum"] = Pilum:New(),
	["FS_PilumArrow"] = PilumArrow:New(),
})