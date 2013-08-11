-- Use the automatic CMD ID generator
local GetCmdID = GG.CustomCommands.GetCmdID

-- Common valid() functions here:
local function allMechs(unitDefID) return true end
local function hasJumpjets(unitDefID) return (UnitDefs[unitDefID].customParams.canjump or false) end

local function hasWeaponName(unitDefID, weapName)
	local weapons = UnitDefs[unitDefID].weapons
	for weapNum, weapTable in pairs(weapons) do 
		if weapTable["weaponDef"] == WeaponDefNames[weapName:lower()].id then return true end
	end
	return false
end

local function hasWeaponClass(unitDefID, className) -- projectile, energy, missile
	local weapons = UnitDefs[unitDefID].weapons
	for weapNum, weapTable in pairs(weapons) do 
		if WeaponDefs[weapTable["weaponDef"]].customParams["weaponclass"] == className then return true end
	end
	return false
end	

-- Common apply() functions
local function setWeaponClassAttribute(unitID, className, attrib, multiplier)
	local weapons = UnitDefs[Spring.GetUnitDefID(unitID)].weapons
	for weapNum, weapTable in pairs(weapons) do
		if WeaponDefs[weapTable["weaponDef"]].customParams["weaponclass"] == className then
			local currAttrib = Spring.GetUnitWeaponState(unitID, weapNum, attrib)
			--Spring.Echo("Current " .. attrib .. ": ", currAttrib, weapNum, WeaponDefs[weapTable["weaponDef"]].name)
			Spring.SetUnitWeaponState(unitID, weapNum, attrib, currAttrib * multiplier)
		end
	end
end

return {
	heatcapacity = {
		cmdDesc = {
			id = GetCmdID('PERK_HEAT_CAPACITY'),
			action = 'perkheatcapacity',
			name = '  Heat:\n  Capacity  ',
			tooltip = '+50% Heat capacity',
			--texture = 'unitpics/is_atlas.png',	
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
			--texture = 'unitpics/is_atlas.png',	
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
			--texture = 'unitpics/is_osiris.png',	
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
			--texture = 'unitpics/is_osiris.png',	
		},
		valid = hasJumpjets,
		applyPerk = function (unitID) 
			--Spring.Echo("Fast Reload Jumpjets selected") 
			local currReload = Spring.GetUnitRulesParam(unitID, "jumpReload")
			Spring.SetUnitRulesParam(unitID, "jumpReload", currReload * 0.5)
		end,
	},
	sensorrange = {
		cmdDesc = {
			id = GetCmdID('PERK_SENSORS_RANGE'),
			action = 'perksensorsrange',
			name = '  Sensors:\n  Range     ',
			tooltip = '+50% Radar and LOS range',
			--texture = 'unitpics/is_owens.png',	
		},
		valid = allMechs,
		applyPerk = function (unitID) 
			--Spring.Echo("Sensor range selected") 
			local currRadar = Spring.GetUnitSensorRadius(unitID, "radar")
			local currLos = Spring.GetUnitSensorRadius(unitID, "los")
			local currAirLos = Spring.GetUnitSensorRadius(unitID, "airLos")
			Spring.SetUnitSensorRadius(unitID, "radar", currRadar * 1.5)
			Spring.SetUnitSensorRadius(unitID, "los", currLos * 1.5)
			Spring.SetUnitSensorRadius(unitID, "airLos", currAirLos * 1.5)
		end,
	},
	narcduration = {
		cmdDesc = {
			id = GetCmdID('PERK_NARC_DURATION'),
			action = 'perknarkduration',
			name = '  NARC:\n  Duration  ',
			tooltip = '+50% NARC duration',
			--texture = 'unitpics/is_raven.png',	
		},
		valid = function (unitDefID) return hasWeaponName(unitDefID, "NARC") end,
		applyPerk = function (unitID) 
			--Spring.Echo("Sensor range selected") 
			local currDuration = Spring.GetUnitRulesParam(unitID, "NARC_DURATION") or Spring.GetGameRulesParam("NARC_DURATION")
			Spring.SetUnitRulesParam(unitID, "NARC_DURATION", currDuration * 1.5)
		end,
	},
	missilerange = {
		cmdDesc = {
			id = GetCmdID('PERK_MISSILE_RANGE'),
			action = 'perkmissilerange',
			name = '  Missiles:\n  Range     ',
			tooltip = '+50% Missile Range',
			--texture = 'unitpics/is_catapult.png',	
		},
		valid = function (unitDefID) return hasWeaponClass(unitDefID, "missile") end,
		applyPerk = function (unitID) 
			--Spring.Echo("Missile range selected") 
			setWeaponClassAttribute(unitID, "missile", "range", 1.5)
		end,
	},
	energyrange = {
		cmdDesc = {
			id = GetCmdID('PERK_ENERGY_RANGE'),
			action = 'perkenergyrange',
			name = '  Energy:\n  Range     ',
			tooltip = '+50% Energy Weapon Range',
			--texture = 'unitpics/cl_nova.png',	
		},
		valid = function (unitDefID) return hasWeaponClass(unitDefID, "energy") end,
		applyPerk = function (unitID) 
			--Spring.Echo("Energy range selected") 
			setWeaponClassAttribute(unitID, "energy", "range", 1.5)
		end,
	},
	projectilerange = {
		cmdDesc = {
			id = GetCmdID('PERK_PROJECTILE_RANGE'),
			action = 'perkprojectilerange',
			name = '  Projectile:\n  Range     ',
			tooltip = '+50% Projectile Weapon Range',
			--texture = 'unitpics/is_hollander.png',	
		},
		valid = function (unitDefID) return hasWeaponClass(unitDefID, "projectile") end,
		applyPerk = function (unitID) 
			--Spring.Echo("Projectile range selected") 
			setWeaponClassAttribute(unitID, "projectile", "range", 1.5)
		end,
	},
}