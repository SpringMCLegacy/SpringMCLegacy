

local Outpost_C3Array = Outpost:New{
	name              	= "C3 Network Router",
	description         = "A Command, Control & Communications facility to increase your Mech control capacity",
	iconType			= "outpost_c3array",
	maxDamage           = 5200,
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