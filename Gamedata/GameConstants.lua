return {
	ammoTypes = {
		LRM			= 96,--24/ton
		SRM			= 100,--50/ton
		InfSRM		= 2,--1/ton
		ATM			= 80,--20/ton
		MRM			= 96,--24/ton
		Arrow		= 6,--5/ton
		Narc		= 12,--6/ton
		MML			= 132,--33-40/ton

		AC2			= 180,--45/ton
		AC5			= 80,--20/ton
		AC10 		= 25,--10/ton
		AC20		= 10,--5/ton
		Thumper		= 20,--15/ton ???
		Sniper		= 10,--10/ton ???
		LongTom		= 5,--5/ton ???

		Gauss		= 13,--8/ton
		LtGauss		= 40,--16/ton
		HvGauss		= 4,--4/ton
	
		Bomb		= 1,
	},
	damageMults = {
		dropship	= 0.8,
		beacons		= 0,
		infantry	= 1,
		light		= 1,   
		medium		= 0.9, 
		heavy		= 0.8, 
		assault		= 0.6, 
		vehicle		= 1.25,
		aero		= 1.25, 
		vtol		= 1.25,
		tower		= 1,
		walls		= 1,
		outpost		= 1,
	},
	partsList = {
		mech	= {"torso", "arm_left", "arm_right", "leg_left", "leg_right"},
		apc		= {"turret", "base"},
		vehicle	= {"turret", "base"},
		aero	= {"body", "left_wing", "right_wing"},
		vtol	= {"body", "rotor"},
	},
}