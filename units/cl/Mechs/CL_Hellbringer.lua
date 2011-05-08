local CL_Hellbringer = {
	name              	= "Hellbringer (Loki)",
	description         = "Heavy Sniper Mech",
	objectName        	= "CL_Hellbringer.s3o",
	iconType			= "heavymech",
	script				= "Mech.lua",
	corpse				= "CL_Hellbringer_X",
	explodeAs          	= "mechexplode",
	category 			= "mech ground notbeacon",
	noChaseCategory		= "beacon air",
	sightDistance       = 1200,
	radarDistance      	= 2000,
		stealth				= 1,
		activateWhenBuilt   = true,
		onoffable           = true,
		radarDistanceJam    = 500,
	maxDamage           = 12800,
	mass                = 6500,
	footprintX			= 3,
	footprintZ 			= 3,
	--collisionVolumeType = "box",
	--collisionVolumeScales = "40 50 40",
	--collisionVolumeOffsets = "0 0 0",
	collisionVolumeTest = 1,
	usePieceCollisionVolumes = true,
--	leaveTracks			= 1,
--	trackOffset			= 10,--no idea what this does
--	trackStrength		= 2.5,--how visible the tracks are
--	trackStretch		= 1,-- how much the tracks stretch, the higher the number the more "compact" they become
--	trackType			= "Thick",--graphics file to use for the track decal, from \bitmaps\tracks\ folder
--	trackWidth			= 20,--width to render the decal
	buildCostEnergy     = 65,
	buildCostMetal      = 26700,
	buildTime           = 0,
	upright				= true,
	canMove				= true,
		movementClass   = "LARGEMECH",
		maxVelocity		= 4.3, --86kph/20
		maxReverseVelocity= 2.15,
		acceleration    = 1,
		brakeRate       = 0.2,
		turnRate 		= 700,
		smoothAnim		= 1,
	
	canAttack 			= true,
		--Makes unit use weapon from /weapons folder
		weapons 		= {	
			[1] = {
				name	= "Gauss",
				mainDir = "0 0 1",
				maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
			},
			[2] = {
				name	= "UAC10",
				--weaponSlaveTo2 = 1,
				mainDir = "0 0 1",
				maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[3] = {
				name	= "CERSBL",
				mainDir = "0 0 1",
				maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[4] = {
				name	= "LRM10",
				mainDir = "0 0 1",
				maxAngleDif = 220,
				OnlyTargetCategory = "notbeacon",
				WeaponSlaveTo = 1,
			},
			[9] = {
				name	= "AMS",
			},
		},
    customparams = {
		hasturnbutton	= "1",
		helptext		= "Armament: 1 x Gauss Rifle, 1 x UAC/10, 1 x ER Small Beam Laser, 1 x LRM-10 - Armor: 8 tons Ferro-Fibrous",
		heatlimit		= "26",
		torsoturnspeed	= "130",
		unittype		= "mech",
    },
}

return lowerkeys({ ["CL_Hellbringer"] = CL_Hellbringer })