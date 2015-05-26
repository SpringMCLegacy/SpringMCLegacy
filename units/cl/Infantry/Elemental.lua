local CL_Elemental = Light:New{
	corpse				= "CL_Elemental_X",
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
		maxammo 		= {srm = 2},
		unittype = "infantry",
		squadsize		= 5,
    },
}
	
local Prime = CL_Elemental:New{
	name              	= "Elemental",
	description         = "Battle Armour",
	objectName        	= "CL_Elemental.s3o",
	weapons 		= {	
		[1] = {
			name	= "MicroSPL",
		},
		[2] = {
			name	= "InfSRM2",
		},
		[3] = {
			name	= "Microlaser",
		},
	},
}
return lowerkeys({
	["CL_Elemental_Prime"] = Prime:New(),
	["IS_Standard_BA"] = Prime:New(),
})