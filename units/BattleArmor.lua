local BattleArmor = Light:New{
	corpse				= "",
	maxDamage           = 500,
	mass                = 500,
	buildCostEnergy     = 5,
	buildCostMetal      = 5,
	explodeAs			= "Death_Class",
	iconType			= "infantry",
	maxVelocity		= 14.3, --86kph/20
	--maxReverseVelocity= 2.15,
	acceleration    = 1.7,
	brakeRate       = 0.1,
	turnRate 		= 3000,
	
	footprintX = 1,
	footprintZ = 1,
	script = "Infantry.lua",

	cruisealt = 50,
	canfly = true,
	hoverattack = true,
	airhoverfactor = 10,
	canLoopbackAttack = true,
	usesmoothmesh = false,
	
		maxAcc			= 0.2,
	maxBank			= 0.07,
	maxPitch		= 0.0007,
	maxAileron		= 0.0045,
	maxElevator		= 0.004,
	maxRudder		= 0.2,
	wingAngle		= 0.1,
	wingDrag		= 0.07,
	myGravity		= 0.8,
	turnRadius		= 100,
	
	customparams = {
		helptext		= "Armament: Small Pulse Laser, SRM-2, Microlaser",
		heatlimit		= 20,
		torsoturnspeed	= 380,
		maxammo 		= {infsrm = 4},
		squadsize		= 5,
		baseclass		= "infantry", -- TODO: hacks
    },
}
	
local Elemental = BattleArmor:New{
	name              	= "Elemental",
	description         = "Battle Armour",
	objectName        	= "Elemental.s3o",
	weapons 		= {	
		[1] = {
			name	= "SBL",
		},
		[2] = {
			name	= "InfSRM2",
		},
		[3] = {
			name	= "InfMG",
		},
	},
}

local Standard = BattleArmor:New{
	name              	= "Inner Sphere Standard",
	description         = "Battle Armour",
	objectName        	= "Standard.s3o",
	
	weapons 		= {	
		[1] = {
			name	= "SBL",
		},
	},
	
	customparams = {
		squadsize		= 3,
    },
}

local StandardSRM = BattleArmor:New{
	name              	= "Inner Sphere Standard SRM",
	description         = "Battle Armour",
	objectName        	= "Standard.s3o",
	
	weapons 		= {	
		[1] = {
			name	= "InfSRM",
		},
	},
	
	customparams = {
		squadsize		= 2,
    },
}

return lowerkeys({
	["CL_Elemental"] = Elemental:New(),
	["CC_Standard"] = Standard:New(),
	["CC_StandardSRM"] = StandardSRM:New(),
	["DC_Standard"] = Standard:New(),
	["DC_StandardSRM"] = StandardSRM:New(),
	["FS_Standard"] = Standard:New(),
	["FS_StandardSRM"] = StandardSRM:New(),
	["FW_Standard"] = Standard:New(),
	["FW_StandardSRM"] = StandardSRM:New(),
	["LA_Standard"] = Standard:New(),
	["LA_StandardSRM"] = StandardSRM:New(),
})