return {
	heatsinks = {
		cmdDesc = {
			id = 3000,
			action = 'perkheatsinks',
			name = 'Extra\nHeatsinks',
			tooltip = '+50% Heat capacity',
			texture = 'unitpics/is_atlas.png',	
		},
		valid = function (unitDefID) return true end, -- available for all mechs
		applyPerk = function (unitID) 
			--Spring.Echo("Extra Heatsinks selected") 
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
			tooltip = '+50% Jump range & speed',
			texture = 'unitpics/is_osiris.png',	
		},
		valid = function (unitDefID)
			-- only available for mechs which already have jumpjets
			return (UnitDefs[unitDefID].customParams.canjump or false) 
		end,
		applyPerk = function (unitID) 
			--Spring.Echo("Enhanced Jumpjets selected") 
			local currRange = Spring.GetUnitRulesParam(unitID, "jumpRange")
			local currSpeed = Spring.GetUnitRulesParam(unitID, "jumpSpeed")
			Spring.SetUnitRulesParam(unitID, "jumpRange", currRange * 1.5)
			Spring.SetUnitRulesParam(unitID, "jumpSpeed", currSpeed * 1.5)
		end,
	},
}