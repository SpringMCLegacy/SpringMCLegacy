

local Outpost_C3Array = Outpost:New{
	name              	= "C3 Network Relay (Reinforce)",
	description         = "Command & Control Capacity outpost",
	maxDamage           = 2200,
	mass                = 10000,
	buildCostMetal      = 13000,
	istargetingoutpost 	= true,
	--energyStorage		= modOptions and modOptions.startenergy or 150, -- grants 150 extra Tonnage space, need to lua it arriving with 150 e

	customparams = {
		helptext		= "Adds additional control slots for your forces",
    },
	sounds = {
	select = "C3Array",
	}
}

return lowerkeys({ ["outpost_C3Array"] = Outpost_C3Array })