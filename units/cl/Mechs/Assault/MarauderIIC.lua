local MarauderIIC = Medium:New{
	name				= "Marauder IIC",

	customparams = {
		tonnage			= 85,
    },	
}

local Mk1 = MarauderIIC:New{
	description         = "Assault Sniper",
	weapons	= {	
		[1] = {
			name	= "CERPPC",
		},
		[2] = {
			name	= "CERPPC",
		},
		[3] = {
			name	= "CERPPC",
		},
		[4] = {
			name	= "CMPL",
		},
		[5] = {
			name	= "CMPL",
		},
		[6] = {
			name	= "CERSBL",
		},
		[7] = {
			name	= "CERSBL",
		},
		[8] = {
			name	= "CERSBL",
		},
		[9] = {
			name	= "CERSBL",
		},
	},
		
	customparams = {
		variant			= "Mk 1",
		speed			= 60,
		price			= 26800,
		heatlimit 		= 42,
		armor			= {type = "ferro", tons = 11.5},
		barrelrecoildist = {[1] = 4},
    },
}

return lowerkeys({
	["WF_MarauderIIC_Mk1"] = Mk1:New(),
	["HH_MarauderIIC_Mk1"] = Mk1:New(),
	["GB_MarauderIIC_Mk1"] = Mk1:New(),
	["JF_MarauderIIC_Mk1"] = Mk1:New(),
	["SJ_MarauderIIC_Mk1"] = Mk1:New(),
})