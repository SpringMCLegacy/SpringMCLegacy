local IS_Avenger = {
	name              	= "Avenger-Class Dropship",
	description         = "Prefab Delivery Dropship",
	objectName        	= "IS_Avenger.s3o",
	iconType			= "dropship",
	script				= "Dropship_Assault.lua",
	category 			= "dropship structure notbeacon",
	activateWhenBuilt   = true,
	maxDamage           = 180000,
	mass                = 36000,
	footprintX			= 20,
	footprintZ 			= 20,
	--collisionVolumeType = "ellipsoid",
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
	buildTime           = 0,
	canMove				= true,
	maxVelocity			= 0,
	energyStorage		= 0.01,
	metalMake			= 400,
	metalStorage		= 50000,
	idleAutoHeal		= 0,
	maxSlope			= 50,
	moveState			= 0,
	levelGround			= false,
	
	-- Transport tags
	transportSize		= 5,
	minTransportSize	= 5, -- ?
	transportCapacity	= 5, -- 1x transportSize
	transportMass		= 10000,
	minTransportMass	= 10000,

	--Makes unit use weapon from /weapons folder
	weapons	= {	

	},
	--Gets CEG effects from /gamedata/explosions folder
	--[[sfxtypes = {
		explosiongenerators = {
		},
	},]]
	customparams = {
		helptext		= "A Dropship",
    },
	sounds = {
		underattack        = "Dropship_Alarm",
	},
}

return lowerkeys({["IS_Avenger"] = IS_Avenger})