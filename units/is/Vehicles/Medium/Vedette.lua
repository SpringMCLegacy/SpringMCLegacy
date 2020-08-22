local Vedette = LightTank:New{
	name              	= "Vedette",
	trackWidth			= 23,--width to render the decal
	
	customparams = {
		tonnage			= 50,
    },
}

local VedetteUAC = Vedette:New{
	description         = "Medium Striker Tank",
	
	weapons	= {	
		[1] = {
			name	= "UAC5",
		},
		[2] = {
			name	= "MG",
		},
	},
	
	customparams = {
		variant         = "",
		speed			= 80,
		price			= 4080,
		heatlimit 		= 10,
		armor			= 5.5,
		maxammo 		= {ac5 = 4},
		barrelrecoildist = {[1] = 5},
		squadsize 		= 2,
		mods			= {"ferrofibrousarmour"},
    },
}
	
return lowerkeys({
	["DC_Vedette"] = VedetteUAC:New(),
	["FS_Vedette"] = VedetteUAC:New(),
	["LA_Vedette"] = VedetteUAC:New(),
	["CC_Vedette"] = VedetteUAC:New(),
	["FW_Vedette"] = VedetteUAC:New(),
})