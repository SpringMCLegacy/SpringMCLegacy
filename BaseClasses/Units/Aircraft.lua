-- Aircraft ----
local Aircraft = Unit:New{
	canFly						= true,
	canMove 					= true,
	explodeAs          			= "mechexplode",
	factoryHeadingTakeoff 		= false,
	footprintX					= 2,
	footprintZ 					= 2,
	iconType					= "aero",
	moveState					= 0, -- Hold Position
	script						= "Vehicle.lua",
	usepiececollisionvolumes 	= true,
	
	customparams = {
		unittype		= "vehicle", -- TODO: check where this is used and change to aircraft
		ignoreatbeacon  = true,
    },
}
	
local Aero = Aircraft:New{
	category 			= "aero air notbeacon",
	noChaseCategory		= "beacon ground",
	cruiseAlt			= 300,
	canLoopbackAttack 	= true,
	
	customparams = {
		baseclass			= "Aero",
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
		baseclass			= "VTOL",
    },
}

return {
	Aircraft = Aircraft,
	Aero = Aero,
	VTOL = VTOL,
}
