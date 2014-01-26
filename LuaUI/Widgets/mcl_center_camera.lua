function widget:GetInfo()
	return {
		name      = "MC:L - Center camera",
		desc      = "Centers camera on your command unit on game start",
		author    = "Gnome, FLOZi (C Lawrence)",
		date      = "June 2008, Jan 2014",
		license   = "Public domain",
		layer     = -5,
		enabled   = true  --  loaded by default?
	}
end

function widget:GameFrame(n)
	local teamID = Spring.GetLocalTeamID()
	local clanDZ = Spring.GetTeamUnitDefCount(teamID, UnitDefNames["cl_dropzone"].id)
	local isDZ = Spring.GetTeamUnitDefCount(teamID, UnitDefNames["is_dropzone"].id)
	if clanDZ == 1 or isDZ == 1 then
		local DZ = clanDZ == 1 and UnitDefNames["cl_dropzone"].id or UnitDefNames["is_dropzone"].id
		local units =	Spring.GetTeamUnitsByDefs(teamID, DZ)
		local x,y,z = Spring.GetUnitPosition(units[1])
		Spring.SelectUnitArray({units[1]})
		Spring.SetCameraTarget(x,y,z)
		widgetHandler:RemoveWidget()
	end
end