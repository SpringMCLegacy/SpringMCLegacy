-- Use the automatic CMD ID generator
local GetCmdID = GG.CustomCommands.GetCmdID

local PAD_LENGTH = 12

local function PadString(input)
	while input:len() < PAD_LENGTH do
		input = " " .. input .. " "
	end
	return input
end
local function Pad(...)
	local arg = {...}
	local output = ""
	for i, v in ipairs(arg) do
		output = output .. PadString(v) .. "\n"
	end
	return output:sub(1,-2) -- remove trailing newline
end

-- Common valid() functions here:
local function allMechs(unitDefID) return (UnitDefs[unitDefID].customParams.baseclass == "mech") end
local function hasJumpjets(unitDefID) return (UnitDefs[unitDefID].customParams.jumpjets or false) end
local function hasMASC(unitDefID) return (allMechs(unitDefID) and UnitDefs[unitDefID].customParams.masc or false) end
local function hasECM(unitDefID) return (allMechs(unitDefID) and UnitDefs[unitDefID].customParams.ecm or false) end
local function hasBAP(unitDefID) return (allMechs(unitDefID) and UnitDefs[unitDefID].customParams.bap or false) end
local function isFaction(unitDefID, faction) return (allMechs(unitDefID) and UnitDefs[unitDefID].name:sub(1,2) == faction) end

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
	{
		name = "heatefficiency",
		cmdDesc = {
			id = GetCmdID('PERK_HEAT_EFFICIENCY'),
			action = 'perkheatefficiency',
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
	{
		name = "sensorrange",
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
	{
		name = "narcduration",
		cmdDesc = {
			id = GetCmdID('PERK_NARC_DURATION'),
			action = 'perknarkduration',
			name = Pad("NARC"),
			tooltip = '+50% NARC duration',
			texture = 'bitmaps/ui/perkbgability.png',	
		},
		valid = function (unitDefID) return allMechs(unitDefID) and hasWeaponName(unitDefID, "NARC") end,
		applyPerk = function (unitID) 
			--Spring.Echo("Sensor range selected") 
			local currDuration = Spring.GetUnitRulesParam(unitID, "NARC_DURATION") or Spring.GetGameRulesParam("NARC_DURATION")
			Spring.SetUnitRulesParam(unitID, "NARC_DURATION", currDuration * 1.5)
		end,
		costFunction = deductXP,
	},
	{
		name = "jumpjetefficiency",
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
	{
		name = "mascefficiency",
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
	{
		name = "amsrange",
		cmdDesc = {
			id = GetCmdID('PERK_AMS_RANGE'),
			action = 'perkamsrange',
			name = Pad("AMS"),
			tooltip = '+50% AMS Weapon Range',
			texture = 'bitmaps/ui/perkbgability.png',	
		},
		valid = function (unitDefID) return allMechs(unitDefID) and hasWeaponClass(unitDefID, "ams") end,
		applyPerk = function (unitID) 
			--Spring.Echo("Projectile range selected") 
			setWeaponClassAttribute(unitID, "ams", "range", 1.5)
		end,
		costFunction = deductXP,
	},
	{
		name = "ecmrange",
		cmdDesc = {
			id = GetCmdID('PERK_ECM_RANGE'),
			action = 'perkecmrange',
			name = Pad("ECM"),
			tooltip = '+50% ECM range',
			texture = 'bitmaps/ui/perkbgability.png',	
		},
		valid = function (unitDefID) return (allMechs(unitDefID) and hasECM(unitDefID) and isFaction(unitDefID, "cc")) end,
		applyPerk = function (unitID) 
			--Spring.Echo("ECM range selected") 
			local currECM = Spring.GetUnitSensorRadius(unitID, "radarJammer")
			Spring.SetUnitSensorRadius(unitID, "radarJammer", currECM * 1.5)
			GG.allyJammers[Spring.GetUnitAllyTeam(unitID)][unitID] = currECM * 1.5
		end,
		costFunction = deductXP,
	},
	{
		name = "insulation",
		cmdDesc = {
			id = GetCmdID('PERK_INSULATED_ELECTRONICS'),
			action = 'perkinsulatedelectronics',
			name = Pad("Insulated", "Electronics"),
			tooltip = '-50% PPC disruption time',
			texture = 'bitmaps/ui/perkbgability.png',	
		},
		valid = function (unitDefID) return (allMechs(unitDefID) and hasECM(unitDefID) or hasBAP(unitDefID)) end,
		applyPerk = function (unitID) 
			--Spring.Echo("Insulated Electronics selected") 
			Spring.SetUnitRulesParam(unitID, "insulation", 0.5)
		end,
		costFunction = deductXP,
	},
	-- Weapon (Faction) specific
	{
		name = "lrmrange",
		cmdDesc = {
			id = GetCmdID('PERK_LRM_RANGE'),
			action = 'perklrmrange',
			name = Pad("LRM"),
			tooltip = '+50% LRM Range',
			texture = 'bitmaps/ui/perkbgfaction.png',	
		},
		valid = function (unitDefID) return (allMechs(unitDefID) and hasWeaponClass(unitDefID, "lrm") and isFaction(unitDefID, "fw")) end,
		applyPerk = function (unitID) 
			--Spring.Echo("Missile range selected") 
			setWeaponClassAttribute(unitID, "lrm", "range", 1.5)
		end,
		costFunction = deductXP,
	},
	{
		name = "mrmrange",
		cmdDesc = {
			id = GetCmdID('PERK_MRM_RANGE'),
			action = 'perkmrmrange',
			name = Pad("MRM"),
			tooltip = '+50% MRM Range',
			texture = 'bitmaps/ui/perkbgfaction.png',	
		},
		valid = function (unitDefID) return (allMechs(unitDefID) and hasWeaponClass(unitDefID, "mrm") and isFaction(unitDefID, "dc")) end,
		applyPerk = function (unitID) 
			--Spring.Echo("Missile range selected") 
			setWeaponClassAttribute(unitID, "mrm", "range", 1.5)
		end,
		costFunction = deductXP,
	},
	{
		name = "ppcrange",
		cmdDesc = {
			id = GetCmdID('PERK_PPC_RANGE'),
			action = 'perkppcrange',
			name = Pad("PPC"),
			tooltip = '+50% PPC Weapon Range',
			texture = 'bitmaps/ui/perkbgfaction.png',	
		},
		valid = function (unitDefID) return (allMechs(unitDefID) and hasWeaponClass(unitDefID, "ppc") and isFaction(unitDefID, "dc")) end,
		applyPerk = function (unitID) 
			--Spring.Echo("PPC range selected") 
			setWeaponClassAttribute(unitID, "ppc", "range", 1.5)
		end,
		costFunction = deductXP,
	},
	{
		name = "autocannonrange",
		cmdDesc = {
			id = GetCmdID('PERK_AUTOCANNON_RANGE'),
			action = 'perkautocannonrange',
			name = Pad("Autocannon"),
			tooltip = '+50% Autocannon Weapon Range',
			texture = 'bitmaps/ui/perkbgfaction.png',	
		},
		valid = function (unitDefID) return (allMechs(unitDefID) and hasWeaponClass(unitDefID, "autocannon") and isFaction(unitDefID, "fs")) end,
		applyPerk = function (unitID) 
			--Spring.Echo("Autocannon range selected") 
			setWeaponClassAttribute(unitID, "autocannon", "range", 1.5)
		end,
		costFunction = deductXP,
	},
	{
		name = "gaussrange",
		cmdDesc = {
			id = GetCmdID('PERK_GAUSS_RANGE'),
			action = 'perkgaussrange',
			name = Pad("Gauss"),
			tooltip = '+50% Gauss Weapon Range',
			texture = 'bitmaps/ui/perkbgfaction.png',	
		},
		valid = function (unitDefID) return (allMechs(unitDefID) and hasWeaponClass(unitDefID, "gauss") and isFaction(unitDefID, "la")) end,
		applyPerk = function (unitID) 
			--Spring.Echo("Gauss range selected") 
			setWeaponClassAttribute(unitID, "gauss", "range", 1.5)
		end,
		costFunction = deductXP,
	},
	-- Upgrades
	{
		name = "union",
		cmdDesc = {
			id = GetCmdID('CMD_DROPZONE_2'),
			action = 'perkdropshipupgradeunion',
			name = Pad("Union", "Dropship"),
			tooltip = 'Increases Tonnage Limit',
			texture = 'bitmaps/ui/upgrade.png',	
		},
		valid = function (unitDefID) return UnitDefs[unitDefID].name:find("dropzone") end,
		applyPerk = function (unitID)
			local teamID = Spring.GetUnitTeam(unitID)
			GG.TeamDropshipUpgrade(teamID)
		end,
		costFunction = deductCBills,
		price = 10000,
	},
	{
		name = "overlord",
			cmdDesc = {
			id = GetCmdID('CMD_DROPZONE_3'),
			action = 'perkdropshipupgradeoverlord',
			name = Pad("Overlord", "Dropship"),
			tooltip = 'Increases Tonnage Limit',
			texture = 'bitmaps/ui/upgrade.png',
		},
		valid = function (unitDefID) return UnitDefs[unitDefID].name:find("dropzone") end,
		applyPerk = function (unitID)
			local teamID = Spring.GetUnitTeam(unitID)
			GG.TeamDropshipUpgrade(teamID)
		end,
		costFunction = deductCBills,
		price = 10000,
		requires = "union",
	},
	-- vehicle pad
	{
		name = "vpadheavy",
		cmdDesc = {
			id = GetCmdID('PERK_VPAD_2'),
			action = 'perkvpadheavy',
			name = Pad("Heavy", "Units"),
			tooltip = 'Adds heavy units to the militia, increases chance of medium units',
			texture = 'bitmaps/ui/upgrade.png',	
		},
		valid = function (unitDefID) return UnitDefs[unitDefID].name:find("vehiclepad") end,
		applyPerk = function (unitID)
			GG.VPadUpgrade(unitID, 2)
		end,
		costFunction = deductCBills,
		price = 10000,
	},
	{
		name = "vpadhouse",
		cmdDesc = {
			id = GetCmdID('PERK_VPAD_3'),
			action = 'perkvpadhouse',
			name = Pad("Assault", "Units"),
			tooltip = 'Adds assault units to the militia, increases chance of heavy units',
			texture = 'bitmaps/ui/upgrade.png',	
		},
		valid = function (unitDefID) return UnitDefs[unitDefID].name:find("vehiclepad") end,
		applyPerk = function (unitID)
			GG.VPadUpgrade(unitID, 3)
		end,
		costFunction = deductCBills,
		price = 10000,
		requires = "vpadheavy",
	},
	-- Garrison 
	{
		name = "garrisonlaser",
		cmdDesc = {
			id = GetCmdID('PERK_GARRISON_2'),
			action = 'perkgarrisonlaser',
			name = Pad("Defensive", "Lasers"),
			tooltip = 'Opens firing ports for lasers (-20% damage resistance)',
			texture = 'bitmaps/ui/upgrade.png',	
		},
		valid = function (unitDefID) return UnitDefs[unitDefID].name == "upgrade_garrison" end,
		applyPerk = function (unitID)
			env = Spring.UnitScript.GetScriptEnv(unitID)
			env.noFiring = false
			Spring.SetUnitArmored(unitID, true, 0.8)
		end,
		costFunction = deductCBills,
		price = 8000,
	},
	{
		name = "garrisonfaction",
		cmdDesc = {
			id = GetCmdID('PERK_GARRISON_3'),
			action = 'perkgarrisonfaction',
			name = Pad("Faction", "Turret"),
			tooltip = 'Adds a powerful faction special weapon turret (-30% damage resistance)',
			texture = 'bitmaps/ui/upgrade.png',	
		},
		valid = function (unitDefID) return UnitDefs[unitDefID].name:find("garrison") end,
		applyPerk = function (unitID)
			local x,y,z = Spring.GetUnitPosition(unitID)
			local faction = GG.teamSide[Spring.GetUnitTeam(unitID)]
			local turretID = Spring.CreateUnit("garrison_" .. faction, x,y,z, 0, Spring.GetUnitTeam(unitID))
			Spring.UnitAttach(unitID, turretID, 8)
			Spring.SetUnitArmored(unitID, true, 0.7)
		end,
		costFunction = deductCBills,
		price = 10000,
		requires = "garrisonlaser",
	},
	-- Uplink
	{
		name = "uplink_2",
		cmdDesc = {
			id = GetCmdID('PERK_UPLINK_2'),
			action = 'perkuplink_2',
			name = Pad("Naval", "PPC"),
			tooltip = 'Upgrade to Naval PPC weapon (+25s cooldown)',
			texture = 'bitmaps/ui/upgrade.png',	
		},
		valid = function (unitDefID) return UnitDefs[unitDefID].name == "upgrade_uplink" end,
		applyPerk = function (unitID)
			GG.UplinkUpgrade(unitID, 2)
		end,
		costFunction = deductCBills,
		price = 8000,
	},
	{
		name = "uplink_3",
		cmdDesc = {
			id = GetCmdID('PERK_UPLINK_3'),
			action = 'perkuplink_3',
			name = Pad("Naval", "AC/40"),
			tooltip = 'Upgrade to Naval Autocannon 40 weapon (+15s cooldown)',
			texture = 'bitmaps/ui/upgrade.png',	
		},
		valid = function (unitDefID) return UnitDefs[unitDefID].name == "upgrade_uplink" end,
		applyPerk = function (unitID)
			GG.UplinkUpgrade(unitID, 3)
		end,
		costFunction = deductCBills,
		price = 8000,
		requires = "uplink_2",
	},
	-- Turret Control
	{
		name = "turretcontrol_2",
		cmdDesc = {
			id = GetCmdID('PERK_TURRETCONTROL_2'),
			action = 'perkturretcontrol_2',
			name = Pad("Increase", "Limit"),
			tooltip = 'Increases the number of turrets suppported',
			texture = 'bitmaps/ui/upgrade.png',	
		},
		valid = function (unitDefID) return UnitDefs[unitDefID].name == "upgrade_turretcontrol" end,
		applyPerk = function (unitID)
			GG.LimitTowerType(unitID, Spring.GetUnitTeam(unitID), "turret", 4)
		end,
		costFunction = deductCBills,
		price = 8000,
	},
	{
		name = "turretcontrol_3",
		cmdDesc = {
			id = GetCmdID('PERK_TURRETCONTROL_3'),
			action = 'perkturretcontrol_3',
			name = Pad("Sensor", "Towers"),
			tooltip = 'Unlocks sensor towers',
			texture = 'bitmaps/ui/upgrade.png',	
		},
		valid = function (unitDefID) return UnitDefs[unitDefID].name == "upgrade_turretcontrol" end,
		applyPerk = function (unitID)
			GG.LimitTowerType(unitID, Spring.GetUnitTeam(unitID), "sensor", 2)
		end,
		costFunction = deductCBills,
		price = 8000,
		requires = "turretcontrol_2",
	},
	-- Seismic Sensor
	{
		name = "seismic_2",
		cmdDesc = {
			id = GetCmdID('PERK_SEISMIC_2'),
			action = 'perkseismic_2',
			name = Pad("Increase", "Range"),
			tooltip = 'Increases the range of the seismic sensor +50% (+10% time between pings)',
			texture = 'bitmaps/ui/upgrade.png',	
		},
		valid = function (unitDefID) return UnitDefs[unitDefID].name == "upgrade_seismic" end,
		applyPerk = function (unitID)
			env = Spring.UnitScript.GetScriptEnv(unitID)
			env.seismicRange = env.seismicRange * 1.5
			env.seismicDelay = env.seismicDelay * 1.1
		end,
		costFunction = deductCBills,
		price = 8000,
	},
	{
		name = "seismic_3",
		cmdDesc = {
			id = GetCmdID('PERK_SEISMIC_3'),
			action = 'perkseismic_3',
			name = Pad("Increase", "Duration"),
			tooltip = 'Increases the duration of each ping +250% (+20% time between pings)',
			texture = 'bitmaps/ui/upgrade.png',	
		},
		valid = function (unitDefID) return UnitDefs[unitDefID].name == "upgrade_seismic" end,
		applyPerk = function (unitID)
			env = Spring.UnitScript.GetScriptEnv(unitID)
			env.seismicDuration = env.seismicDuration * 2.5
			env.seismicDelay = env.seismicDelay * 1.2
		end,
		costFunction = deductCBills,
		price = 8000,
	},
}