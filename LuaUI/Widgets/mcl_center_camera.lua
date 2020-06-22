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


function widget:UnitCreated(unitID, unitDefID)
	local unitDef = UnitDefs[unitDefID]
	if unitDef.name:find("dropzone") then
		local x,y,z = Spring.GetUnitPosition(unitID)
		Spring.SelectUnitArray({unitID})
		Spring.GiveOrderToUnit(unitID, Spring.GetGameRulesParam("CMD_MENU_LIGHTMECH"), {}, {})
		Spring.SetCameraTarget(x,y,z)
		widgetHandler:RemoveWidget()
	end
end