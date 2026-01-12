local yard = ""
for i = 1, 16 do
	yard = yard .. "o"
end

local Outpost_VehiclePad = Outpost:New{
	name              	= "Vehicle Landing Pad",
	description         = "A designated LZ for independent planetary militia forces",
	iconType			= "outpost_vehiclepad",
	maxDamage           = 5500,
	mass                = 5000,
	buildCostMetal      = 10000,

	collisionVolumeOffsets = [[0 12 0]],
	collisionVolumeScales = [[70 36 70]],
	collisionVolumeType = "cylY",

	canMove				= true,
	canFight			= true,
	canAttack			= false,
	canPatrol			= true,
	canGuard			= true,
	
	yardmap				= yard,
	workertime			= 10,
	builder				= true,

	customparams = {
    },
	sounds = {
	select = "VehiclePad",
	}
}

return lowerkeys({ 
	["outpost_VehiclePad"] = Outpost_VehiclePad,
})