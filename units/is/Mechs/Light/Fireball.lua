local Fireball = Light:New{
	name              	= "Fireball",
	
	leaveTracks			= true,	
	trackType			= "Fireball",
	trackOffset			= 6,
	trackWidth			= 26,
	trackStretch 		= 2,
	
	customparams = {
		cockpitheight	= 5.95,
		tonnage			= 20,
    },
}

local ALM9D = Fireball:New{
	description         = "Light Scout",
	weapons = {	
		[1] = {
			name	= "MBL",
		},
		[2] = {
			name	= "SSRM2",
		},
	},
		
	customparams = {
		variant         = "ALM-9D",
		speed			= 170,
		price			= 6740,
		heatlimit 		= 10,
		armor			= 4.5,
		maxammo 		= {srm = 1},
    },
}

return lowerkeys({
	["FS_Fireball_ALM9D"] = ALM9D:New(),
})