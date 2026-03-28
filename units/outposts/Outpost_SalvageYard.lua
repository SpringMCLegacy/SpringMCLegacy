local Outpost_SalvageYard = Outpost:New{
	name              	= "Salvage Processing Yard",
	iconType			= "outpost_salvageyard",
	description         = "A facility for processing battlefield salvage via automated Salvagers",
	maxDamage           = 10000,
	mass                = 9000,
	buildCostMetal      = 7200,
	
	harvestStorage		= 20000,
	
	--[[builder				= true,
	canResurrect		= true,
	workerTime			= 100,
	buildDistance		= 50,]]
	holdSteady			= true,
	
	sounds = {
		select = "salvageyard",
	},
	customParams = {
		salvagerange = 4000, -- actually salvage range
	},
}

return lowerkeys({ 
	["outpost_SalvageYard"] = Outpost_SalvageYard 
})