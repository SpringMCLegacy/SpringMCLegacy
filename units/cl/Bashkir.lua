local Bashkir = Aero:New{
	name              	= "Bashkir",
	description         = "Light Interceptor",
	
	acceleration       = 0.42,
	maxAcc             = 1.2,
	turnRadius         = 90,
	wingDrag           = 0.05,
	wingAngle          = 0.08,
	crashDrag          = 0.005,
	maxBank            = 0.72,
	maxPitch           = 0.6,
	verticalSpeed      = 4.0,
	maxAileron         = 0.013,
	maxElevator        = 0.013,
	maxRudder          = 0.0022,
	
	weapons = {	
		[1] = {
			name	= "CERMBL",
			maxAngleDif = 35,
		},
		[2] = {
			name	= "CERMBL",
			maxAngleDif = 35,
		},
		[3] = {
			name	= "CERSBL",
			maxAngleDif = 35,
		},
		[4] = {
			name	= "SSRM4", -- should be 2?
			maxAngleDif = 35,
		},
	},
	
	customparams = {
		tonnage			= 30,
		variant         = "Prime",
		speed			= 468 * 1.5, -- 4680
		price			= 5450,
		heatlimit 		= 20,
		armor			= 2,
		maxammo 		= {srm = 2},
		
		entryDelay 		= 5,
		prepDelay 		= 10,
    },
}

aeros = {}

aeros["wf_bashkir_p"] = Bashkir:New{}
return lowerkeys(aeros)