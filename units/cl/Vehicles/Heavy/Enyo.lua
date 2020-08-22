local Enyo = LightTank:New{
	name              	= "Enyo",
	description			= "Heavy Brawler",
	trackWidth			= 23,--width to render the decal
	
	weapons	= {	
		[1] = {
			name	= "CLPL",
		},
		[2] = {
			name	= "SSRM6",
		},
		[3] = {
			name	= "SSRM6",
			maxAngleDif = 60,
		},
		[4] = {
			name	= "SSRM6",
			maxAngleDif = 60,
		},
	},
	
	customparams = {
		tonnage			= 55,
		variant         = "",
		speed			= 90,
		price			= 15270,
		heatlimit 		= 20,
		armor			= 7.5,
		maxammo 		= {srm = 3},
		squadsize 		= 1,
		mods			= {"ferrofibrousarmour"},
    },
}

return lowerkeys({
	["WF_Enyo"] = Enyo:New(),
})