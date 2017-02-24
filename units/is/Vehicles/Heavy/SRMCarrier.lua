local SRMCarrier = LightTank:New{
	name              	= "SRM Carrier",
	description         = "Heavy Missile Support",
	trackWidth			= 23,--width to render the decal
	weapons	= {	
		[1] = {
			name	= "SRM6",
			maxAngleDif = 60,
		},
		[2] = {
			name	= "SRM6",
			maxAngleDif = 60,
			SlaveTo = 1,
		},
		[3] = {
			name	= "SRM6",
			maxAngleDif = 60,
			SlaveTo = 1,
		},
		[4] = {
			name	= "SRM6",
			maxAngleDif = 60,
		},
		[5] = {
			name	= "SRM6",
			maxAngleDif = 60,
			SlaveTo = 1,
		},
		[6] = {
			name	= "SRM6",
			maxAngleDif = 60,
			SlaveTo = 1,
		},
		[7] = {
			name	= "SRM6",
			maxAngleDif = 60,
		},
		[8] = {
			name	= "SRM6",
			maxAngleDif = 60,
			SlaveTo = 1,
		},
		[9] = {
			name	= "SRM6",
			maxAngleDif = 60,
			SlaveTo = 1,
		},
		[10] = {
			name	= "SRM6",
			maxAngleDif = 60,
			SlaveTo = 1,
		},
	},
	
	customparams = {
		tonnage			= 60,
		variant         = "",
		speed			= 50,
		price			= 8160,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 2},
		maxammo 		= {srm = 4},
		squadsize 		= 1,
    },
}

return lowerkeys({
	--["CC_SRMCarrier"] = SRMCarrier:New(),
	--["DC_SRMCarrier"] = SRMCarrier:New(),
	--["FS_SRMCarrier"] = SRMCarrier:New(),
	--["FW_SRMCarrier"] = SRMCarrier:New(),
	--["LA_SRMCarrier"] = SRMCarrier:New(),
})