weaponDef = {
	name                    = "Anti-Missile System (AMS)",
	weaponType				= "Shield",
	isShield				= true,
	shieldInterceptType		= 32,
	exteriorShield			= false,
	shieldEnergyUse			= 0,
	shieldPower				= 500,
	shieldPowerRegen		= 100,
	shieldPowerRegenEnergy	= 0,
	shieldRadius			= 200,
	shieldStartingPower		= 500,
	smartShield				= true,
	visibleShield			= false,
	--	shieldAlpha				= 1.0,
	--	shieldGoodColor			= "0.0 1.0 0.0",
	--	shieldBadColor			= "1.0 0.0 0.0",
	damage = {
		default = 10,--1 DPS
	},
}

return lowerkeys({ AMS = weaponDef })