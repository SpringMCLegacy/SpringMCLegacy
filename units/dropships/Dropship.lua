local Union = DropShip:New{
	objectName        	= "Dropship_Union.s3o",
	name              	= "Union Class Dropship",

	weapons 		= {	
		-- LBLs
		[1] = {
			name	= "LBL",
			mainDir = "0 0 1",
			maxAngleDif = 90,
		},
		[2] = {
			name	= "LBL",
			mainDir = "0 0 1",
			maxAngleDif = 90,
			slaveTo = 1,
		},
		[3] = {
			name	= "LBL",
			mainDir = "-1 0 0",
			maxAngleDif = 90,
		},
		[4] = {
			name	= "LBL",
			mainDir = "-1 0 0",
			maxAngleDif = 90,
			slaveTo = 3,
		},
		[5] = {
			name	= "LBL",
			mainDir = "0 0 -1",
			maxAngleDif = 90,
		},
		[6] = {
			name	= "LBL",
			mainDir = "0 0 -1",
			maxAngleDif = 90,
			slaveTo = 5,
		},
		[7] = {
			name	= "LBL",
			mainDir = "1 0 0",
			maxAngleDif = 90,
		},
		[8] = {
			name	= "LBL",
			mainDir = "1 0 0",
			maxAngleDif = 90,
			slaveTo = 7,
		},
		-- ERMBLs
		[9] = {
			name	= "ERMBL",
			mainDir = "1 -0.5 1",
			maxAngleDif = 90,
		},
		[10] = {
			name	= "ERMBL",
			mainDir = "1 -0.5 1",
			maxAngleDif = 90,
			slaveTo = 9,
		},
		[11] = {
			name	= "ERMBL",
			mainDir = "1 -0.5 -1",
			maxAngleDif = 90,
		},
		[12] = {
			name	= "ERMBL",
			mainDir = "1 -0.5 -1",
			maxAngleDif = 90,
			slaveTo = 11,
		},
		[13] = {
			name	= "ERMBL",
			mainDir = "-1 -0.5 -1",
			maxAngleDif = 90,
		},
		[14] = {
			name	= "ERMBL",
			mainDir = "-1 -0.5 -1",
			maxAngleDif = 90,
			slaveTo = 13,
		},
		[15] = {
			name	= "ERMBL",
			mainDir = "-1 -0.5 1",
			maxAngleDif = 90,
		},
		[16] = {
			name	= "ERMBL",
			mainDir = "-1 0 1",
			maxAngleDif = 90,
			slaveTo = 15,
		},
		-- PPCs
		[17] = {
			name	= "PPC",
			mainDir = "1 -0.5 1",
			maxAngleDif = 90,
		},
		[18] = {
			name	= "PPC",
			mainDir = "1 -0.5 1",
			maxAngleDif = 90,
			slaveTo = 17,
		},
		[19] = {
			name	= "PPC",
			mainDir = "1 -0.5 -1",
			maxAngleDif = 90,
		},
		[20] = {
			name	= "PPC",
			mainDir = "1 -0.5 -1",
			maxAngleDif = 90,
			slaveTo = 19,
		},
		[21] = {
			name	= "PPC",
			mainDir = "-1 -0.5 -1",
			maxAngleDif = 90,
		},
		[22] = {
			name	= "PPC",
			mainDir = "-1 -0.5 -1",
			maxAngleDif = 90,
			slaveTo = 21,
		},
		[23] = {
			name	= "PPC",
			mainDir = "-1 -0.5 1",
			maxAngleDif = 90,
		},
		[24] = {
			name	= "PPC",
			mainDir = "-1 0 1",
			maxAngleDif = 90,
			slaveTo = 23,
		},
		-- LRM-15s
		[25] = {
			name	= "LRM15",
			mainDir = "0 0 1",
			maxAngleDif = 90,
		},
		[26] = {
			name	= "LRM15",
			mainDir = "1 0 0",
			maxAngleDif = 90,
		},
		[27] = {
			name	= "LRM15",
			mainDir = "0 0 -1",
			maxAngleDif = 90,
		},
		[28] = {
			name	= "LRM15",
			mainDir = "-1 0 0",
			maxAngleDif = 90,
		},
		[29] = {
			name = "LAMS",
			mainDir = "0 1 0", -- straight up
			maxAngleDif = 175,
		}
	},
	
	customparams = {
		maxtonnage		= 250,
		cooldown		= 30 * 30, -- 30s, time before the dropship has regained orbit, refuelled etc ready to drop again
		-- droptime
	},
	sfxtypes = {
		explosiongenerators = {
			"custom:heavy_jet_trail_blue",
			"custom:medium_jet_trail_blue",
			"custom:dropship_main_engine_stage2",
			"custom:heavy_jet_trail",
		},
	},
}

local Leopard = Union:New{ -- TODO: DropShip:New, custom weapons etc
	--objectName        	= "Dropship_Leopard.s3o",
	customparams = {
		maxtonnage		= 150,
		cooldown		= 20 * 30,
		-- droptime
	},	
}

local Overlord = Union:New{ -- TODO: DropShip:New, custom weapons etc
	--objectName        	= "Dropship_Overlord.s3o",
	customparams = {
		maxtonnage		= 400,
		cooldown		= 50 * 30,
		-- droptime
	},	
}

dropShips = {}
for i, sideName in pairs(Sides) do
	dropShips[sideName .. "_dropship_leopard"] = Leopard:New{}
	dropShips[sideName .. "_dropship_union"] = Union:New{}
	dropShips[sideName .. "_dropship_overlord"] = Overlord:New{}
	--Spring.Echo("Making Dropship for", sideName)
end
return lowerkeys(dropShips)