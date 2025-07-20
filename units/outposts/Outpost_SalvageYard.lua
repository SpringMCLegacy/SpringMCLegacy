local Outpost_SalvageYard = Outpost:New{
	name              	= "Salvage Yard",
	description         = "Salvage & Recovery outpost",
	maxDamage           = 10000,
	mass                = 9000,
	buildCostMetal      = 7200,
		
	transportSize		= 3,
	transportCapacity	= 3, -- 1x transportSize
	transportMass		= 10000,
	loadingradius		= 100,
	
	harvestStorage		= 20000,
	
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