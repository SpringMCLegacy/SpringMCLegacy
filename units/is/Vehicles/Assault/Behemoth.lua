local BehemothBase = Tank:New{
	name              	= "Behemoth",
	description         = "Assault Tank",
	trackWidth			= 32,--width to render the decal

	
	customparams = {
		tonnage			= 100,
		variant         = "",
		speed			= 30,
		price			= 10000,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 13},
		maxammo 		= {ac10 = 2, lrm = 1, srm = 3},
		barrelrecoildist = {[1] = 5, [2] = 5},
		squadsize 		= 1,
		trackwidth		= 56,
	},
}
	
local Behemoth = BehemothBase:New{
	weapons	= {	
		[1] = {
			name	= "AC10",
		},
		[2] = {
			name	= "AC10",
		},
		[3] = {
			name	= "SRM6",
		},
		[4] = {
			name	= "SRM6",
		},
		[5] = {
			name	= "SRM2",
			mainDir = [[-1 0 0]],
			maxAngleDif = 120,
		},
		[6] = {
			name	= "SRM2",
			mainDir = [[1 0 0]],
			maxAngleDif = 120,
		},
		[7] = {
			name	= "LRM20",
			maxAngleDif = 60,
		},
		[8] = {
			name	= "SRM4",
			maxAngleDif = 60,
		},
		[9] = {
			name	= "MG",
			mainDir = [[-1 0 0]],
			maxAngleDif = 120,
			SlaveTo = 5,
		},
		[10] = {
			name	= "MG",
			mainDir = [[1 0 0]],
			maxAngleDif = 120,
			SlaveTo = 6,
		},
		[11] = {
			name	= "MG",
			maxAngleDif = 60,
		},
		[12] = {
			name	= "MG",
			maxAngleDif = 60,
		},
	},
}

local BehemothD = BehemothBase:New{
	weapons	= {	
		[1] = {
			name	= "AC10",
		},
		[2] = {
			name	= "AC10",
		},
		[3] = {
			name	= "SRM6",
		},
		[4] = {
			name	= "SRM6",
		},
		[5] = {
			name	= "LRM10",
			maxAngleDif = 60,
		},
	},
	
	customparams = {
		tonnage			= 100,
		variant         = "(Davion)",
		speed			= 30,
		price			= 12000,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 24},
		maxammo 		= {ac10 = 3, lrm = 1, srm = 3},
		barrelrecoildist = {[1] = 5, [2] = 5},
		squadsize 		= 1,
		replaces		= "fs_behemoth",
	},
}

local BehemothK = BehemothBase:New{
	weapons	= {	
		[1] = {
			name	= "UAC10",
		},
		[2] = {
			name	= "UAC10",
		},
		[3] = {
			name	= "SRM6",
		},
		[4] = {
			name	= "SRM6",
		},
		[5] = {
			name	= "LRM10",
			maxAngleDif = 60,
		},
		[6] = {
			name	= "MRM10",
		},
		[7] = {
			name	= "MRM10",
		},
	},
	
	customparams = {
		tonnage			= 100,
		variant         = "(Kurita)",
		speed			= 30,
		price			= 11700,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 21},
		maxammo 		= {ac10 = 4, lrm = 1, srm = 2, mrm = 2},
		barrelrecoildist = {[1] = 5, [2] = 5},
		squadsize 		= 1,
		replaces		= "dc_behemoth",
	},
}

local BehemothM = BehemothBase:New{
	weapons	= {	
		[1] = {
			name	= "LightGauss",
		},
		[2] = {
			name	= "LightGauss",
		},
		[3] = {
			name	= "SRM6",
		},
		[4] = {
			name	= "SRM6",
		},
		[5] = {
			name	= "SRM2",
			mainDir = [[-1 0 0]],
			maxAngleDif = 120,
		},
		[6] = {
			name	= "SRM2",
			mainDir = [[1 0 0]],
			maxAngleDif = 120,
		},
		[7] = {
			name	= "LRM20",
			maxAngleDif = 60,
		},
		[8] = {
			name	= "SRM4",
			maxAngleDif = 60,
		},
		[9] = {
			name	= "MG",
			mainDir = [[-1 0 0]],
			maxAngleDif = 120,
			SlaveTo = 5,
		},
		[10] = {
			name	= "MG",
			mainDir = [[1 0 0]],
			maxAngleDif = 120,
			SlaveTo = 6,
		},
		[11] = {
			name	= "MG",
			maxAngleDif = 60,
		},
		[12] = {
			name	= "MG",
			maxAngleDif = 60,
		},
	},
	customparams = {
		tonnage			= 100,
		variant         = "(Marik)",
		speed			= 30,
		price			= 13700,
		heatlimit 		= 20,
		armor			= {type = "standard", tons = 21},
		maxammo 		= {ltgauss = 4, lrm = 1, srm = 2, mrm = 2},
		barrelrecoildist = {[1] = 5, [2] = 5},
		squadsize 		= 1,
		replaces		= "fw_behemoth",
	},
}

return lowerkeys({
	["CC_Behemoth"] = Behemoth:New(),
	["DC_Behemoth"] = Behemoth:New(),
	["DC_BehemothK"] = BehemothK:New(),
	["FS_Behemoth"] = Behemoth:New(),
	["FS_BehemothD"] = BehemothD:New(),
	["FW_Behemoth"] = Behemoth:New(),
	["FW_BehemothM"] = BehemothM:New(),
	["LA_Behemoth"] = Behemoth:New(),
})