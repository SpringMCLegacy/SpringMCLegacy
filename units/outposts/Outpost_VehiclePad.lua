local Outpost_VehiclePad = Outpost:New{
	name              	= "Vehicle Pad (Support)",
	description         = "Allows delivery of offensive vehicle support units",
	iconType			= "outpost_vehiclepad",
	maxDamage           = 5500,
	mass                = 5000,
	buildCostMetal      = 10000,

	collisionVolumeOffsets = [[0 12 0]],
	collisionVolumeScales = [[70 36 70]],
	collisionVolumeType = "cylY",

	customparams = {
		helptext		= "Grants access to friendly vehicle support.",
    },
	sounds = {
	select = "VehiclePad",
	}
}

return lowerkeys({ 
	["outpost_VehiclePad"] = Outpost_VehiclePad,
})