return {
	heatsinks = {
		cmdDesc = {
			id = 3000,
			action = 'perkheatsinks',
			name = 'Extra Heatsinks',
			disabled = true,
			tooltip = '+5% Heat Capacity',
			texture = 'unitpics/is_atlas.png',	
		},
		valid = function (unitDefID) return true end,
		applyPerk = function (unitID) 
			Spring.Echo("Extra Heatsinks selected") 
			env = Spring.UnitScript.GetScriptEnv(unitID)
			--Spring.Echo(env.heatLimit)
			env.heatLimit = 1000
			Spring.SetUnitRulesParam(unitID, "heatLimit", env.heatLimit)
			--Spring.Echo(Spring.GetUnitRulesParam(unitID, "heatLimit"))
		end,
	},
	jumpjets = {
		cmdDesc = {
			id = 3001,
			action = 'perkjumpjet',
			name = 'Enhanced Jumpjets',
			disabled = true,
			tooltip = '+5% Jump Range',
			texture = 'unitpics/is_osiris.png',	
		},
		valid = function (unitDefID) return true end,
		applyPerk = function (unitID) 
			Spring.Echo("Enhanced Jumpjets selected") 
			Spring.SetUnitRulesParam(unitID, "jumpRange", 1000000)
		end,
	},
}