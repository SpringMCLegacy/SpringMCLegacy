local Upgrade_SalvageYard = Upgrade:New{
	name              	= "Salvage Yard",
	description         = "Salvage & Recovery Upgrade",
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

return lowerkeys({ ["Upgrade_SalvageYard"] = Upgrade_SalvageYard })