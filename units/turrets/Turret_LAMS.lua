local Turret_LAMS = Tower:New{
	description         = "Laser AMS",
	objectName        	= "Turret_LAMS.s3o",
	--buildCostMetal      = 0,

	weapons = {	
		[1] = {
			name	= "LAMS",
		},
	},
	customparams = {
		turretturnspeed = 300,
		elevationspeed  = 300,
    },
}

return lowerkeys({
	["Turret_LAMS"] = Turret_LAMS,
})