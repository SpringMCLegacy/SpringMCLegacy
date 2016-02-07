-- Use the automatic CMD ID generator
local GetCmdID = GG.CustomCommands.GetCmdID

local PAD_LENGTH = 12
local function Pad(input, input2)
	while input:len() < PAD_LENGTH do
		input = " " .. input .. " "
	end
	if input2 then return input .. "\n" .. Pad(input2) end
	return input
end


-- Common valid() functions here:
local function allMechs(unitDefID) return (UnitDefs[unitDefID].customParams.baseclass == "mech") end
local function hasJumpjets(unitDefID) return (UnitDefs[unitDefID].customParams.jumpjets or false) end
local function hasMASC(unitDefID) return (UnitDefs[unitDefID].customParams.masc or false) end
local function hasECM(unitDefID) return (UnitDefs[unitDefID].customParams.ecm or false) end
local function hasBAP(unitDefID) return (UnitDefs[unitDefID].customParams.bap or false) end
local function isFaction(unitDefID, faction) return UnitDefs[unitDefID].name:sub(1,2) == faction end

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


-- Common costFunction() functions

local function deductXP(unitID, amount)
	local currExp = Spring.GetUnitExperience(unitID)
	local newExp = currExp - amount
	Spring.SetUnitExperience(unitID, newExp)
	Spring.SetUnitRulesParam(unitID, "perk_xp", math.min(100, 100 * newExp / amount))
end

local function deductCBills(unitID, amount)
	local teamID = Spring.GetUnitTeam(unitID)
	Spring.UseTeamResource(teamID, "m", amount)
end

