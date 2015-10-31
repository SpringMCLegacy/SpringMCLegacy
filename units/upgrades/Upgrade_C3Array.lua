

local Upgrade_C3Array = Upgrade:New{
	name              	= "C3 Network Relay",
	description         = "Command & Control Capacity Upgrade",
	maxDamage           = 2200,
	mass                = 10000,
	buildCostMetal      = 15000,
	--energyStorage		= modOptions and modOptions.startenergy or 150, -- grants 150 extra Tonnage space, need to lua it arriving with 150 e

	customparams = {
		helptext		= "Adds additional control slots for your forces",
    },
}

return lowerkeys({ ["Upgrade_C3Array"] = Upgrade_C3Array })