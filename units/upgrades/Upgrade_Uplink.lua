local Upgrade_Uplink = Upgrade:New{
	name              	= "Orbital Uplink",
	description         = "Orbital Asset Upgrade",
	maxDamage           = 10000,
	mass                = 5000,
	buildCostMetal      = 8000,

	collisionVolumeScales = [[25 25 25]],

	-- Constructor stuff
	builder				= true,
	builddistance 		= 1000000,
	workerTime			= 10, -- ?	
	terraformSpeed		= 10000,
	showNanoSpray		= false,
	
	customparams = {
		helptext		= "Grants access to various abilities and upgrades.",
		hasbap			= true,
    },
	sounds = {
	select = "Uplink",
	}
}

return lowerkeys({ ["Upgrade_Uplink"] = Upgrade_Uplink })