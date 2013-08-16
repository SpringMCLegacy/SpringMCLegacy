local Upgrade_Bunker = {
	name              	= "Bunker",
	description         = "Fortified Defensive Upgrade",
	objectName        	= "Upgrade_Bunker.s3o",
	script				= "Upgrade_Bunker.lua",
	iconType			= "beacon",
	category 			= "structure ground notbeacon",
		activateWhenBuilt   = true,
	maxDamage           = 50000,
	mass                = 10000,
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
		ammosupplier	= "0",
		supplyradius	= "0",
		helptext		= "Heavily-fortified structure resilient to all attacks to fortify captured control points.",
		flagdefendrate = 100,
    },
	--sounds = {
    --underattack        = "Dropship_Alarm",
	--},
}

return lowerkeys({ ["Upgrade_Bunker"] = Upgrade_Bunker })