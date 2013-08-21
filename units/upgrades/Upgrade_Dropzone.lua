local Upgrade_Dropzone = {
	name              	= "Dropzone",
	description         = "Landing Demarcation",
	objectName        	= "Upgrade_Dropzone.s3o",
	iconType			= "Ddropzone",
	script				= "Upgrade_Dropzone.lua",
	category 			= "beacon",
	sightDistance       = 0,
	radarDistance      	= 0,
	activateWhenBuilt   = true,
	maxDamage           = 50000,
	mass                = 1000,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = "4 25 4",
	collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
	buildCostEnergy     = 0,
	buildCostMetal      = 0,
	buildTime           = 0,
	--canMove				= false,
	energyStorage		= 0,
	metalMake			= 0,
	metalStorage		= 0,
	idleAutoHeal		= 0,
	maxSlope			= 50,
		movementClass   = "LARGEMECH",
		
	-- Constructor stuff
	builder				= true,
	builddistance 		= 460,
	workerTime			= 10, -- ?	
	terraformSpeed		= 10000,
	showNanoSpray		= false,
	--[[sfxtypes = {
		explosiongenerators = {"custom:reentry_fx", "custom:JumpJetTrail"},
	},]]
	
	customparams = {
		dontcount		= 1,
		helptext		= "A Beacon indicating a strategically important location.",
		minbuildrange	= 230,
    },
	
	sounds = {
    underattack        = "Dropship_Alarm",
	},
}

return lowerkeys({ ["Upgrade_Dropzone"] = Upgrade_Dropzone })