local CL_Bashkir = Aero:New{
	name              	= "Bashkir",
	description         = "Light Interceptor ASF",
	objectName        	= "CL_Bashkir.s3o",
	sightDistance       = 1200,
	radarDistance      	= 1500,
	maxDamage           = 260,
	mass                = 2000,
	buildCostEnergy     = 20,
	buildCostMetal      = 4500,
	turnRadius		= 1000,
	maxAcc			= 0.2,
	maxBank			= 0.0007,
	maxPitch		= 0.0007,
	maxAileron		= 0.0045,
	maxElevator		= 0.004,
	maxRudder		= 0.002,
	wingAngle		= 0.1,
	wingDrag		= 0.07,
	myGravity		= 0.8,
	
	weapons	= {	
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
			name	= "SSRM4",
			maxAngleDif = 70,
		},
	},
	customparams = {
		helptext		= "Armament: 2 x Medium Pulse Laser, 1 x ER Small Beam Laser, 1 x SSRM-4 - Armor: 2 tons",
		heatlimit		= 15,
		maxmmo = {srm = 120},
    },
}

return lowerkeys({
	["CL_Bashkir"] = CL_Bashkir,
})