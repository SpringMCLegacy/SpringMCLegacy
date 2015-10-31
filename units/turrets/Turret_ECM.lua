local Turret_ECM = Tower:New{
	name              	= "ECM Emplacement",
	description         = "Electronic Counter-Measure",

	customparams = {
		towertype 		= "sensor",
		ecm			= true,
    },
}

return lowerkeys({
	["Turret_ECM"] = Turret_ECM,
})