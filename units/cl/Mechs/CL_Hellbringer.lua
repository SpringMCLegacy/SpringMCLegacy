local CL_Hellbringer = Heavy:New{
	corpse				= "CL_Hellbringer_X",
	sightDistance       = 1200,
	radarDistance      	= 2000,
	stealth				= 1,
	radarDistanceJam    = 500,
	maxDamage           = 12800,
	mass                = 6500,
	buildCostEnergy     = 65,
	buildCostMetal      = 26700,
	maxVelocity		= 4.3, --86kph/20
	maxReverseVelocity= 2.15,
	acceleration    = 1,
	brakeRate       = 0.2,
	turnRate 		= 700,

	customparams = {
		heatlimit		= 26,
		torsoturnspeed	= 130,
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
		helptext		= "Armament: 1 x Gauss Rifle, 1 x UAC/10, 1 x ER Small Beam Laser, 1 x LRM-10 - Armor: 8 tons Ferro-Fibrous",
    },
}

return lowerkeys({
	["CL_Hellbringer_B"] = B,
})