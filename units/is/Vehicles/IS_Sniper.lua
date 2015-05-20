local IS_Sniper = LightTank:New{
	name              	= "Sniper",
	description         = "Mobile Artillery",
	objectName        	= "IS_Sniper.s3o",
	corpse				= "IS_Sniper_X",
	maxDamage           = 12000,
	mass                = 8000,
	trackWidth			= 24,--width to render the decal
	buildCostEnergy     = 80,
	buildCostMetal      = 9135,
	maxVelocity		= 1.8, --54kph/30
	maxReverseVelocity= 1.3,
	acceleration    = 0.6,
	brakeRate       = 0.1,
	turnRate 		= 300,
	
	weapons	= {	
		[1] = {
			name	= "Sniper",
			maxAngleDif = 15,
		},
		[2] = {
			name	= "ERSBL",
		},
		[3] = {
			name	= "ERSBL",
			SlaveTo = 2,
		},
	},
	
	customparams = {
		helptext		= "Armament: 1 x Sniper Artillery Gun, 2 x ER Small Beam Laser - Armor: 12 tons",
		heatlimit		= 15,
		turretturnspeed = 50,
		turret2turnspeed = 200,
		elevationspeed = 50,
		turrets = {[2] = 2, [3] = 2},
		barrelrecoildist = {[1] = 4},
		maxammo 		= {sniper = 10},
    },
}

return lowerkeys({
	["IS_Sniper"] = IS_Sniper,
})