return {
	-- Generic
	heatefficiency = {
		cmdDesc = {
			id = GetCmdID('PERK_HEAT_EFFICIENCY'),
			action = 'perkheatsefficiency',
			name = Pad("Heatsinks"),
			tooltip = '+50% Heat dissipation rate & capacity',
			texture = 'bitmaps/ui/perkbg.png',	
		},
		valid = allMechs,
		applyPerk = function (unitID) 
			--Spring.Echo("Heatsink Dissipation selected") 
			env = Spring.UnitScript.GetScriptEnv(unitID)
			env.baseCoolRate = env.baseCoolRate * 1.5
			env.heatLimit = env.heatLimit * 1.5
			Spring.SetUnitRulesParam(unitID, "heatLimit", env.heatLimit)
		end,
		costFunction = deductXP,
	},
	sensorrange = {
		cmdDesc = {
			id = GetCmdID('PERK_SENSORS_RANGE'),
			action = 'perksensorsrange',
			name = Pad("Sensors"),
			tooltip = '+50% Radar and LOS range',
			texture = 'bitmaps/ui/perkbg.png',	
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
			if hasBAP(Spring.GetUnitDefID(unitID)) then
				GG.allyBAPs[Spring.GetUnitAllyTeam(unitID)][unitID] = currRadar * 1.5
			end
		end,
		costFunction = deductXP,
	},
	-- Ability modifiers
	narcduration = {
		cmdDesc = {
			id = GetCmdID('PERK_NARC_DURATION'),
			action = 'perknarkduration',
			name = Pad("NARC"),
			tooltip = '+50% NARC duration',
			texture = 'bitmaps/ui/perkbgability.png',	
		},
		valid = function (unitDefID) return hasWeaponName(unitDefID, "NARC") end,
		applyPerk = function (unitID) 
			--Spring.Echo("Sensor range selected") 
			local currDuration = Spring.GetUnitRulesParam(unitID, "NARC_DURATION") or Spring.GetGameRulesParam("NARC_DURATION")
			Spring.SetUnitRulesParam(unitID, "NARC_DURATION", currDuration * 1.5)
		end,
		costFunction = deductXP,
	},
	jumpjetefficiency = {
		cmdDesc = {
			id = GetCmdID('PERK_JUMP_EFFICIENCY'),
			action = 'perkjumpjetefficiency',
			name = Pad("Jumpjets"),
			tooltip = '+50% Jump range, speed & reload',
			texture = 'bitmaps/ui/perkbgability.png',	
		},
		valid = hasJumpjets,
		applyPerk = function (unitID) 
			--Spring.Echo("Extended Range Jumpjets selected") 
			local currRange = Spring.GetUnitRulesParam(unitID, "jumpRange")
			local currSpeed = Spring.GetUnitRulesParam(unitID, "jumpSpeed")
			local currReload = Spring.GetUnitRulesParam(unitID, "jumpReload")
			Spring.SetUnitRulesParam(unitID, "jumpRange", currRange * 1.5)
			Spring.SetUnitRulesParam(unitID, "jumpSpeed", currSpeed * 1.5)
			Spring.SetUnitRulesParam(unitID, "jumpReload", currReload * 0.5)
		end,
		costFunction = deductXP,
	},
	mascefficiency = {
		cmdDesc = {
			id = GetCmdID('PERK_MASC_EFFICIENCY'),
			action = 'perkmascefficiency',
			name = Pad("MASC"),
			tooltip = '-50% MASC heat generation',
			texture = 'bitmaps/ui/perkbgability.png',	
		},
		valid = hasMASC,
		applyPerk = function (unitID) 
			--Spring.Echo("MASC heat reduction selected") 
			env = Spring.UnitScript.GetScriptEnv(unitID)
			env.mascHeatRate = env.mascHeatRate * 0.5
		end,
		costFunction = deductXP,
	},
	amsrange = {
		cmdDesc = {
			id = GetCmdID('PERK_AMS_RANGE'),
			action = 'perkamsrange',
			name = Pad("AMS"),
			tooltip = '+50% AMS Weapon Range',
			texture = 'bitmaps/ui/perkbgability.png',	
		},
		valid = function (unitDefID) return hasWeaponClass(unitDefID, "ams") end,
		applyPerk = function (unitID) 
			--Spring.Echo("Projectile range selected") 
			setWeaponClassAttribute(unitID, "ams", "range", 1.5)
		end,
		costFunction = deductXP,
	},
	ecmrange = {
		cmdDesc = {
			id = GetCmdID('PERK_ECM_RANGE'),
			action = 'perkecmrange',
			name = Pad("ECM"),
			tooltip = '+50% ECM range',
			texture = 'bitmaps/ui/perkbgability.png',	
		},
		valid = function (unitDefID) return (hasECM(unitDefID) and isFaction(unitDefID, "cc")) end,
		applyPerk = function (unitID) 
			--Spring.Echo("ECM range selected") 
			local currECM = Spring.GetUnitSensorRadius(unitID, "radarJammer")
			Spring.SetUnitSensorRadius(unitID, "radarJammer", currECM * 1.5)
			GG.allyJammers[Spring.GetUnitAllyTeam(unitID)][unitID] = currECM * 1.5
		end,
		costFunction = deductXP,
	},
	insulation = {
		cmdDesc = {
			id = GetCmdID('PERK_INSULATED_ELECTRONICS'),
			action = 'perkinsulatedelectronics',
			name = Pad("Insulated", "Electronics"),
			tooltip = '-50% PPC disruption time',
			texture = 'bitmaps/ui/perkbgability.png',	
		},
		valid = function (unitDefID) return (hasECM(unitDefID) or hasBAP(unitDefID)) end,
		applyPerk = function (unitID) 
			--Spring.Echo("Insulated Electronics selected") 
			Spring.SetUnitRulesParam(unitID, "insulation", 0.5)
		end,
		costFunction = deductXP,
	},
	-- Weapon (Faction) specific
	lrmrange = {
		cmdDesc = {
			id = GetCmdID('PERK_LRM_RANGE'),
			action = 'perklrmrange',
			name = Pad("LRM"),
			tooltip = '+50% LRM Range',
			texture = 'bitmaps/ui/perkbgfaction.png',	
		},
		valid = function (unitDefID) return (hasWeaponClass(unitDefID, "lrm") and isFaction(unitDefID, "fw")) end,
		applyPerk = function (unitID) 
			--Spring.Echo("Missile range selected") 
			setWeaponClassAttribute(unitID, "lrm", "range", 1.5)
		end,
		costFunction = deductXP,
	},
	mrmrange = {
		cmdDesc = {
			id = GetCmdID('PERK_MRM_RANGE'),
			action = 'perkmrmrange',
			name = Pad("MRM"),
			tooltip = '+50% MRM Range',
			texture = 'bitmaps/ui/perkbgfaction.png',	
		},
		valid = function (unitDefID) return (hasWeaponClass(unitDefID, "mrm") and isFaction(unitDefID, "dc")) end,
		applyPerk = function (unitID) 
			--Spring.Echo("Missile range selected") 
			setWeaponClassAttribute(unitID, "mrm", "range", 1.5)
		end,
		costFunction = deductXP,
	},
	ppcrange = {
		cmdDesc = {
			id = GetCmdID('PERK_PPC_RANGE'),
			action = 'perkppcrange',
			name = Pad("PPC"),
			tooltip = '+50% PPC Weapon Range',
			texture = 'bitmaps/ui/perkbgfaction.png',	
		},
		valid = function (unitDefID) return (hasWeaponClass(unitDefID, "ppc") and isFaction(unitDefID, "dc")) end,
		applyPerk = function (unitID) 
			--Spring.Echo("PPC range selected") 
			setWeaponClassAttribute(unitID, "ppc", "range", 1.5)
		end,
		costFunction = deductXP,
	},
	autocannonrange = {
		cmdDesc = {
			id = GetCmdID('PERK_AUTOCANNON_RANGE'),
			action = 'perkautocannonrange',
			name = Pad("Autocannon"),
			tooltip = '+50% Autocannon Weapon Range',
			texture = 'bitmaps/ui/perkbgfaction.png',	
		},
		valid = function (unitDefID) return (hasWeaponClass(unitDefID, "autocannon") and isFaction(unitDefID, "fs")) end,
		applyPerk = function (unitID) 
			--Spring.Echo("Autocannon range selected") 
			setWeaponClassAttribute(unitID, "autocannon", "range", 1.5)
		end,
		costFunction = deductXP,
	},
	gaussrange = {
		cmdDesc = {
			id = GetCmdID('PERK_GAUSS_RANGE'),
			action = 'perkgaussrange',
			name = Pad("Gauss"),
			tooltip = '+50% Gauss Weapon Range',
			texture = 'bitmaps/ui/perkbgfaction.png',	
		},
		valid = function (unitDefID) return (hasWeaponClass(unitDefID, "gauss") and isFaction(unitDefID, "la")) end,
		applyPerk = function (unitID) 
			--Spring.Echo("Gauss range selected") 
			setWeaponClassAttribute(unitID, "gauss", "range", 1.5)
		end,
		costFunction = deductXP,
	},
	-- DropShip/Zone upgrades
	drop = {
		cmdDesc = {
			id = GetCmdID('PERK_DROPSHIP_UPGRADE'),
			action = 'perkdropshipupgrade',
			name = Pad("Upgrade", "Dropship"),
			tooltip = 'Increases Tonnage Limit',
			texture = 'bitmaps/ui/perkbg.png',	
		},
		valid = function (unitDefID) return UnitDefs[unitDefID].name:find("dropzone") end,
		applyPerk = function (unitID)
			local teamID = Spring.GetUnitTeam(unitID)
			GG.TeamDropshipUpgrade(teamID)
		end,
		costFunction = deductCBills,
		price = 10000,
	},
}