local Turret_BAP = Tower:New{
	name              	= "Sensor Emplacement",
	description         = "Beagle Active Probe",
	buildCostMetal      = 4500,

	customparams = {
		bap			= true,
    },
	sounds = {
		select = "Turret",
	}
}

return lowerkeys({
	--["Turret_BAP"] = Turret_BAP,
})