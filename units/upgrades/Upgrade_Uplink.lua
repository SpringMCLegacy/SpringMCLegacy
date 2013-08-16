local Upgrade_Uplink = {
	name              	= "Orbital Uplink",
	description         = "Orbital Asset Upgrade",
	objectName        	= "Upgrade_Uplink.s3o",
	script				= "Upgrade_Uplink.lua",
	iconType			= "beacon",
	category 			= "structure ground notbeacon",
		activateWhenBuilt   = true,
	maxDamage           = 10000,
	mass                = 5000,
	footprintX			= 3,
	footprintZ 			= 3,
	collisionVolumeType = "box",
	collisionVolumeScales = "25 25 25",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
	buildTime           = 0,
	canMove				= false,
	maxVelocity			= 0,
	idleAutoHeal		= 0,
	maxSlope			= 100,
	builder				= false,
	TEDClass			= "FORT",
		--Makes unit use weapon from /weapons folder
	customparams = {
		dontcount		= 1,
		helptext		= "Grants access to various abilities and upgrades.",
		hasbap			= true,
    },
	--sounds = {
    --underattack        = "Dropship_Alarm",
	--},
}

return lowerkeys({ ["Upgrade_Uplink"] = Upgrade_Uplink })