local CL_Kitfox = Light:New{
	corpse				= "CL_Kitfox_X",
	maxDamage           = 7600,
	mass                = 3000,
	buildCostEnergy     = 30,
	buildCostMetal      = 13320,
	maxVelocity		= 4.85, --97kph/30
	maxReverseVelocity= 2.43,
	acceleration    = 1.8,
	brakeRate       = 0.1,
	turnRate 		= 950,

	customparams = {
		heatlimit		= 20,
		torsoturnspeed	= 180,
    },

}

local Prime = CL_Kitfox:New{
	name              	= "Kit Fox (Uller) Prime",
	description         = "Light Strike Mech",
	objectName        	= "CL_Kitfox.s3o",	
	weapons = {	
		[1] = {
			name	= "CERLBL",
		},
		[2] = {
			name	= "LBX5",
		},
		[3] = {
			name	= "CSPL",
		},
		[4] = {
			name	= "SSRM4",
		},
	},
	
	customparams = {
		helptext		= "Armament: 1 x ER Large Beam Laser, 1 x UAC/5, 1 x Small Pulse Laser, 1 x SSRM-6 - Armor: 4 tons Ferro-Fibrous",
		maxammo 		= {ac5 = 50, srm = 80},
    },
}

local C = CL_Kitfox:New{
	name              	= "Kit Fox (Uller) Alt. Config C",
	description         = "Light Support Mech",
	objectName        	= "CL_Kitfox_C.s3o",	
	weapons = {	
		[1] = {
			name	= "CERLBL",
		},
		[2] = {
			name	= "CSPL",
		},
		[3] = {
			name	= "MG",
		},
		[4] = {
			name	= "MG",
		},
		[5] = {
			name	= "AMS",
		},
		[6] = {
			name	= "AMS",
		},
		[7] = {
			name	= "AMS",
		},
	},
	
	customparams = {
		hasbap = true,
		hasecm = true,
		helptext		= "Armament: 1 x ER Large Beam Laser, 1 x Small Pulse Laser, 2 x MG, 3 x AMS - Armor: 4 tons Ferro-Fibrous",
    },
}

return lowerkeys({
	["CL_Kitfox_Prime"] = Prime,
	["CL_Kitfox_C"] = C,
})