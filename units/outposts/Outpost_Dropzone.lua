local footPrint = 14
local yardMapString = ""
local yardMapRow = ""
for i = 1, footPrint do
	yardMapRow = yardMapRow .. "y"
end
for i = 1, footPrint do
	yardMapString = yardMapString .. yardMapRow
end

local Outpost_Dropzone = Outpost:New{
	name              	= "Dropzone",
	description         = "Allows the purchase and delivery of battlemechs",
	objectName        	= "outpost/outpost_Dropzone.s3o",
	iconType			= "beacon",
	script				= "outpost_Dropzone.lua",
	category 			= "beacon",
	collisionVolumeType 	= "", -- override base class, as we want s3o radius...
	collisionVolumeScales 	= "", -- ...for selection
	maxDamage           = 50000, -- should never take damage
	footprintX			= footPrint,
	footprintZ 			= footPrint,
	yardMap				= yardMapString,
	levelGround			= false,
	canMove = false,
	canAttack = false,
	canFight = false,
	canPatrol = false,
	canGuard = false,
	canRepeat = false,
	canSelfDestruct = false,
	fireState = -1,

	-- Constructor stuff
	builder				= true,
	workerTime			= 10, -- required in order to have a build menu
	-- Set in weapondefs_post.lua
	--[[sfxtypes = {
		explosiongenerators = {"custom:beacon"},
	},]]
	
	customparams = {
		ignoreatbeacon	= true,
		baseclass		= "beacons", -- don't want to end up in beacon point build menu
		invincible		= true,
    },
}

dropZones = {}
for i, sideName in pairs(Sides) do
	dropZones[sideName .. "_dropzone"] = Outpost_Dropzone:New{}
	--Spring.Echo("Making Dropzone for", sideName)
end
return lowerkeys(dropZones)