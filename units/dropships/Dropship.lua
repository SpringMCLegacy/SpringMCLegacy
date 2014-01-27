local Dropship = Unit:New{
	name              	= "Dropship",
	description         = "Lance Delivery Dropship",
	objectName        	= "Dropship.s3o",
	iconType			= "dropship",
	script				= "Dropship_union.lua",
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
		-- LBLs
		[1] = {
			name	= "LBL",
			mainDir = "0 0 1",
			maxAngleDif = 90,
		},
		[2] = {
			name	= "LBL",
			mainDir = "0 0 1",
			maxAngleDif = 90,
			slaveTo = 1,
		},
		[3] = {
			name	= "LBL",
			mainDir = "-1 0 0",
			maxAngleDif = 90,
		},
		[4] = {
			name	= "LBL",
			mainDir = "-1 0 0",
			maxAngleDif = 90,
			slaveTo = 3,
		},
		[5] = {
			name	= "LBL",
			mainDir = "0 0 -1",
			maxAngleDif = 90,
		},
		[6] = {
			name	= "LBL",
			mainDir = "0 0 -1",
			maxAngleDif = 90,
			slaveTo = 5,
		},
		[7] = {
			name	= "LBL",
			mainDir = "1 0 0",
			maxAngleDif = 90,
		},
		[8] = {
			name	= "LBL",
			mainDir = "1 0 0",
			maxAngleDif = 90,
			slaveTo = 7,
		},
		-- ERMBLs
		[9] = {
			name	= "ERMBL",
			mainDir = "1 -0.5 1",
			maxAngleDif = 90,
		},
		[10] = {
			name	= "ERMBL",
			mainDir = "1 -0.5 1",
			maxAngleDif = 90,
			slaveTo = 9,
		},
		[11] = {
			name	= "ERMBL",
			mainDir = "1 -0.5 -1",
			maxAngleDif = 90,
		},
		[12] = {
			name	= "ERMBL",
			mainDir = "1 -0.5 -1",
			maxAngleDif = 90,
			slaveTo = 11,
		},
		[13] = {
			name	= "ERMBL",
			mainDir = "-1 -0.5 -1",
			maxAngleDif = 90,
		},
		[14] = {
			name	= "ERMBL",
			mainDir = "-1 -0.5 -1",
			maxAngleDif = 90,
			slaveTo = 13,
		},
		[15] = {
			name	= "ERMBL",
			mainDir = "-1 -0.5 1",
			maxAngleDif = 90,
		},
		[16] = {
			name	= "ERMBL",
			mainDir = "-1 0 1",
			maxAngleDif = 90,
			slaveTo = 15,
		},
		-- PPCs
		[17] = {
			name	= "PPC",
			mainDir = "1 -0.5 1",
			maxAngleDif = 90,
		},
		[18] = {
			name	= "PPC",
			mainDir = "1 -0.5 1",
			maxAngleDif = 90,
			slaveTo = 17,
		},
		[19] = {
			name	= "PPC",
			mainDir = "1 -0.5 -1",
			maxAngleDif = 90,
		},
		[20] = {
			name	= "PPC",
			mainDir = "1 -0.5 -1",
			maxAngleDif = 90,
			slaveTo = 19,
		},
		[21] = {
			name	= "PPC",
			mainDir = "-1 -0.5 -1",
			maxAngleDif = 90,
		},
		[22] = {
			name	= "PPC",
			mainDir = "-1 -0.5 -1",
			maxAngleDif = 90,
			slaveTo = 21,
		},
		[23] = {
			name	= "PPC",
			mainDir = "-1 -0.5 1",
			maxAngleDif = 90,
		},
		[24] = {
			name	= "PPC",
			mainDir = "-1 0 1",
			maxAngleDif = 90,
			slaveTo = 23,
		},
		-- LRM-15s
		[25] = {
			name	= "LRM15",
			mainDir = "0 0 1",
			maxAngleDif = 90,
		},
		[26] = {
			name	= "LRM15",
			mainDir = "1 0 0",
			maxAngleDif = 90,
		},
		[27] = {
			name	= "LRM15",
			mainDir = "0 0 -1",
			maxAngleDif = 90,
		},
		[28] = {
			name	= "LRM15",
			mainDir = "-1 0 0",
			maxAngleDif = 90,
		},
		[29] = {
			name = "LAMS",
			mainDir = "0 1 0", -- straight up
			maxAngleDif = 175,
		}
	},
	
	--Gets CEG effects from /gamedata/explosions folder
	sfxtypes = {
		explosiongenerators = {
		"custom:dropship_main_engine_stage2",
		"custom:dropship_main_engine_stage3",
		"custom:heavy_jet_trail",
		"custom:heavy_jet_trail_blue",
		"custom:dropship_reentry",
		"custom:mech_jump_dust"
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