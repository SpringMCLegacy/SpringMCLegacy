local CL_Summoner = Heavy:New{
	corpse				= "CL_Summoner_X",
	maxDamage           = 18200,
	mass                = 7000,
	buildCostEnergy     = 70,
	buildCostMetal      = 34580,
	maxVelocity		= 4.3, --86kph/20
	maxReverseVelocity= 2.15,
	acceleration    = 1,
	brakeRate       = 0.2,
	turnRate 		= 700,
	
	customparams = {
		heatlimit		= 28,
		torsoturnspeed	= 130,
		canjump			= "1",
    },
}
	
local C = CL_Summoner:New{
	name              	= "Summoner (Thor) C",
	description         = "Heavy Brawler Mech",
	objectName        	= "CL_Summoner.s3o",
	weapons = {	
		[1] = {
			name	= "UAC20",
		},
		[2] = {
			name	= "CLPL",
		},
		[3] = {
			name	= "CSPL",
		},
		[4] = {
			name	= "SRM6",
		},
	},
		
	customparams = {
		helptext		= "Armament: 1 x UAC/20, 1 x Large Pulse Laser, 1 x Small Pulse Laser, 1 x SRM-6 - Armor: 9.5 tons Ferro-Fibrous",
    },
}

return lowerkeys({
	["CL_Summoner_C"] = C,
})