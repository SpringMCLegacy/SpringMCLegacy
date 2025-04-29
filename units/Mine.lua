local Mine = {
	name              	= "Mine",
	description         = "Explodes!",
	objectName        	= "mine.s3o",
	script				= "Wall.lua",
	category 			= "mine",
	activateWhenBuilt   = true,
	canSelfDestruct		= true,
	maxDamage           = 10000,
	mass                = 1000,
	footprintX			= 1,
	footprintZ 			= 1,
	buildCostMetal      = 1,
	canMove				= false,
	maxVelocity			= 0,
	idleAutoHeal		= 0,
	maxSlope			= 100,
	cantbetransported	= true,
	kamikaze			= true,
	kamikazeDistance	= 25,
	selfDestructAs		= "Mine",
}

return lowerkeys({ ["Mine"] = Mine })