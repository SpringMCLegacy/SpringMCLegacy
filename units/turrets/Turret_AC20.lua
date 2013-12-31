local Turret_AC20 = Tower:New{
	description         = "Ultra Autocannon/20",
	objectName        	= "Turret_AC20.s3o",
	buildCostMetal      = 6000,

	weapons	= {	
		[1] = {
			name	= "AC20",
			OnlyTargetCategory = "notbeacon",
		},
	},
	customparams = {
		barrelrecoildist = {[1] = 5},
		turretturnspeed = 100,
		elevationspeed  = 150,
    },
}

return lowerkeys({
	["Turret_AC20"] = Turret_AC20,
})