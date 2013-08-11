local Turret_LPL = {
	name              	= "Weapon Emplacement",
	description         = "Quad Medium Pulse Laser",
	objectName        	= "Turret_LPL.s3o",
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
			[1] = {
				name	= "LPL",
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "LPL",
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[3] = {
				name	= "LPL",
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
			[4] = {
				name	= "LPL",
				OnlyTargetCategory = "notbeacon",
				SlaveTo = 1,
			},
		},
	customparams = {
		towertype = "turret",
		flagdefendrate	= "100",
		helptext		= "An auto-spawning defensive turret for Garrisons.",
		turretturnspeed = "175",
		elevationspeed  = "250",
    },
	sounds = {
    underattack        = "Dropship_Alarm",
	},
}

return lowerkeys({ ["Turret_LPL"] = Turret_LPL })