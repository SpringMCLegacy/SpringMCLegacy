return {
	heatsinks = {
		cmdDesc = {
			id = 1000,
			action = 'perkheatsinks',
			name = 'Heatsink\nCapacity',
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
	jumpjetrange = {
		cmdDesc = {
			id = 1001,
			action = 'perkjumpjetrange',
			name = 'Jumpjet\nRange',
			tooltip = '+50% Jump range & speed',
			texture = 'unitpics/is_osiris.png',	
		},
		valid = function (unitDefID)
			-- only available for mechs which already have jumpjets
			return (UnitDefs[unitDefID].customParams.canjump or false) 
		end,
		applyPerk = function (unitID) 
			--Spring.Echo("Extended Range Jumpjets selected") 
			local currRange = Spring.GetUnitRulesParam(unitID, "jumpRange")
			local currSpeed = Spring.GetUnitRulesParam(unitID, "jumpSpeed")
			Spring.SetUnitRulesParam(unitID, "jumpRange", currRange * 1.5)
			Spring.SetUnitRulesParam(unitID, "jumpSpeed", currSpeed * 1.5)
		end,
	},
	jumpjetreload = {
		cmdDesc = {
			id = 1002,
			action = 'perkjumpjetreload',
			name = 'Jumpjet\nReload',
			tooltip = '-50% Jump reload time',
			texture = 'unitpics/is_osiris.png',	
		},
		valid = function (unitDefID)
			-- only available for mechs which already have jumpjets
			return (UnitDefs[unitDefID].customParams.canjump or false) 
		end,
		applyPerk = function (unitID) 
			--Spring.Echo("Fast Reload Jumpjets selected") 
			local currReload = Spring.GetUnitRulesParam(unitID, "jumpReload")
			Spring.SetUnitRulesParam(unitID, "jumpReload", currReload * 0.5)
		end,
	},
}