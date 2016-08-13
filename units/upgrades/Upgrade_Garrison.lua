local Upgrade_Garrison = Upgrade:New{
	name              	= "Garrison",
	description         = "Fortified Defensive Upgrade",
	maxDamage           = 20000,
	mass                = 10000,
	collisionVolumeScales = [[50 50 50]],
	buildCostMetal      = 12000,

	-- Constructor stuff
	builder				= true,
	builddistance 		= 460, -- beacon cap radius
	workerTime			= 10, -- ?	
	terraformSpeed		= 10000,
	showNanoSpray		= false,
	
	weapons = {
	},
	
	customparams = {
		helptext		= "Heavily-fortified structure resilient to all attacks to fortify captured control points.",
		flagdefendrate = 100,
		ignoreatbeacon	= false,
    },
}

for i = 1, 6 do
	Upgrade_Garrison.weapons[i] = {}
	Upgrade_Garrison.weapons[i]["name"] = "MPL"
	Upgrade_Garrison.weapons[i]["maxAngleDif"] = 60
	local x = math.sin(math.rad((i-1) * 60))
	local z = math.cos(math.rad((i-1) * 60))
	Upgrade_Garrison.weapons[i]["mainDir"] = "" .. x .. " 0 " .. z
	Spring.Echo("YOYO", i, Upgrade_Garrison.weapons[i]["mainDir"])
end		

return lowerkeys({ ["Upgrade_Garrison"] = Upgrade_Garrison })