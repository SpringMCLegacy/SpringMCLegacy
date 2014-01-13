local Wall = {
	name              	= "Wall",
	description         = "Fortified Barrier",
	objectName        	= "Wall.s3o",
	script				= "Wall.lua",
	corpse				= "Wall_X",
	--iconType			= "",
	category 			= "structure ground notbeacon",
	activateWhenBuilt   = true,
	maxDamage           = 10000,
	mass                = 1000,
	footprintX			= 7,
	footprintZ 			= 7,
	collisionVolumeType = "box",
	collisionVolumeScales = "120 85 25",
	collisionVolumeOffsets = "0 -20 0",
	buildCostEnergy     = 0,
	buildCostMetal      = 500,
	buildTime           = 0,
	canMove				= false,
	maxVelocity			= 0,
	idleAutoHeal		= 0,
	maxSlope			= 100,
	cantbetransported	= false,

	customparams = {
		ammosupplier	= "0",
		supplyradius	= "0",
		helptext		= "A Wall",
		--flagdefendrate = 0,
    },
	--sounds = {
    --underattack        = "Dropship_Alarm",
	--},
}

return lowerkeys({ ["Wall"] = Wall })