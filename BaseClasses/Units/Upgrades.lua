-- Upgrades ----
local Upgrade = Unit:New{
	script				= "Upgrade.lua",
	iconType			= "upgrade",
	category 			= "structure ground notbeacon",
	activateWhenBuilt   = true,
	footprintX			= 4,
	footprintZ 			= 4,
	collisionVolumeType = "box",
	collisionVolumeScales = [[75 75 75]],
	buildCostEnergy     = 0,
	buildCostMetal      = 15000, -- overridden by C3 & Garrison
	canMove				= true,
	maxVelocity			= 0,
	idleAutoHeal		= 0,
	maxSlope			= 100,
	cantbetransported	= false,
	
	customparams = {
		upgrade = true,
		baseclass		= "upgrade",
	},
}

return {
	Upgrade = Upgrade,
}
