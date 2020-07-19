local Outpost_SalvageYard = Outpost:New{
	name              	= "Salvage Yard (Upgrade)",
	description         = "Salvage & Recovery outpost",
	maxDamage           = 10000,
	mass                = 9000,
	buildCostMetal      = 8000,
		
	transportSize		= 3,
	transportCapacity	= 3, -- 1x transportSize
	transportMass		= 10000,
	loadingradius		= 100,
	
	sounds = {
		select = "salvageyard",
	}
}

--return lowerkeys({ ["outpost_SalvageYard"] = Outpost_SalvageYard })