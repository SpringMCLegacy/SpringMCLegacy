local Wall_Gate = {
	name              	= "Gate",
	description         = "Wall Entrance",
	objectName        	= "Wall_Gate.s3o",
	script				= "Gate.lua",
	corpse				= "Wall_X",
	--iconType			= "",
	category 			= "structure ground notbeacon",
	activateWhenBuilt   = true,
	canSelfDestruct		= false,
	onOffAble			= true,
	maxDamage           = 5000,
	mass                = 1000,
	footprintX			= 7,
	footprintZ 			= 7,
	collisionVolumeType = "box",
	collisionVolumeScales = "120 85 25",
	collisionVolumeOffsets = "0 -20 0",
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
	canMove				= false,
	maxVelocity			= 0,
	idleAutoHeal		= 0,
	maxSlope			= 100,

	customparams = {
		ammosupplier	= "0",
		supplyradius	= "0",
		helptext		= "A Wall",
		wall			= true,
    },
}

return lowerkeys({ ["Wall_Gate"] = Wall_Gate })