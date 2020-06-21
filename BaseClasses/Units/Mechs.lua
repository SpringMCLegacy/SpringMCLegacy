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
	
	sounds = {
		select = {
			'Voice_SelectA_1',
			'Voice_SelectA_2',
			'Voice_SelectA_3',
		},
		ok = {
			'Voice_OKA_1',
			'Voice_OKA_2',
			'Voice_OKA_3',
		},
		arrived = {
			'Voice_ArrivedA_1',
			'Voice_ArrivedA_2',
		},
		cant = {
			'Voice_CantA_1',
			'Voice_CantA_2',
		},
		underattack = {
			'Voice_UnderAttackA_1',
			'Voice_UnderAttackA_2',
		},
	},	
	
	customparams = {
		hasturnbutton	= true,
		baseclass		= "mech",
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