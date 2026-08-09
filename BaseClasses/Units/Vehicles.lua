-- Vehicles ----
local Vehicle = Unit:New{
	canMove 			= true,
	footprintX			= 3,-- current both TANK and HOVER movedefs are 2x2 even if unitdefs are not
	footprintZ 			= 3,
	iconType			= "vehiclelight",
	moveState			= 0, -- Hold Position
	onoffable           = true,
	turnInPlaceAngleLimit = 60,
	script				= "Vehicle.lua",
	usepiececollisionvolumes = true,
	
	customparams = {
		ignoreatbeacon  = true,
		baseclass		= "vehicle",
    },
}

local Tank = Vehicle:New{
	category 			= "tank ground notbeacon",
	corpse				= "<NAME>_x",
	explodeAs          	= "mechexplode",
	leaveTracks			= true,	
	movementClass   	= "TANK",
	noChaseCategory		= "beacon air",
	trackType			= "Thick",
	trackOffset			= 10,
	customparams = {
		hasturnbutton	= "1",
		uniformbin		= "treads",
    },
}

local LightTank = Tank:New{
	footprintX			= 2, 
	footprintZ 			= 2,
	trackType			= "Thin",
}

local Hover = LightTank:New{
	movementClass   = "HOVER",
	leaveTracks		= false,
	customparams = {
		uniformbin			= nil,
	},
}

local Support = Tank:New{
	iconType			= "support",
	customparams = {
		support			= true,
    },
}

return {
	Vehicle = Vehicle,
	Tank = Tank,
	LightTank = LightTank,
	Hover = Hover,
	Support = Support,
}
