local jumpers			= {} -- list of units with class stats
local jumpClassGroups	= {} -- lists of units stored within a list based on grouping
local jumpCategory		= {} -- base category for jumpjet types 
local overCategory		= {} -- override category for jumpjet types 

jumpCategory = { 
	baseclass = {
		range = 600, height = 200, speed = 6,  reload = 10,  aaShootMe = false, delay = 30, cobscript = false, rotateMidAir = true,
	},	
}

jumpClassGroups = {
	baseclass = { 
		"is_chimera_cma1s",
		"is_catapult_cpltc1",
		"is_catapult_cpltc4",
		"is_osiris_osr3d",
		"is_osiris_osr4d",
		"cl_mistlynx_prime",
		"cl_nova_prime",
		"cl_summoner_c",
		"cl_shadowcat_prime",
	},
}

------------------------------------------------------------------------------------------------------------------------------------------------
-- Unit overrides
-- 
--		range	
--		height
--		speed
--		reload
------------------------------------------------------------------------------------------------------------------------------------------------	
--[[overCategory = {
	is_chimera = { cobscript = false},
	is_catapult = { cobscript = false},
	is_osiris = { cobscript = false},
	cl_mistlynx = { cobscript = false},
	cl_nova = { cobscript = false},
	cl_summoner = { cobscript = false},
	cl_shadowcat = { cobscript = false},
 --[[	
 corsumo = {
    delay = 30, height = 100, range = 300, reload = 13, cobscript = false, rotateMidAir = false},
 },
}--]]