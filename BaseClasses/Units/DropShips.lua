-- DropShips ----
local DropShip = Unit:New{
	description         = "BattleMech Dropship",
	iconType			= "dropship",
	script				= "Dropship.lua",
	category 			= "dropship structure notbeacon",
	activateWhenBuilt   = true,
	maxDamage           = 180000, -- TODO: Do we want to make lower tier dropships vulnerable?
	mass                = 36000,
	footprintX			= 20, -- TODO: Probably safe to leave this as standard?
	footprintZ 			= 20,
	idleAutoHeal		= 0,
	transportSize		= 8,
	transportCapacity	= 96, -- 12x transportSize
	transportMass		= 120000,
	holdSteady 			= true,
	power				= 1, -- don't target me!
	maxvelocity 		= 0.1,
	
	customparams = {
		bap					= true,
		dropship			= "mech",
		--baseclass			= "dropship",
    },
	
	sfxtypes = {
		explosiongenerators = {
			"custom:heavy_jet_trail_blue",
			"custom:medium_jet_trail_blue",
			"custom:dropship_main_engine_stage2",
			"custom:heavy_jet_trail",
		},
	},
}

return {
	DropShip = DropShip,
}
