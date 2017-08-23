local Outpost_Garrison = Outpost:New{
	name              	= "Garrison",
	description         = "Fortified Defensive Outpost",
	maxDamage           = 20000,
	mass                = 10000,
	collisionVolumeScales = [[50 50 50]],
	buildCostMetal      = 10000,

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
	sounds = {
	select = "Garrison",
	}
}

for i = 1, 6 do
	Outpost_Garrison.weapons[i] = {}
	Outpost_Garrison.weapons[i]["name"] = "MPL"
	Outpost_Garrison.weapons[i]["maxAngleDif"] = 60
	local x = math.sin(math.rad((i-1) * 60))
	local z = math.cos(math.rad((i-1) * 60))
	Outpost_Garrison.weapons[i]["mainDir"] = "" .. x .. " 0 " .. z
	--Spring.Echo("YOYO", i, Outpost_Garrison.weapons[i]["mainDir"])
end		

return lowerkeys({ ["outpost_Garrison"] = Outpost_Garrison })