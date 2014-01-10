local CL_Mistlynx = Light:New{
	corpse				= "CL_Mistlynx_X",
	sightDistance       = 1200,
	radarDistance      	= 2000,
	maxDamage           = 6700,
	mass                = 2000,
	buildCostEnergy     = 20,
	buildCostMetal      = 13650,
	maxVelocity		= 6.5, --130kph/30
	maxReverseVelocity= 3.25,
	acceleration    = 2.0,
	brakeRate       = 0.1,
	turnRate 		= 900,
	
	customparams = {
		hasbap 			= true,
		heatlimit		= 20,
		torsoturnspeed	= 200,
		canjump			= "1",
		maxammo 		= {lrm = 120, srm = 80},
    },
}

local Prime = CL_Mistlynx:New{
	name              	= "Mist Lynx (Koshi) Prime",
	description         = "Light Missile Support Mech",
	objectName        	= "CL_Mistlynx.s3o",	
	weapons = {	
		[1] = {
			name	= "LRM10",
		},
		[2] = {
			name	= "NARC",
		},
		[3] = {
			name	= "MG",
		},
		[4] = {
			name	= "MG",
		},
		[5] = {
			name	= "SSRM4",
		},
	},

	customparams = {
		helptext		= "Armament: 1 x LRM-10, 1 x SSRM-4, 2 x MG - Armor: 3.5 tons Ferro-Fibrous",
    },
}

return lowerkeys({
	["CL_Mistlynx_Prime"] = Prime,
})