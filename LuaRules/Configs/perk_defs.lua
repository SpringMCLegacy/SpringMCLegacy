return {
	heatsinks = {
		cmdDesc = {
			id = 3000,
			action = 'perkheatsinks',
			name = 'Extra\nHeatsinks',
			disabled = true,
			tooltip = '+50% Heat Capacity',
			texture = 'unitpics/is_atlas.png',	
		},
		valid = function (unitDefID) return true end,
		applyPerk = function (unitID) 
			Spring.Echo("Extra Heatsinks selected") 
			env = Spring.UnitScript.GetScriptEnv(unitID)
			env.heatLimit = env.heatLimit * 1.5
			Spring.SetUnitRulesParam(unitID, "heatLimit", env.heatLimit)
		end,
	},
	jumpjets = {
		cmdDesc = {
			id = 3001,
			action = 'perkjumpjet',
			name = 'Enhanced\nJumpjets',
			disabled = true,
			tooltip = '+50% Jump Range',
			texture = 'unitpics/is_osiris.png',	
		},
		valid = function (unitDefID)
			return (UnitDefs[unitDefID].customParams.canjump or false) 
		end,
		applyPerk = function (unitID) 
			Spring.Echo("Enhanced Jumpjets selected") 
			local currRange = Spring.GetUnitRulesParam(unitID, "jumpRange")
			local currSpeed = Spring.GetUnitRulesParam(unitID, "jumpSpeed")
			Spring.SetUnitRulesParam(unitID, "jumpRange", currRange * 1.5)
			Spring.SetUnitRulesParam(unitID, "jumpSpeed", currSpeed * 1.5)
		end,
	},
}