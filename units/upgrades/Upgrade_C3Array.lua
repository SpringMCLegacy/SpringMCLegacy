local Upgrade_C3Array = Upgrade:New{
	name              	= "C3 Network Relay",
	description         = "Command & Control Capacity Upgrade",
	objectName        	= "Upgrade_C3Array.s3o",
	maxDamage           = 2200,
	mass                = 10000,
	buildCostMetal      = 15000,
	energyStorage		= 200, -- grants 200 extra Tonnage space, need to lua it arriving with 200 e

	customparams = {
		helptext		= "Adds additional control slots for your forces",
    },
}

return lowerkeys({ ["Upgrade_C3Array"] = Upgrade_C3Array })