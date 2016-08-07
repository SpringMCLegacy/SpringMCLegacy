local Union = DropShip:New{
	objectName        	= "Dropship_Union.s3o",
	name              	= "Union Class Dropship",
	iconType			= "union",

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
}

local Leopard = DropShip:New{
	objectName        	= "IS_Leopard.s3o",
	iconType			= "leopard",

	weapons 		= {	
		[1] = {
			name	= "PPC",
			maxAngleDif = 280,
		},
		[2] = {
			name	= "PPC",
			maxAngleDif = 280,
		},
		[3] = {
			name	= "LBL",
			maxAngleDif = 280,
		},
		[4] = {
			name	= "LBL",
			maxAngleDif = 280,
		},
		[5] = {
			name	= "LRM20",
			maxAngleDif = 60,
		},
	},
		
	customparams = {
		radialdist		= 2500,
		maxtonnage		= 150,
		cooldown		= 20 * 30,
		-- droptime
	},	
}

local Overlord = DropShip:New{ -- TODO: DropShip:New, custom weapons etc
	objectName        	= "Dropship_Overlord.s3o",
	iconType			= "overlord",
	
		weapons 		= {	
		[1] = {
			name	= "Sniper",
		},
		[2] = {
			name	= "UAC10",
			mainDir = "1 0 1",
			maxAngleDif = 90,
		},
		[3] = {
			name	= "UAC10",
			mainDir = "1 0 1",
			maxAngleDif = 90,
			slaveTo = 2,
		},
		[4] = {
			name	= "UAC10",
			mainDir = "-1 0 -1",
			maxAngleDif = 90,
		},
		[5] = {
			name	= "UAC10",
			mainDir = "-1 0 -1",
			maxAngleDif = 90,
			slaveTo = 4,
		},
		-- emitter 6
		[6] = {
			name	= "LBL",
			mainDir = "0 0 1",
			maxAngleDif = 90,
		},
		[7] = {
			name	= "LBL",
			mainDir = "0 0 1",
			maxAngleDif = 90,
			slaveTo =7,
		},
		[8] = {
			name	= "LBL",
			mainDir = "0 0 1",
			maxAngleDif = 90,
			slaveTo =7,
		},
		[9] = {
			name	= "LBL",
			mainDir = "0 0 1",
			maxAngleDif = 90,
			slaveTo =7,
		},
		-- emitter 10
		[10] = {
			name	= "LBL",
			mainDir = "-1 0 0",
			maxAngleDif = 90,
		},
		[11] = {
			name	= "LBL",
			mainDir = "-1 0 0",
			maxAngleDif = 90,
			slaveTo =10,
		},
		[12] = {
			name	= "LBL",
			mainDir = "-1 0 0",
			maxAngleDif = 90,
			slaveTo =10,
		},
		[13] = {
			name	= "LBL",
			mainDir = "-1 0 0",
			maxAngleDif = 90,
			slaveTo =10,
		},
		-- emitter 14
		[14] = {
			name	= "LBL",
			mainDir = "0 0 -1",
			maxAngleDif = 90,
		},
		[15] = {
			name	= "LBL",
			mainDir = "0 0 -1",
			maxAngleDif = 90,
			slaveTo =14,
		},
		[16] = {
			name	= "LBL",
			mainDir = "0 0 -1",
			maxAngleDif = 90,
			slaveTo =14,
		},
		[17] = {
			name	= "LBL",
			mainDir = "0 0 -1",
			maxAngleDif = 90,
			slaveTo =14,
		},
		-- emitter 18
		[18] = {
			name	= "LBL",
			mainDir = "1 0 0",
			maxAngleDif = 90,
		},
		[19] = {
			name	= "LBL",
			mainDir = "1 0 0",
			maxAngleDif = 90,
			slaveTo =18,
		},
		[20] = {
			name	= "LBL",
			mainDir = "1 0 0",
			maxAngleDif = 90,
			slaveTo =18,
		},
		[21] = {
			name	= "LBL",
			mainDir = "1 0 0",
			maxAngleDif = 90,
			slaveTo =18,
		},
		[22] = {
			name	= "LRM20",
			mainDir = "0 0 1",
			maxAngleDif = 120,
		},
		[23] = {
			name	= "LRM20",
			mainDir = "1 0 0",
			maxAngleDif = 120,
		},
		[24] = {
			name	= "LRM20",
			mainDir = "0 0 -1",
			maxAngleDif = 120,
		},
		[25] = {
			name	= "LRM20",
			mainDir = "-1 0 0",
			maxAngleDif = 120,
		},
		-- front blister [[x y 1]] WORKING
		[26] = { -- top
			name	= "MPL",
			mainDir = "0 1 1",
			maxAngleDif = 120,
		},
		[27] = { -- left
			name	= "MPL",
			mainDir = "-1 0 1",
			maxAngleDif = 120,
		},
		[28] = { -- bottom
			name	= "MPL",
			mainDir = "0 -1 1",
			maxAngleDif = 120,
		},
		[29] = { -- right
			name	= "MPL",
			mainDir = "1 0 1",
			maxAngleDif = 120,
		},
		-- left blister [[-1 y z]] WORKING
		[30] = { -- top
			name	= "MPL",
			mainDir = "-1 1 0",
			maxAngleDif = 120,
		},
		[31] = { -- rear
			name	= "MPL",
			mainDir = "-1 0 -1",
			maxAngleDif = 120,
		},
		[32] = { -- bottom
			name	= "MPL",
			mainDir = "-1 -1 0",
			maxAngleDif = 120,
		},
		-- Limit is currently 32 weapons so SOL for now :(
		-- Could comment them out here but would still need to rename model pieces, not worth it
		[33] = { -- front
			name	= "MPL",
			mainDir = "-1 0 1",
			maxAngleDif = 120,
		},
		-- rear blister [[x y -1]]
		[34] = { -- top
			name	= "MPL",
			mainDir = "0 1 -1",
			maxAngleDif = 120,
		},
		[35] = { -- left
			name	= "MPL",
			mainDir = "1 0 -1",
			maxAngleDif = 120,
		},
		[36] = { -- bottom
			name	= "MPL",
			mainDir = "0 -1 -1",
			maxAngleDif = 120,
		},
		[37] = { -- right
			name	= "MPL",
			mainDir = "-1 0 -1",
			maxAngleDif = 120,
		},
		-- right blister [[1 y z]]
		[38] = { -- top
			name	= "MPL",
			mainDir = "1 1 0",
			maxAngleDif = 120,
		},
		[39] = { -- rear
			name	= "MPL",
			mainDir = "1 0 -1",
			maxAngleDif = 120,
		},
		[40] = { -- bottom
			name	= "MPL",
			mainDir = "1 -1 0",
			maxAngleDif = 120,
		},
		[41] = { -- front
			name	= "MPL",
			mainDir = "1 0 1",
			maxAngleDif = 120,
		},
	},
	
	customparams = {
		maxtonnage		= 400,
		cooldown		= 50 * 30,
		barrelrecoildist = 	{[1] = 50, -- Sniper
							 [2] = 5, -- AC10
							 [3] = 5, -- AC10
							 [4] = 5, -- AC10
							 [5] = 5, -- AC10
							},
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