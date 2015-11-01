-- DropShips ----
local DropShip = Unit:New{
	description         = "BattleMech Dropship",
	iconType			= "dropship",
	script				= "Dropship_union.lua", -- TODO: make dropship script generic for all spheroids
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
	
	customparams = {
		bap					= true,
		dropship			= "mech",
		--baseclass			= "dropship",
    },
}

return {
	DropShip = DropShip,
}
