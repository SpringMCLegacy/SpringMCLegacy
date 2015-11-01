-- Mechs ----
local Mech = Unit:New{
	activateWhenBuilt   = true,
	canMove				= true,
	corpse				= "<NAME>_x",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
	onoffable           = true,
	script				= "Mech.lua",
	upright				= true,
	usepiececollisionvolumes = true,
	
	customparams = {
		hasturnbutton	= true,
		unittype		= "mech",
		baseclass		= "Mech",
    },
}

local Light = Mech:New{
	iconType			= "light",
	footprintX			= 1,
	footprintZ 			= 1,
	movementClass		= "SMALLMECH",
}

local Medium = Mech:New{
	iconType			= "medium",
	footprintX			= 2,
	footprintZ 			= 2,
	movementClass		= "SMALLMECH",
}

local Heavy = Mech:New{
	iconType			= "heavy",
	footprintX			= 3,
	footprintZ 			= 3,
	movementClass		= "LARGEMECH",
}

local Assault = Mech:New{
	iconType			= "assault",
	footprintX			= 3,
	footprintZ 			= 3,
	movementClass		= "LARGEMECH",
}

return {
	Mech = Mech,
	Light = Light,
	Medium = Medium,
	Heavy = Heavy,
	Assault = Assault,
}
