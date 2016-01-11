local Tiger = Tank:New{
	name              	= "Tiger",
	description         = "Heavy Strike Tank",
	trackWidth			= 23,--width to render the decal

	weapons	= {	
		[1] = {
			name	= "AC10",
		},
		[2] = {
			name	= "SRM4",
		},
		[3] = {
			name	= "MG",
		},
	},
	
	customparams = {
		tonnage			= 55,
		variant         = "",
		speed			= 60,
		price			= 6190,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 7},
		maxammo 		= {ac10 = 2, srm = 1},
		barrelrecoildist = {[1] = 3},
		squadsize 		= 2,
    },
}

return lowerkeys({
	--["FS_Tiger"] = Tiger:New(),
})