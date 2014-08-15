local Upgrade_VehiclePad = Upgrade:New{
	name              	= "Vehicle Pad",
	description         = "Vehicle Delivery Upgrade",
	objectName        	= "Upgrade_VehiclePad.s3o",
	maxDamage           = 10000,
	mass                = 5000,

	collisionVolumeScales = [[25 25 25]],

	customparams = {
		helptext		= "Grants access to friendly vehicle support.",
    },
}

return lowerkeys({ ["Upgrade_VehiclePad"] = Upgrade_VehiclePad })