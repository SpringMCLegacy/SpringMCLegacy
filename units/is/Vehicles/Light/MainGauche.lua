local MainGauche = LightTank:New{
	name              	= "Main Gauche",
	description			= "Light Sniper Tank",
	
	weapons 		= {	
		[1] = {
			name	= "LightGauss",
			maxAngleDif = 15,
		},
		[2] = {
			name	= "MG",
		},
		[3] = {
			name	= "MG",
		},
	},
	
	customparams = {
		tonnage			= 30,
		variant         = "",
		speed			= 60,
		price			= 4130,
		heatlimit 		= 10,
		armor			= {type = "standard", tons = 5},
		maxammo 		= {ltgauss = 1},
		barrelrecoildist = {[1] = 5},
		squadsize 		= 1,
    },
}

return lowerkeys({
	["FW_MainGauche"] = MainGauche:New(),
})