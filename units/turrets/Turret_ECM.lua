local Turret_ECM = Tower:New{
	name              	= "ECM Emplacement",
	description         = "Electronic Counter-Measure (ECM)",
	objectName        	= "Turret_LAMS.s3o",
	--buildCostMetal      = 0,

	customparams = {
		towertype 		= "ecm",
		hasecm			= true,
    },
}

return lowerkeys({
	["Turret_ECM"] = Turret_ECM,
})