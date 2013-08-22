local Upgrade_Dropzone = {
	name              	= "Dropzone",
	description         = "Landing Demarcation",
	objectName        	= "Upgrade_Dropzone.s3o",
	iconType			= "Ddropzone",
	script				= "Upgrade_Dropzone.lua",
	category 			= "beacon",
	maxDamage           = 50000, -- should never take damage
	footprintX			= 2,
	footprintZ 			= 2,
	-- Colvol
	collisionVolumeType = "box",
	collisionVolumeScales = "4 25 4",
	-- Constructor stuff
	builder				= true,
	builddistance 		= 460,
	workerTime			= 10, -- ?	
	terraformSpeed		= 10000,
	showNanoSpray		= false,
	-- Set in weapondefs_post.lua
	--[[sfxtypes = {
		explosiongenerators = {"custom:beacon"},
	},]]
	
	customparams = {
		helptext		= "A Beacon indicating a strategically important location.",
    },
}

return lowerkeys({ ["Upgrade_Dropzone"] = Upgrade_Dropzone })