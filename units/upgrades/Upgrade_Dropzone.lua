local Upgrade_Dropzone = {
	name              	= "Dropzone",
	description         = "Landing Demarcation",
	objectName        	= "Upgrade_Dropzone.s3o",
	iconType			= "Ddropzone",
	script				= "Upgrade_Dropzone.lua",
	category 			= "beacon",
	maxDamage           = 50000, -- should never take damage
	footprintX			= 5,
	footprintZ 			= 5,
	yardMap				= "yyyyy yyyyy yyyyy yyyyy yyyyy",
	-- Colvol
	--[[collisionVolumeType = "box",
	collisionVolumeScales = "4 25 4",]]
	-- Constructor stuff
	builder				= true,
	builddistance 		= 460,
	workerTime			= 10, -- ?	
	terraformSpeed		= 10000,
	showNanoSpray		= false,
	-- Set in weapondefs_post.lua
	--[[sfxtypes = {
		explosiongenerators = {"custom:beacon"},
	},]]
	
	customparams = {
		helptext		= "A Beacon indicating a strategically important location.",
    },
}

local function copytable(input, output)
	for k,v in pairs(input) do
		if type(v) == "table" then
			output[k] = {}
			copytable(v, output[k])
		else
			output[k] = v
		end
	end
end

local IS_Dropzone = {}
copytable(Upgrade_Dropzone, IS_Dropzone)
local CL_Dropzone = {}
copytable(Upgrade_Dropzone, CL_Dropzone)

return lowerkeys({
	--["Upgrade_Dropzone"] = Upgrade_Dropzone, 
	["CL_Dropzone"] = CL_Dropzone,
	["IS_Dropzone"] = IS_Dropzone,
})