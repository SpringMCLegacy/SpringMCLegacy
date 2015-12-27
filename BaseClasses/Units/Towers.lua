-- Towers ----
local Tower = Unit:New{
	name              	= "Weapon Emplacement", -- overwritten by ecm & bap
	script				= "Turret.lua",
	category 			= "structure notbeacon ground",
	activateWhenBuilt   = true, -- false? activate when deployed?
	buildCostMetal      = 3000,
	maxDamage           = 4000,
	mass                = 5000,
	footprintX			= 3,
	footprintZ 			= 3,
	maxSlope			= 100,
	collisionVolumeType = "box",
	collisionVolumeScales = "25 25 25",
	canMove				= false,
	maxVelocity			= 0,
	idleAutoHeal		= 0,

	customparams = {
		ignoreatbeacon = true,
		baseclass		= "tower",
	}
}

return {
	Tower = Tower,
}
