local Garrison_Sniper = Tower:New{
	description         = "Sniper Artillery Cannon",
	buildCostMetal      = 20000,

	weapons	= {	
		[1] = {
			name	= "Sniper",
			OnlyTargetCategory = "notbeacon",
		},
	},
	customparams = {
		barrelrecoildist = {[1] = 10},
		turretturnspeed = 100,
		elevationspeed  = 150,
    },
	sounds = {
	select = "TurretHeavy",
	}
}

return lowerkeys({
	--["Garrison_Sniper"] = Garrison_Sniper,
})