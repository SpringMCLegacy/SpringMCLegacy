local Upgrade_Uplink = Upgrade:New{
	name              	= "Orbital Uplink",
	description         = "Orbital Asset Upgrade",
	objectName        	= "Upgrade_Uplink.s3o",
	maxDamage           = 10000,
	mass                = 5000,
	buildCostMetal      = 5000,

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
}

return lowerkeys({ ["Upgrade_Uplink"] = Upgrade_Uplink })