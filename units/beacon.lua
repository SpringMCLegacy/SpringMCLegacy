local beacon = Unit:New{
	name              	= "Beacon",
	description         = "Strategic Marker",
	objectName        	= "beacon.s3o",
	iconType			= "beacon",
	script				= "beacon.lua",
	category 			= "beacon",
	maxDamage           = 50000,
	mass                = 1000,
	footprintX			= 2,
	footprintZ 			= 2,
	collisionVolumeType = "box",
	collisionVolumeScales = [[4 25 4]],
	buildCostMetal      = 0, -- default is 1
	--canMove				= false,
	movementClass   = "LARGEMECH",
	canselfdestruct		= false,
		
	-- Constructor stuff
	--[[builder				= true,
	builddistance 		= 460,
	workerTime			= 10, -- ?	
	terraformSpeed		= 10000,
	showNanoSpray		= false,]]
	--[[sfxtypes = {
		explosiongenerators = {"custom:reentry_fx", "custom:JumpJetTrail"},
	},]]
	
	customparams = {
		helptext		= "A Beacon indicating a strategically important location.",
		minbuildrange	= 230,
		ignoreatbeacon	= true,
    },
}

local beacon_point = beacon:New{
	name              	= "Upgrade Point",
	description         = "Beacon Upgrade Marker",
	objectName        	= "beacon_point.s3o",
	script				= "wall.lua",
	
	sightdistance 		= 0,
	airsightdistance 	= 0,
	radardistance 		= 0,
	iconType			= "beaconpoint",
}

return lowerkeys({ 
	["beacon"] = beacon,
	["beacon_point"] = beacon_point,
})