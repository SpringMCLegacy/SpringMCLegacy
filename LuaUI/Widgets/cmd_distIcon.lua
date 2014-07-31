function widget:GetInfo()
	return {
		name = "MC:L - Icon Distance",
		desc = "Sets Icon Distance to a suitable level for MC:L",
		author = "Craig Lawrence",
		date = "09-12-2008",
		license = "Public Domain",
		layer = 1,
		enabled = true
	}
end

local unitIconDist = 0

function widget:Initialize()
	unitIconDist = Spring.GetConfigInt('UnitIconDist')
	Spring.SendCommands("disticon 150")
end

function widget:Shutdown()
	Spring.SendCommands("disticon " .. unitIconDist)
end
