

local Outpost_C3Array = Outpost:New{
	name              	= "C3 Network Relay (Reinforce)",
	description         = "Command & Control Capacity outpost",
	maxDamage           = 2200,
	mass                = 10000,
	buildCostMetal      = 13000,
	istargetingoutpost 	= true,

	customparams = {
		helptext		= "Adds additional control slots for your forces",
    },
	sounds = {
	select = "C3Array",
	}
}

return lowerkeys({ ["outpost_C3Array"] = Outpost_C3Array })