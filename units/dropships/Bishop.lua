local Bishop = DropShip:New{
	name              	= "Bishop Aerocrane",
	description         = "Cargo Lander",
	buildPic			= "Dropship_Bishop.png", -- TODO: remove in future
	objectName        	= "Dropship/Bishop.s3o", -- TODO: automatically look for non-faction models too
	iconType			= "bishop",
	corpse				= "Bishop_x",
	maxDamage           = 6000,
	mass                = 6000,
	usePieceCollisionVolumes = true,
	explodeAs          	= "mechexplode",
	canFly				= true,
	
	--Makes unit use weapon from /weapons folder
	weapons	= {	
	},
	customparams = {
		dropship		= "outpost",
		hoverheight		= 300,
		radialdist		= 2500,
		ignoreatbeacon	= true,
		normaltex		= "unittextures/normals/Bishop_Normals.dds",
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