local Outpost_VehiclePad = Outpost:New{
	name              	= "Vehicle Pad",
	description         = "Vehicle Delivery outpost",
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

local Outpost_HoverPad = Outpost_VehiclePad:New{
	name				= "Hover Pad",
	objectName			= "outpost/outpost_vehiclepad.s3o",
}

return lowerkeys({ 
	["outpost_VehiclePad"] = Outpost_VehiclePad,
	["outpost_HoverPad"] = Outpost_HoverPad,
})