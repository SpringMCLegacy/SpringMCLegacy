local Outpost_Uplink = Outpost:New{
	name              	= "Orbital Uplink (Bombard)",
	description         = "Allows control over orbital bombardment assets",
	maxDamage           = 5500,
	mass                = 5000,
	buildCostMetal      = 8300,

	-- Constructor stuff
	builder				= true,
	builddistance 		= 1000000,
	workerTime			= 10, -- ?	
	terraformSpeed		= 10000,
	showNanoSpray		= false,
	
	customparams = {
		helptext		= "Grants access to various abilities and outposts.",
		hasbap			= true,
    },
	sounds = {
		select = "Uplink",
	}
}

return lowerkeys({ ["outpost_Uplink"] = Outpost_Uplink })