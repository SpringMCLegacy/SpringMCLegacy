local Outpost_Uplink = Outpost:New{
	name              	= "Orbital Comms Uplink",
	description         = "An outpost for extraplanetary strategic attacks like aerostrikes and orbital bombardment",
	iconType			= "outpost_uplink",
	maxDamage           = 5500,
	mass                = 5000,
	buildCostMetal      = 13000,

	-- Constructor stuff
	builder				= true,
	builddistance 		= 1000000,
	workerTime			= 10, -- ?	
	terraformSpeed		= 10000,
	showNanoSpray		= false,
	
	customparams = {
    },
	sounds = {
		select = "Uplink",
	}
}

return lowerkeys({ ["outpost_Uplink"] = Outpost_Uplink })