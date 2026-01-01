-- Towers ----
local Turret = Unit:New{
	name              	= "Weapon Emplacement",
	script				= "Turret.lua",
	category 			= "structure notbeacon ground",
	iconType			= "turret",
	activateWhenBuilt   = true, -- false? activate when deployed?
	buildCostMetal      = 6000,
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
	buildingMask		= 2,

	customparams = {
		ignoreatbeacon = true,
		baseclass		= "turret",
		slotcost		= 1,
	},
	
	sounds = {
		select = "Turret",
	},
}

local HeavyTurret = Turret:New{
	footprintX			= 5,
	footprintZ 			= 5,
	maxDamage           = 8000,
	
	customparams = {
		slotcost		= 2,
	},
	
	sounds = {
		select = "TurretHeavy",
	},
}

return {
	Turret = Turret,
	HeavyTurret = HeavyTurret,
}
