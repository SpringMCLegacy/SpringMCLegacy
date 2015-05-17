local CL_Morrigu = Tank:New{
	name              	= "Morrigu",
	description         = "Heavy Sniper Tank",
	objectName        	= "CL_Morrigu.s3o",
	corpse				= "CL_Morrigu_X",
	radarDistanceJam    = 500,
	maxDamage           = 23200,
	mass                = 8000,
	trackWidth			= 28,--width to render the decal
	buildCostEnergy     = 80,
	buildCostMetal      = 25380,
	maxVelocity		= 1.8, --54kph/30
	maxReverseVelocity= 1.6,
	acceleration    = 0.9,
	brakeRate       = 0.1,
	turnRate 		= 350,
	
	moveState			= 0,
	
	weapons = {	
		[1] = {
			name	= "CERLBL",
		},
		[2] = {
			name	= "CERLBL",
		},
		[3] = {
			name	= "LRM15",
		},
		[4] = {
			name	= "LRM15",
		},
	},
	
	customparams = {
		helptext		= "Armament: 2 x ER Large Beam Laser, 2 x LRM-15 - Armor: 13 tons",
		heatlimit		= 26,
		turretturnspeed = 50,
		elevationspeed = 100,
		wheelspeed = 200,
		maxammo = {lrm = 150},
		squadsize 		= 3,
    },
}

return lowerkeys({
	["CL_Morrigu"] = CL_Morrigu,
})