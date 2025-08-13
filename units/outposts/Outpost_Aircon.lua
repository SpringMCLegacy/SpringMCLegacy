local yard = ""
for i = 1, 16 do
	yard = yard .. "y"
end

local Outpost_Aircon = Outpost:New{
	name              	= "Aerofighter Control Tower",
	description         = "A command hub for aerofighter assets deploying from orbit",
	iconType			= "outpost_aircon",
	maxDamage           = 7000,
	mass                = 5000,
	buildCostMetal      = 8500,
	
	-- Constructor stuff
	builder				= true,
	workerTime			= 10, -- ?	
	showNanoSpray		= false,
	yardmap				= yard,
	
	customparams = {
		helptext		= "Ping Pong Potato",
    },
	sounds = {
		select = "AirControl",
	}
}

return lowerkeys({ ["outpost_Aircon"] = Outpost_Aircon })