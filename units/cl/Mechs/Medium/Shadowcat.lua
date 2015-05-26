local CL_Shadowcat = Medium:New{
	corpse				= "CL_Shadowcat_X",
	maxDamage           = 13400,
	mass                = 4500,
	buildCostEnergy     = 45,
	buildCostMetal      = 26580,
	maxVelocity		= 4.85, --97kph/30
	maxReverseVelocity= 2.43,
	acceleration    = 1.8,
	brakeRate       = 0.1,
	turnRate 		= 950,
	
	customparams = {
		hasbap			= true,
		heatlimit		= 20,
		torsoturnspeed	= 175,
		canjump			= "1",
		canmasc			= true,
		maxammo 		= {gauss = 20},
    },
}
	
local Prime = CL_Shadowcat:New{
	name              	= "Shadow Cat Prime",
	description         = "Medium Sniper Mech",
	objectName        	= "CL_Shadowcat.s3o",
	weapons = {	
		[1] = {
			name	= "Gauss",
		},
		[2] = {
			name	= "CERMBL",
		},
		[3] = {
			name	= "CERMBL",
		},
	},

	customparams = {
		helptext		= "Armament: 1 x Gauss Rifle, 1 x ER Large Beam Laser, 1 x ER Medium Beam Laser - Armor: 7 tons",
    },
}

return lowerkeys({
	["CL_Shadowcat_Prime"] = Prime,
})