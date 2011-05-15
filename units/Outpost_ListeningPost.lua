local Outpost_ListeningPost = {
	name              	= "Observation Outpost",
	description         = "Automated Observation Post",
	objectName        	= "Outpost_ListeningPost.s3o",
	script				= "Outpost_ListeningPost.lua",
	iconType			= "beacon",
	category 			= "structure beacon",
	sightDistance       = 1200,
	radarDistance      	= 2000,
		activateWhenBuilt   = true,
	maxDamage           = 22000,
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
		helptext		= "An observation outpost equipped with advanced sensors.",
    },
	--sounds = {
    --underattack        = "Dropship_Alarm",
	--},
}

return lowerkeys({ ["Outpost_ListeningPost"] = Outpost_ListeningPost })