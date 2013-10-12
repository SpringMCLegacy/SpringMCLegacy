local CL_Nova = Medium:New{
	corpse				= "CL_Nova_X",
	maxDamage           = 16000,
	mass                = 5000,
	buildCostEnergy     = 50,
	buildCostMetal      = 29280,
	maxVelocity		= 4.3, --86kph/20
	maxReverseVelocity= 2.15,
	acceleration    = 1.8,
	brakeRate       = 0.1,
	turnRate 		= 850,
	
	customparams = {
		heatlimit		= 36,
		torsoturnspeed	= 150,
		canjump			= "1",
    },
}

local Prime = CL_Nova:New{
	name              	= "Nova (Black Hawk) Prime",
	description         = "Medium Strike Mech",
	objectName        	= "CL_Nova.s3o",
	weapons = {	
		-- put these in via a loop
	},

	customparams = {
		helptext		= "Armament: 12 x ER Medium Beam Laser - Armor: 10 tons",
    },
}
for i = 1, 12 do -- yep that's 12 ERMBLs, count 'em!
	Prime.weapons[i] = {name = "CERMBL"}
end

return lowerkeys({
	["CL_Nova_Prime"] = Prime
})