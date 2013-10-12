local CL_Adder = Light:New{
	corpse				= "CL_Adder_X",
	maxDamage           = 11500,
	mass                = 3500,
	buildCostEnergy     = 30,
	buildCostMetal      = 13320,
	maxVelocity		= 4.85, --97kph/30
	maxReverseVelocity= 2.43,
	acceleration    = 1.8,
	brakeRate       = 0.1,
	turnRate 		= 950,
    customparams = {
		heatlimit		= 24,
		torsoturnspeed	= 180,
    },
}

local Prime = CL_Adder:New{
	name              	= "Adder (Puma) Prime",
	description         = "Light Sniper Mech",
	objectName        	= "CL_Adder.s3o",
	weapons 		= {	
		[1] = {
			name	= "CERPPC",
		},
		[2] = {
			name	= "CERPPC",
		},
		[3] = {
			name	= "Flamer",
		},
	},
	customparams = {
		helptext		= "Armament: 2 x ER PPC, 1 x Flamer - Armor: 6 tons Ferro-Fibrous",
    },
}

return lowerkeys({
	["CL_Adder_Prime"] = Prime,
})