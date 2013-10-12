local CL_Cougar = Light:New{
	corpse				= "CL_Cougar_X",
	maxDamage           = 10500,
	mass                = 3500,
	buildCostEnergy     = 35,
	buildCostMetal      = 16920,
	maxVelocity		= 4.3, --86kph/20
	maxReverseVelocity= 2.15,
	acceleration    = 1.7,
	brakeRate       = 0.1,
	turnRate 		= 950,

	customparams = {
		helptext		= "Armament: 2 x Large Pulse Laser, 2 x SSRM-4 - Armor: 5.5 tons",
		heatlimit		= 20,
		torsoturnspeed	= 180,
    },
}
	
local Prime = CL_Cougar:New{
	name              	= "Cougar Prime",
	description         = "Light Brawler Mech",
	objectName        	= "CL_Cougar.s3o",
	weapons 		= {	
		[1] = {
			name	= "CLPL",
		},
		[2] = {
			name	= "CLPL",
		},
		[3] = {
			name	= "SSRM4",
		},
		[4] = {
			name	= "SSRM4",
		},
	},
}
return lowerkeys({
	["CL_Cougar_Prime"] = Prime,
})