local Outpost_ControlTower = {
	name              	= "Aero Control Tower",
	description         = "Allows control of Aerospace assets",
	objectName        	= "Outpost_ControlTower.s3o",
	script				= "Outpost_ControlTower.lua",
	iconType			= "beacon",
	category 			= "structure beacon",
	sightDistance       = 800,
	radarDistance      	= 1200,
		activateWhenBuilt   = true,
	maxDamage           = 36000,
	mass                = 5000,
	footprintX			= 6,
	footprintZ 			= 6,
	collisionVolumeType = "box",
	collisionVolumeScales = "75 300 75",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
	buildTime           = 0,
	canMove				= false,
	maxVelocity			= 0,
	idleAutoHeal		= 0,
	maxSlope			= 50,
	builder				= false,
	TEDClass			= "FORT",
		--Makes unit use weapon from /weapons folder
	customparams = {
		dontcount		= 1,
		helptext		= "Allows control of Aerospace assets",
    },
	--sounds = {
    --underattack        = "Dropship_Alarm",
	--},
}

return lowerkeys({ ["Outpost_ControlTower"] = Outpost_ControlTower })