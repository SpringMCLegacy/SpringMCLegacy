local LRMCarrier = LightTank:New{
	name              	= "LRM Carrier",
	description         = "HeavyMissile Support",
	trackWidth			= 23,--width to render the decal
	weapons	= {	
		[1] = {
			name	= "LRM20",
			maxAngleDif = 60,
		},
		[2] = {
			name	= "LRM20",
			maxAngleDif = 60,
		},
		[3] = {
			name	= "LRM20",
			maxAngleDif = 60,
		},
	},
	
	customparams = {
		tonnage			= 60,
		variant         = "",
		speed			= 50,
		price			= 8330,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 2},
		maxammo 		= {lrm = 4},
		squadsize 		= 1,
    },
}

return lowerkeys({
	--["CC_LRMCarrier"] = LRMCarrier:New(),
	--["DC_LRMCarrier"] = LRMCarrier:New(),
	--["FS_LRMCarrier"] = LRMCarrier:New(),
	--["FW_LRMCarrier"] = LRMCarrier:New(),
	--["LA_LRMCarrier"] = LRMCarrier:New(),
})