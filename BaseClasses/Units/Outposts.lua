-- Outposts ----
local Outpost = Unit:New{
	script				= "Outpost.lua",
	iconType			= "outpost",
	category 			= "structure ground notbeacon",
	activateWhenBuilt   = false,
	footprintX			= 4,
	footprintZ 			= 4,
	--collisionVolumeType = "box",
	collisionVolumeScales = [[75 75 75]],
	buildCostEnergy     = 0,
	buildCostMetal      = 15000, -- overridden by C3 & Garrison
	canMove				= true,
	maxVelocity			= 0,
	idleAutoHeal		= 0,
	maxSlope			= 100,
	cantbetransported	= false,
	
	customparams = {
		outpost = true,
		baseclass		= "outpost",
	},
}

return {
	Outpost = Outpost,
}
