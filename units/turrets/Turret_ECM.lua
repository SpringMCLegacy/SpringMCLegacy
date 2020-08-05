local Turret_ECM = Tower:New{
	name              	= "ECM Emplacement",
	description         = "Electronic Counter-Measure",
	buildCostMetal      = 5000,
	maxDamage           = 1000,

	customparams = {
		ecm			= true,
    },
	sounds = {
		select = "Turret",
	}
}

return lowerkeys({
	--["Turret_ECM"] = Turret_ECM,
})