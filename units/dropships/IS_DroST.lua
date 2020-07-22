local IS_DroST = DropShip:New{
	name              	= "DroST II Landing Craft",
	description         = "Cargo Landing Craft",
	objectName        	= "Dropship/DroST.s3o", -- TODO: remove once faction textured models are available
	iconType			= "drost",
	category 			= "ground notbeacon",
	maxDamage           = 13000,
	mass                = 13000,
	usePieceCollisionVolumes = true,
	
	--Makes unit use weapon from /weapons folder
	weapons	= {	
		[1] = {
			name	= "AC10",
			maxAngleDif = 100,
		},
		[2] = {
			name	= "LBL",
			maxAngleDif = 100,
		},
		[3] = {
			name	= "LBL",
			maxAngleDif = 100,
		},
		[4] = {
			name	= "MBL",
			maxAngleDif = 100,
		},
		[5] = {
			name	= "MBL",
			maxAngleDif = 100,
		},
	},
	customparams = {
		helptext		= "A Dropship",
		dropship		= "outpost",
		hoverheight		= 300,
		radialdist		= 2500,
		ignoreatbeacon	= true,
    },
	sounds = {
		underattack        = "Dropship_Alarm",
	},
}

dropShips = {}
for i, sideName in pairs(Sides) do
	dropShips[sideName .. "_drost"] = IS_DroST:New{}
end
return lowerkeys(dropShips)