-- Use the automatic CMD ID generator
local GetCmdID = GG.CustomCommands.GetCmdID

-- Common valid() functions here:
local function allMechs(unitDefID) return true end
local function hasJumpjets(unitDefID) return (UnitDefs[unitDefID].customParams.canjump or false) end

return {
	heatcapacity = {
		cmdDesc = {
			id = GetCmdID('PERK_HEAT_CAPACITY'),
			action = 'perkheatcapacity',
			name = '  Heat:\n  Capacity  ',
			tooltip = '+50% Heat capacity',
			texture = 'unitpics/is_atlas.png',	
		},
		valid = allMechs,
		applyPerk = function (unitID) 
			--Spring.Echo("Heatsink Capacity selected") 
			env = Spring.UnitScript.GetScriptEnv(unitID)
			env.heatLimit = env.heatLimit * 1.5
			Spring.SetUnitRulesParam(unitID, "heatLimit", env.heatLimit)
		end,
	},
	heatdissapate = {
		cmdDesc = {
			id = GetCmdID('PERK_HEAT_DISSIPATE'),
			action = 'perkheatsdissipate',
			name = '  Heat:\n  Dissipate ',
			tooltip = '+50% Heat disiapation rate',
			texture = 'unitpics/is_atlas.png',	
		},
		valid = allMechs,
		applyPerk = function (unitID) 
			--Spring.Echo("Heatsink Dissipation selected") 
			env = Spring.UnitScript.GetScriptEnv(unitID)
			env.baseCoolRate = env.baseCoolRate * 1.5
		end,
	},
	jumpjetrange = {
		cmdDesc = {
			id = GetCmdID('PERK_JUMP_RANGE'),
			action = 'perkjumpjetrange',
			name = '  Jump:\n  Range     ',
			tooltip = '+50% Jump range & speed',
			texture = 'unitpics/is_osiris.png',	
		},
		valid = hasJumpjets,
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
			id = GetCmdID('PERK_JUMP_RELOAD'),
			action = 'perkjumpjetreload',
			name = '  Jump:\n  Reload    ',
			tooltip = '-50% Jump reload time',
			texture = 'unitpics/is_osiris.png',	
		},
		valid = hasJumpjets,
		applyPerk = function (unitID) 
			--Spring.Echo("Fast Reload Jumpjets selected") 
			local currReload = Spring.GetUnitRulesParam(unitID, "jumpReload")
			Spring.SetUnitRulesParam(unitID, "jumpReload", currReload * 0.5)
		end,
	},
}