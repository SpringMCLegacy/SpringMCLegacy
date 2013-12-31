local Turret_BAP = Tower:New{
	name              	= "Sensor Emplacement",
	description         = "Beagle Active Probe (BAP)",
	objectName        	= "Turret_LAMS.s3o",
	--buildCostMetal      = 0,

	customparams = {
		towertype 		= "sensor",
		hasbap			= true,
    },
}

return lowerkeys({
	["Turret_BAP"] = Turret_BAP,
})