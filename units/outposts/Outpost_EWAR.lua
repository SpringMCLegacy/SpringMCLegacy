local Outpost_EWAR = Outpost:New{
	name              	= "Electronic Warfare Station (EWAR)",
	description         = "Deploys a Beagle Active Probe radar tower, ECM and TAG designator lasers",
	maxDamage           = 5000,
	mass                = 5000,
	buildCostMetal      = 5350,
	
	radarDistance		= 2500,
	radarDistanceJam	= 0,
	
	weapons = {
		[1] = {
			name	= "TAG",
			mainDir = [[-1 0 0]],
			maxAngleDif = 200,
		},
		[2] = {
			name	= "TAG",
			mainDir = [[1 0 0]],
			maxAngleDif = 200,
		},
	},
	
	customparams = {
		helptext		= "Ping Pong Potato",
		bap				= true,
		ecm				= true,
    },
	sounds = {
		select = "Seismic",
	}
}

return lowerkeys({ ["outpost_ewar"] = Outpost_EWAR })