local Sparrowhawk = Aero:New{
	name              	= "Sparrowhawk",
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
		speed			= 250 * 1.75, --3600
		price			= 4500,
		heatlimit 		= 20,
		armor			= 8,
		
		entryDelay 		= 5,
		prepDelay 		= 10,
		strafeDistance  = 300, -- how close to get to target while strafing
		strafeOvertime  = 1000, -- how long to keep flying over target after strafing
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