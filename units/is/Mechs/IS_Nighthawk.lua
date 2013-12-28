local IS_Nighthawk = Light:New{
	corpse				= "IS_Nighthawk_X",
	maxDamage           = 11200,
	mass                = 3500,
	buildCostEnergy     = 35,
	buildCostMetal        = 15000,
	maxVelocity		= 4.5, --90kph/20
	
	customparams = {
		heatlimit 		= "22",
		torsoturnspeed	= "180",
    },
}

local NTK2Q = IS_Nighthawk:New{
	name              	= "Night Hawk NTK-2Q",
	description         = "Light-class Mid Range Fire Support",
	objectName        	= "IS_Nighthawk_NTK2Q.s3o",	
	weapons	= {	
		[1] = {
			name	= "ERLBL",
		},
		[2] = {
			name	= "LBL",
		},
		[3] = {
			name	= "MPL",
			OnlyTargetCategory = "ground",
		},
	},
		
	customparams = {
		helptext		= "Armament: 1 x ER Large Beam Laser, 1 x Large Beam Laser, 1 x Medium Pulse Laser - Armor: 7.5 tons Stabdard",
    },
}

return lowerkeys({
	["IS_Nighthawk_NTK2Q"] = NTK2Q,
})