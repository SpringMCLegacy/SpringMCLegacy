local Scorpion = LightTank:New{
	name              	= "Scorpion",
	description			= "Light Striker Tank",
	trackWidth			= 22,--width to render the decal
	
	weapons 		= {	
		[1] = {
			name	= "AC5",
		},
		[2] = {
			name	= "MG",
			maxAngleDif = 60,
		},
	},
	
	customparams = {
		tonnage			= 25,
		variant         = "",
		speed			= 80,
		price			= 4130,
		heatlimit 		= 10,
		armor			= 4,
		maxammo 		= {ac5 = 2},
		barrelrecoildist = {[1] = 4},
		squadsize 		= 3,
    },
}

return lowerkeys({
	["CC_Scorpion"] = Scorpion:New(),
	["DC_Scorpion"] = Scorpion:New(),
	["FW_Scorpion"] = Scorpion:New(),
	["FS_Scorpion"] = Scorpion:New(),
	["LA_Scorpion"] = Scorpion:New(),
})