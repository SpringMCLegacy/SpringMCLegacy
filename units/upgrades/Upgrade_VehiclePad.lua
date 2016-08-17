local Upgrade_VehiclePad = Upgrade:New{
	name              	= "Vehicle Pad",
	description         = "Vehicle Delivery Upgrade",
	maxDamage           = 10000,
	mass                = 5000,
	buildCostMetal      = 10000,

	collisionVolumeOffsets = [[0 2 0]],
	collisionVolumeScales = [[125 12 125]],
	collisionVolumeType = "cylY",

	customparams = {
		helptext		= "Grants access to friendly vehicle support.",
    },
	sounds = {
	select = "VehiclePad",
	}
}

return lowerkeys({ ["Upgrade_VehiclePad"] = Upgrade_VehiclePad })