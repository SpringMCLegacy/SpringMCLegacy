-- Aircraft ----
local Aircraft = Unit:New{
	canFly						= true,
	canMove 					= true,
	explodeAs          			= "mechexplode",
	factoryHeadingTakeoff 		= false,
	footprintX					= 2,
	footprintZ 					= 2,
	iconType					= "aero",
	moveState					= 1, -- Maneuver
	script						= "Vehicle.lua",
	usepiececollisionvolumes 	= true,
	collide						= false,
	
	customparams = {
		ignoreatbeacon  = true,
    },
}
	
local Aero = Aircraft:New{
	category 			= "aero air notbeacon",
	noChaseCategory		= "beacon ground",
	cruiseAlt			= 300,
	canLoopbackAttack 	= true,
	airSightDistance	= 1500,
	
	customparams = {
		baseclass			= "aero",
		entryDelay 			= 15,
		prepDelay 			= 15,
	},
}

local VTOL = Aircraft:New{
	category 			= "vtol air notbeacon",
	noChaseCategory		= "beacon air vtol",
	cruiseAlt			= 250,
	hoverAttack			= true,
	airHoverFactor		= -0.0001,
	
	customparams = {
		hasturnbutton		= "1",
		baseclass			= "vtol",
    },
}

return {
	Aircraft = Aircraft,
	Aero = Aero,
	VTOL = VTOL,
}
