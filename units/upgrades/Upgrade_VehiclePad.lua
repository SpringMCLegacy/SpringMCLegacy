local Upgrade_VehiclePad = Upgrade:New{
	name              	= "Vehicle Pad",
	description         = "Vehicle Delivery Upgrade",
	objectName        	= "Upgrade_VehiclePad.s3o",
	maxDamage           = 10000,
	mass                = 5000,

	collisionVolumeOffsets = [[0 -12 0]],
	collisionVolumeScales = [[125 12 125]],
	collisionVolumeType = "cylY",

	customparams = {
		helptext		= "Grants access to friendly vehicle support.",
    },
}

return lowerkeys({ ["Upgrade_VehiclePad"] = Upgrade_VehiclePad })