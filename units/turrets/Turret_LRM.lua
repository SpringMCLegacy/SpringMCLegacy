local Turret_LRM = Tower:New{
	description         = "LRM-20",
	objectName        	= "Turret_LRM.s3o",
	buildCostMetal      = 0,

	weapons = {	
		[1] = {
			name	= "LRM20",
			OnlyTargetCategory = "notbeacon",
		},
	},
	customparams = {
		turretturnspeed = 100,
		elevationspeed  = 200,
    },
}

return lowerkeys({
	["Turret_LRM"] = Turret_LRM,
})