weaponDef = {
	name                    = "Sniper Artillery Cannon",
	weaponType              = "Cannon",
	explosionGenerator    	= "custom:HE_XLARGE",
	soundHit             	= [[GEN_Explode5]],
	soundStart           	= [[Sniper_Fire]],
	burnblow				= false, 	--Bullets explode at range limit.
	collideFriendly			= true,
	noSelfDamage            = true,
	turret                  = true,
	ballistic				= 1,
	range                   = 10000,
	accuracy                = 350,
	tolerance				= 1000,
	areaOfEffect            = 200,
	weaponVelocity          = 1000,
	reloadtime              = 20,
	renderType				= 1,
	size					= 3,
	sizeDecay				= 0,
	separation				= 2, 		--Distance between each plasma particle.
	stages					= 75, 		--Number of particles used in one plasma shot.
--	AlphaDecay				= 0.05, 		--How much a plasma particle is more transparent than the previous particle. 
	rgbcolor				= "1 0.8 0",
	intensity				= 0.5,
	damage = {
		default = 7500, --375 DPS (should be 250, but seemed weak)
		dropships = 0,--haha fuck you flozi
	},
	customparams = {
		heatgenerated		= "200",--10/sec
    },
}

return lowerkeys({ Sniper = weaponDef })