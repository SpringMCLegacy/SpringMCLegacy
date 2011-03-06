weaponDef = {
	name                    = "Dropship Anti-Missile System (AMS)",
	isShield				= true,
	shieldInterceptType		= 1,
	exteriorShield			= true,
	shieldEnergyUse			= 0,
	shieldPower				= 1500,
	shieldPowerRegen		= 750,
	shieldPowerRegenEnergy	= 0,
	shieldRadius			= 500,
	shieldStartingPower		= 1500,
	smartShield				= true,
	visibleShield			= false,
		shieldAlpha				= 1.0,
		shieldGoodColor			= "0.0 1.0 0.0",
		shieldBadColor			= "1.0 0.0 0.0",
	damage = {
		default = 10,--1 DPS
	},

}

return lowerkeys({ AMS_Dropship = weaponDef })