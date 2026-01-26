local Outpost_Sensor = Outpost:New{
	name              	= "Sensor Outpost",
	description         = "A static, long-range sensor equipped with an upgradable Active Probe system",
	iconType			= "outpost_sensor",
	maxDamage           = 5000,
	mass                = 5000,
	buildCostMetal      = 4800,
	
	customparams = {
		bap				= true,
    },
	sounds = {
		select = "Seismic",
	}
}

return lowerkeys({ ["outpost_sensor"] = Outpost_Sensor })