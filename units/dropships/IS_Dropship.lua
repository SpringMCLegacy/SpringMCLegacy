local IS_Dropship = {
	name              	= "Dropship",
	description         = "Unit Aquisition Facility",
	objectName        	= "Dropship_2.s3o",
	iconType			= "dropship",
	script				= "Dropship.lua",
	category 			= "dropship structure notbeacon",
		activateWhenBuilt   = true,
	maxDamage           = 180000,
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
	metalMake			= 400,
	metalStorage		= 50000,
	idleAutoHeal		= 0,
	maxSlope			= 50,
	builder				= true,
	moveState			= 0,
		showNanoFrame		= 0,
		showNanoSpray		= 0,
		workerTime			= 1,
		canBeAssisted	= false,
		yardmap			= [[yyyyyyyyyyyyyyyyyyyy
		                    yyyyyyyyyyyyyyyyyyyy 
							yyyyyyyyyyyyyyyyyyyy 
							yyyyyyyyyyyyyyyyyyyy 
							yyyyoyyyyyyyyyyoyyyy 
							yyyyyyyyyyyyyyyyyyyy 
							yyyyyyyyyyyyyyyyyyyy 
							yyyyyyyyyyyyyyyyyyyy 
							yyyyyyyyyyyyyyyyyyyy 
							yyyyyyyyyyyyyyyyyyyy 
							yyyyyyyyyyyyyyyyyyyy 
							yyyyyyyyyyyyyyyyyyyy 
							yyyyyyyyyyyyyyyyyyyy 
							yyyyyyyyyyyyyyyyyyyy 
							yyyyyyyyyyyyyyyyyyyy 
							yyyyoyyyyyyyyyyoyyyy 
							yyyyyyyyyyyyyyyyyyyy 
							yyyyyyyyyyyyyyyyyyyy 
							yyyyyyyyyyyyyyyyyyyy 
							yyyyyyyyyyyyyyyyyyyy]],
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "AC10",
				mainDir = "0 1 1",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "AC10",
				mainDir = "0 1 1",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[3] = {
				name	= "AC10",
				mainDir = "1 1 0",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[4] = {
				name	= "AC10",
				mainDir = "1 1 0",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[5] = {
				name	= "AC10",
				mainDir = "0 1 -1",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[6] = {
				name	= "AC10",
				mainDir = "0 1 -1",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[7] = {
				name	= "AC10",
				mainDir = "-1 1 0",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[8] = {
				name	= "AC10",
				mainDir = "-1 1 0",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[9] = {
				name	= "PPC",
				mainDir = "0 1 1",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[10] = {
				name	= "PPC",
				mainDir = "1 1 0",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[11] = {
				name	= "PPC",
				mainDir = "0 1 -1",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[12] = {
				name	= "PPC",
				mainDir = "-1 1 0",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[13] = {
				name	= "LRM15",
				mainDir = "1 1 1",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[14] = {
				name	= "LRM15",
				mainDir = "1 1 -1",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[15] = {
				name	= "LRM15",
				mainDir = "-1 1 -1",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[16] = {
				name	= "LRM15",
				mainDir = "-1 1 1",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[17] = {
				name	= "ERMBL",
				mainDir = "0 1 1",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[18] = {
				name	= "ERMBL",
				mainDir = "0 1 1",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[19] = {
				name	= "ERMBL",
				mainDir = "1 1 0",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[20] = {
				name	= "ERMBL",
				mainDir = "1 1 0",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[21] = {
				name	= "ERMBL",
				mainDir = "0 1 -1",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[22] = {
				name	= "ERMBL",
				mainDir = "0 1 -1",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[23] = {
				name	= "ERMBL",
				mainDir = "-1 1 0",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[24] = {
				name	= "ERMBL",
				mainDir = "-1 1 0",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[25] = {
				name	= "LBL",
				mainDir = "1 1 1",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[26] = {
				name	= "LBL",
				mainDir = "1 1 -1",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[27] = {
				name	= "LBL",
				mainDir = "-1 1 -1",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[28] = {
				name	= "LBL",
				mainDir = "-1 1 1",
				maxAngleDif = 180,
				OnlyTargetCategory = "notbeacon",
			},
			[29] = {
				name	= "AMS_Dropship",
			},
		},
	--Gets CEG effects from /gamedata/explosions folder
	sfxtypes = {
		explosiongenerators = {
		"custom:MISSILE_MUZZLEFLASH",
		"custom:PPC_MUZZLEFLASH",
		"custom:LASER_MUZZLEFLASH",
		"custom:dropship_main_engine_stage2",
		"custom:dropship_main_engine_stage3",
		"custom:dropship_heavy_dust",
		"custom:heavy_jet_trail",
		"custom:heavy_jet_trail_blue",
		"custom:dropship_reentry",
		},
	},
	customparams = {
		ammosupplier	= "0",
		supplyradius	= "500",
		helptext		= "A Dropship",
		hasbap			= true,
    },
	sounds = {
    underattack        = "Dropship_Alarm",
	},
}

local function copytable(input, output)
	for k,v in pairs(input) do
		if type(v) == "table" then
			output[k] = {}
			copytable(v, output[k])
		else
			output[k] = v
		end
	end
end

local IS_Dropship_FX = {}
copytable(IS_Dropship, IS_Dropship_FX)
IS_Dropship_FX["weapons"] = {} -- remove all weapons
IS_Dropship_FX["yardmap"] = "" -- remove yardmap
IS_Dropship_FX["moveclass"] = "LARGEMECH" -- make it a mobile unit
IS_Dropship_FX["script"] = "dropship_fx.lua" -- change script
IS_Dropship_FX["objectName"] = "dropship.s3o" -- change model

return lowerkeys({ ["IS_Dropship"] = IS_Dropship, ["IS_Dropship_FX"] = IS_Dropship_FX })