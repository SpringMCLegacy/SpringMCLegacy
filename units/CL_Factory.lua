local CL_Factory = {
	name              	= "Dropship",
	description         = "Unit Aquisition Facility",
	objectName        	= "Dropship.s3o",
	script				= "CL_Factory.cob",
	category 			= "dropship structure",
	sightDistance       = 1000,
	radarDistance      	= 1500,
		activateWhenBuilt   = true,
	maxDamage           = 50000,
	mass                = 36000,
	footprintX			= 20,
	footprintZ 			= 20,
	collisionVolumeType = "ellipsoid",
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
	buildTime           = 0,
	canMove				= true,
	maxVelocity			= 0,
	energyStorage		= 0.01,
	metalMake			= 100,
	metalStorage		= 50000,
	idleAutoHeal		= 0,
	maxSlope			= 50,
	builder				= true,
		moveState			= 0,
		showNanoFrame		= 0,
		showNanoSpray		= 0,
		workerTime			= 1,
		canBeAssisted	= false,
		yardmap			= "ooccccccccccccccccoo ooccccccccccccccccoo cccccccccccccccccccc  cccccccccccccccccccc  cccccccccccccccccccc  cccccccccccccccccccc  cccccccccccccccccccc  cccccccccccccccccccc  cccccccccccccccccccc  cccccccccccccccccccc  cccccccccccccccccccc  cccccccccccccccccccc  cccccccccccccccccccc  cccccccccccccccccccc  cccccccccccccccccccc  cccccccccccccccccccc  ooccccccccccccccccoo  ooccccccccccccccccoo",
	TEDClass			= PLANT,
	--canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		--weapons 		= {	
		--	[1] = {
		--		name	= "",
		--	},
		--},
	--Gets CEG effects from /gamedata/explosions folder
	sfxtypes = {
		--explosiongenerators = {
		--"MG_MUZZLEFLASH",
		--"MEDIUM_MUZZLEFLASH",
		--},
	},
	customparams = {
		ammosupplier	= "0",
		supplyradius	= "0",
		helptext		= "A Dropship",
    },
	sounds = {
    underattack        = "Dropship_Alarm",
	},
}

return lowerkeys({ ["CL_Factory"] = CL_Factory })