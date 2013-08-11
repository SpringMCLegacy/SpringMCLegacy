local Turret_ECM = {
	name              	= "ECM Emplacement",
	description         = "Electronic Counter-Measure (ECM)",
	objectName        	= "Turret_LAMS.s3o",
	script				= "Turret.lua",
	category 			= "structure notbeacon ground",
		activateWhenBuilt   = true,
	maxDamage           = 12000,
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
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
		},
	customparams = {
		towertype 		= "ecm",
		hasecm			= "true",
		ammosupplier	= "0",
		supplyradius	= "0",
		flagdefendrate	= "100",
		helptext		= "An auto-spawning defensive turret for Garrisons.",
		turretturnspeed = "300",
		elevationspeed  = "300",
    },
	sounds = {
		underattack        = "Dropship_Alarm",
	},
}

return lowerkeys({ ["Turret_ECM"] = Turret_ECM })