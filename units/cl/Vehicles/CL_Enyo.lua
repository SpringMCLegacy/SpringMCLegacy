local CL_Enyo = LightTank:New{
	name              	= "Enyo",
	description         = "Medium Strike Tank",
	objectName        	= "CL_Enyo.s3o",
	corpse				= "CL_Enyo_X",
	maxDamage           = 13400,
	mass                = 5500,
	trackWidth			= 24,--width to render the decal
	buildCostEnergy     = 55,
	buildCostMetal      = 15120,
	maxVelocity		= 3.23, --97kph/30
	maxReverseVelocity= 1.6,
	acceleration    = 0.9,
	brakeRate       = 0.1,
	turnRate 		= 500,
	
	weapons 		= {	
		[1] = {
			name	= "SSRM6",
		},
		[2] = {
			name	= "SSRM6",
		},
		[3] = {
			name	= "CLPL",
		},
	},
	customparams = {
		helptext		= "Armament: 1 x Large Pulse Laser, 2 x SSRM-6 - Armor: 7 tons",
		heatlimit		= 28,
		turretturnspeed = 100,
		elevationspeed  = 150,
		maxammo = {srm = 120},
		squadsize 		= 3,
    },
}

return lowerkeys({
	["CL_Enyo"] = CL_Enyo,
})