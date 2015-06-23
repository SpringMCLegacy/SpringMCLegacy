local Turret_BAP = Tower:New{
	name              	= "Sensor Emplacement",
	description         = "Beagle Active Probe",
	objectName        	= "Turret_BAP.s3o",
	--buildCostMetal      = 0,

	customparams = {
		towertype 		= "sensor",
		bap			= true,
    },
}

return lowerkeys({
	["Turret_BAP"] = Turret_BAP,
})