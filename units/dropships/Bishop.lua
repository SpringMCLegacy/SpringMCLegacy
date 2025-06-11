local Bishop = DropShip:New{
	name              	= "Bishop Aerocrane",
	description         = "Cargo Lander",
	objectName        	= "Dropship/Bishop.s3o", -- TODO: remove once faction textured models are available
	iconType			= "drost",
	category 			= "ground notbeacon",
	maxDamage           = 6000,
	mass                = 6000,
	usePieceCollisionVolumes = true,
	
	--Makes unit use weapon from /weapons folder
	weapons	= {	
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
	dropShips[sideName .. "_bishop"] = Bishop:New{}
end
return lowerkeys(dropShips)