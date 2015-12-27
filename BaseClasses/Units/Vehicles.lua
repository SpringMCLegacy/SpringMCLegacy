-- Vehicles ----
local Vehicle = Unit:New{
	canMove 			= true,
	footprintX			= 3,-- current both TANK and HOVER movedefs are 2x2 even if unitdefs are not
	footprintZ 			= 3,
	iconType			= "vehicle",
	moveState			= 0, -- Hold Position
	onoffable           = true,
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
}

return {
	Vehicle = Vehicle,
	Tank = Tank,
	LightTank = LightTank,
	Hover = Hover,
}
