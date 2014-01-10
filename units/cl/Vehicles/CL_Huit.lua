local CL_Huit = LightTank:New{
	name              	= "Huitzilopochtli",
	description         = "Heavy Artillery Support Vehicle",
	objectName        	= "CL_Huit.s3o",
	corpse				= "CL_Huit_X",
	radarDistanceJam    = 500,
	maxDamage           = 9800,
	mass                = 8500,
	trackWidth			= 22,--width to render the decal
	buildCostEnergy     = 85,
	buildCostMetal      = 12420,
	maxVelocity		= 1.06, --32kph/30
	maxReverseVelocity= 0.8,
	acceleration    = 0.9,
	brakeRate       = 0.1,
	turnRate 		= 500,
	
	weapons = {	
		[1] = {
			name	= "ArrowIV",
		},
		[2] = {
			name	= "ArrowIV",
		},
		[3] = {
			name	= "CMPL",
		},
		[4] = {
			name	= "CMPL",
		},
	},
	customparams = {
		helptext		= "Armament: 2 x Arrow IV Artillery Missle, 2 x Medium Pulse Laser - Armor: 5.5 tons",
		heatlimit		= 20,
		turretturnspeed = 50,
		elevationspeed  = 75,
		maxmmo = {arrow = 10},
    },
}

return lowerkeys({
	["CL_Huit"] = CL_Huit,
})