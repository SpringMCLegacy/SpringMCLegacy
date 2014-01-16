local Dropship = Unit:New{
	name              	= "Dropship",
	description         = "Lance Delivery Dropship",
	objectName        	= "Dropship.s3o",
	iconType			= "dropship",
	script				= "Dropship_fx.lua",
	category 			= "dropship structure notbeacon",
	activateWhenBuilt   = true,
	maxDamage           = 180000,
	mass                = 36000,
	footprintX			= 20,
	footprintZ 			= 20,
	collisionVolumeType = "ellipsoid",
	idleAutoHeal		= 0,
	transportSize		= 8,
	transportCapacity	= 80, -- 10x transportSize
	transportMass		= 100000,
	holdSteady 			= true,

	weapons 		= {	
		[1] = {
			name	= "LBL",
			mainDir = "0 0 1",
			maxAngleDif = 90,
		},
		[2] = {
			name	= "LBL",
			mainDir = "1 0 0",
			maxAngleDif = 90,
		},
		[3] = {
			name	= "LBL",
			mainDir = "0 0 -1",
			maxAngleDif = 90,
		},
		[4] = {
			name	= "LBL",
			mainDir = "-1 0 0",
			maxAngleDif = 90,
		},
	},
	
	--Gets CEG effects from /gamedata/explosions folder
	sfxtypes = {
		explosiongenerators = {
		--[["custom:MISSILE_MUZZLEFLASH",
		"custom:PPC_MUZZLEFLASH",
		"custom:LARGELASER_MUZZLEFLASH",]]
		"custom:dropship_main_engine_stage2",
		"custom:dropship_main_engine_stage3",
		--"custom:dropship_heavy_dust",
		"custom:heavy_jet_trail",
		"custom:heavy_jet_trail_blue",
		"custom:dropship_reentry",
		},
	},
	customparams = {
		helptext		= "A Dropship",
		hasbap			= true,
    },
	sounds = {
		underattack        = "Dropship_Alarm",
	},
}

return lowerkeys({
	["IS_Dropship"] = Dropship,
	["CL_Dropship"] = Dropship:New{},
})