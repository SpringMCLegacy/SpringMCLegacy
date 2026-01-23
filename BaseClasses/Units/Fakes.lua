-- Fake Unit --
-- Used as base for various invisible fake units
local Fake = Unit:New{
	objectName 				= "Fake.s3o",
	script 					= "Fake.lua",
	hideDamage				= true,
	maxDamage				= 10, -- hack to avoid showing healthbar, never actually takes damage
	
	customParams = {
		ignoreatbeacon	= true,
	}
}


return {
	Fake = Fake,
}