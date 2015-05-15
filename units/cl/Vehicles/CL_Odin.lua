local CL_Odin = LightTank:New{
	name              	= "Odin",
	description         = "Light Brawler Tank",
	objectName        	= "CL_Odin.s3o",
	corpse				= "CL_Odin_X",
	sightDistance       = 1200,
	radarDistance      	= 2000,
	maxDamage           = 3000,
	mass                = 2000,
	trackWidth			= 23,--width to render the decal
	buildCostEnergy     = 20,
	buildCostMetal      = 10710,
	maxVelocity		= 4.3, --130kph/30
	maxReverseVelocity= 2.2,
	acceleration    = 1.6,
	brakeRate       = 0.2,
	turnRate 		= 450,

	weapons	= {	
		[1] = {
			name	= "CMPL",
		},
		[2] = {
			name	= "CMPL",
		},
		[3] = {
			name	= "CERSBL",
		},
		[4] = {
			name	= "SSRM2",
		},
	},
	
	customparams = {
		helptext		= "Armament: 2 x Medium Pulse Laser, 1 x ER Small Beam Laser, 1 x Streak SRM-2",
		heatlimit		= 20,
		turrettunspeed  = 75,
		elevationspeed  = 200,
		wheelspeed      = 200,
		maxammo 		= {srm = 120},
		squadsize 		= 4,
    },
}

return lowerkeys({
	["CL_Odin"] = CL_Odin,
})