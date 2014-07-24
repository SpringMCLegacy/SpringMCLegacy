local footPrint = 14
local yardMapString = ""
local yardMapRow = ""
for i = 1, footPrint do
	yardMapRow = yardMapRow .. "y"
end
for i = 1, footPrint do
	yardMapString = yardMapString .. yardMapRow
end

local Upgrade_Dropzone = Upgrade:New{
	name              	= "Dropzone",
	description         = "Landing Demarcation",
	objectName        	= "Upgrade_Dropzone.s3o",
	iconType			= "Ddropzone",
	script				= "Upgrade_Dropzone.lua",
	category 			= "beacon",
	collisionVolumeType 	= "", -- override base class, as we want s3o radius...
	collisionVolumeScales 	= "", -- ...for selection
	maxDamage           = 50000, -- should never take damage
	footprintX			= footPrint,
	footprintZ 			= footPrint,
	yardMap				= yardMapString,

	-- Constructor stuff
	builder				= true,
	workerTime			= 10, -- required in order to have a build menu
	-- Set in weapondefs_post.lua
	--[[sfxtypes = {
		explosiongenerators = {"custom:beacon"},
	},]]
	
	customparams = {
		helptext		= "Primary Drop Zone",
    },
}

return lowerkeys({
	["CL_Dropzone"] = Upgrade_Dropzone:New{},
	["IS_Dropzone"] = Upgrade_Dropzone:New{},
})