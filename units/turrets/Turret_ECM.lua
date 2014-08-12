local Turret_ECM = Tower:New{
	name              	= "ECM Emplacement",
	description         = "Electronic Counter-Measure",
	objectName        	= "Turret_ECM.s3o",
	--buildCostMetal      = 0,

	customparams = {
		towertype 		= "sensor",
		hasecm			= true,
    },
}

return lowerkeys({
	["Turret_ECM"] = Turret_ECM,
})