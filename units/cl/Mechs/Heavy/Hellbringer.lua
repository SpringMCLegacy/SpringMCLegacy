local CL_Hellbringer = Heavy:New{
	corpse				= "CL_Hellbringer_X",
	maxDamage           = 12800,
	maxVelocity		= 4.3, --86kph/20
	maxReverseVelocity= 2.15,
	acceleration    = 1,
	brakeRate       = 0.2,
	turnRate 		= 700,

	customparams = {
		heatlimit		= 26,
		tonnage			= 65,
		torsoturnspeed	= 130,
		maxammo 		= {gauss = 20, ac10 = 20, lrm = 120},
		hasecm			= true,
    },
}

local B = CL_Hellbringer:New{
	name              	= "Hellbringer (Loki) B",
	description         = "Heavy Sniper Mech",
	objectName        	= "CL_Hellbringer.s3o",
	weapons = {	
		[1] = {
			name	= "Gauss",
		},
		[2] = {
			name	= "UAC10",
		},
		[3] = {
			name	= "CERSBL",
		},
		[4] = {
			name	= "LRM10",
		},
		[9] = {
			name	= "AMS",
		},
	},
	customparams = {
		price      = 26700,
		helptext		= "Armament: 1 x Gauss Rifle, 1 x UAC/10, 1 x ER Small Beam Laser, 1 x LRM-10 - Armor: 8 tons Ferro-Fibrous",
    },
}

return lowerkeys({
	["CL_Hellbringer_B"] = B,
})