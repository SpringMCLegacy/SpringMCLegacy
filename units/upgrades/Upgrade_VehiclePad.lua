local Upgrade_VehiclePad = Upgrade:New{
	name              	= "Vehicle Pad",
	description         = "Vehicle Delivery Upgrade",
	maxDamage           = 10000,
	mass                = 5000,
	buildCostMetal      = 10000,
	objectname			= "upgrade/upgrade_vehiclepad.s3o",

	collisionVolumeOffsets = [[0 2 0]],
	collisionVolumeScales = [[125 12 125]],
	collisionVolumeType = "cylY",

	customparams = {
		helptext		= "Grants access to friendly vehicle support.",
    },
}

vPads = {}
for i, sideName in pairs(Sides) do
	vPads[sideName .. "_vehiclepad"] = Upgrade_VehiclePad:New{}
	--Spring.Echo("Making Dropzone for", sideName)
end
return lowerkeys(vPads)