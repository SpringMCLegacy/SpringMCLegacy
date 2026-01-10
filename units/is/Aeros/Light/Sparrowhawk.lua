local Sparrowhawk = Aero:New{
	name              	= "Sparrowhawk SPR-7D",
	description         = "Light Interceptor",
	
	buildPic			= "fs_sparrowhawk.png", -- TODO: remove in future
	
	acceleration       = 0.42,
	maxAcc             = 1.2,
	turnRadius         = 90,
	wingDrag           = 0.05,
	wingAngle          = 0.08,
	crashDrag          = 0.005,
	maxBank            = 0.72,
	maxPitch           = 0.6,
	verticalSpeed      = 4.0,
	maxAileron         = 0.026,--13,
	maxElevator        = 0.026,--13,
	maxRudder          = 0.0044,--22,
	
	weapons = {	
		[1] = {
			name	= "MPL",
			maxAngleDif = 35,
		},
		[2] = {
			name	= "MPL",
			maxAngleDif = 35,
		},
		[3] = {
			name	= "ERMBL",
			maxAngleDif = 35,
		},
		[4] = {
			name	= "ERMBL",
			maxAngleDif = 35,
		},
	},
	
	customparams = {
		tonnage			= 30,
		variant         = "SPR-7D",
		speed			= 360 * 1.75, --3600
		price			= 4500,
		heatlimit 		= 20,
		armor			= 2,
		
		entryDelay 		= 5,
		prepDelay 		= 10,
    },
}

aeros = {}
for i, sideName in pairs(Sides) do
	aeros[sideName .. "_sparrowhawk"] = Sparrowhawk:New{}
end
-- Sparrowhawk is IS only!
aeros["wf_sparrowhawk"] = nil
aeros["sj_sparrowhawk"] = nil
return lowerkeys(aeros)