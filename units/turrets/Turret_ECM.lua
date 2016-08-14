local Turret_ECM = Tower:New{
	name              	= "ECM Emplacement",
	description         = "Electronic Counter-Measure",
	buildCostMetal      = 5000,

	customparams = {
		ecm			= true,
    },
}

return lowerkeys({
	["Turret_ECM"] = Turret_ECM,
})