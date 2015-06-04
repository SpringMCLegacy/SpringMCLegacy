local Manteuffel = Tank:New{
	name              	= "Manteuffel",
	trackWidth			= 23,--width to render the decal
	
	customparams = {
		tonnage			= 75,
    },
}

local ManteuffelRAC = Manteuffel:New{
	description         = "Heavy Brawler Tank",
	trackWidth			= 23,--width to render the decal
	
	weapons	= {	
		[1] = {
			name	= "RAC5",
		},
		[2] = {
			name	= "ERMBL",
		},
		[3] = {
			name	= "ERMBL",
		},
		[4] = {
			name	= "ERMBL",
		},
	},
	
	customparams = {
		variant         = "RAC",
		speed			= 80,
		price			= 10170,
		heatlimit 		= 20,
		armor			= {type = "ferro", tons = 10},
		maxammo 		= {ac5 = 4},
		squadsize 		= 2,
		ecm				= true,
    },
}

local ManteuffelHG = Manteuffel:New{
	description         = "Heavy Brawler Tank",
	trackWidth			= 23,--width to render the decal
	
	weapons	= {	
		[1] = {
			name	= "HeavyGauss",
		},
		[2] = {
			name	= "MBL",
		},
		[3] = {
			name	= "ERSBL",
		},
	},
	
	customparams = {
		variant         = "HG",
		speed			= 80,
		price			= 10280,
		heatlimit 		= 20,
		armor			= {type = "ferro", tons = 10},
		maxammo 		= {hvgauss = 4},
		barrelrecoildist = {[1] = 7},
		squadsize 		= 1,
    },
}
	
return lowerkeys({
	["FS_Manteuffel"] = ManteuffelRAC,
	["LA_Manteuffel"] = ManteuffelHG,
})