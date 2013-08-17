local Upgrade_C3Array = {
	name              	= "C3 Network Relay",
	description         = "Command & Control Capacity Upgrade",
	objectName        	= "Upgrade_C3Array.s3o",
	script				= "Upgrade_C3Array.lua",
	iconType			= "beacon",
	category 			= "structure ground notbeacon",
		activateWhenBuilt   = true,
	maxDamage           = 2200,
	mass                = 10000,
	footprintX			= 7,
	footprintZ 			= 7,
	collisionVolumeType = "box",
	collisionVolumeScales = "75 75 75",
	collisionVolumeOffsets = "0 0 0",
	buildCostEnergy     = 0,
	buildCostMetal      = 1000,
	buildTime           = 0,
	canMove				= true,
	maxVelocity			= 0,
	idleAutoHeal		= 0,
	maxSlope			= 100,
	energyStorage		= 200, -- grants 200 extra Tonnage space, need to lua it arriving with 200 e
	cantbetransported	= false,

	customparams = {
		dontcount		= 1,
		helptext		= "Adds additional control slots for your forces",
    },
	--sounds = {
    --underattack        = "Dropship_Alarm",
	--},
}

return lowerkeys({ ["Upgrade_C3Array"] = Upgrade_C3Array })