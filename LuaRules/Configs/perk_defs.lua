-- Use the automatic CMD ID generator
local GetCmdID = GG.CustomCommands.GetCmdID

local modOptions = Spring.GetModOptions()

local EFFECT = modOptions and modOptions.perkeffect or 5
local PCENT_INC = (100+EFFECT)/100
local PCENT_DEC = (100-EFFECT)/100

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
		if className == "all" or (WeaponDefs[weapTable["weaponDef"]].customParams["weaponclass"] == className) then
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
	Spring.UseTeamResource(teamID, "m", Spring.IsNoCostEnabled() and 0 or amount)
end

return {
	-- Weapon
	{
		name = "deadshot",
		cmdDesc = {
			id = GetCmdID('PERK_DEAD_SHOT'),
			action = 'perkdeadshot',
			name = GG.Pad("Dead", "Shot"),
			tooltip = '+' .. EFFECT .. '% weapon accuracy',
			texture = 'bitmaps/ui/perkbgfaction.png',	
		},
		valid = allMechs,
		applyPerk = function (unitID) 
			setWeaponClassAttribute(unitID, "all", "accuracy", PCENT_INC)
		end,
		costFunction = deductXP,
		levels = 3,
	},
	{
		name = "triggerfinger",
		cmdDesc = {
			id = GetCmdID('PERK_TRIGGER_FINGER'),
			action = 'perktriggerfinger',
			name = GG.Pad("Trigger", "Finger"),
			tooltip = '+' .. EFFECT .. '% weapon rate of fire',
			texture = 'bitmaps/ui/perkbgfaction.png',	
		},
		valid = allMechs,
		applyPerk = function (unitID) 
			setWeaponClassAttribute(unitID, "all", "reloadTime", PCENT_DEC)
		end,
		costFunction = deductXP,
		levels = 3,
	},
	{
		name = "firediscipline",
		cmdDesc = {
			id = GetCmdID('PERK_FIRE_DISCIPLINE'),
			action = 'perkfirediscipline',
			name = GG.Pad("Fire", "Discipline"),
			tooltip = '-' .. EFFECT .. '% weapon heat generation',
			texture = 'bitmaps/ui/perkbgfaction.png',	
		},
		valid = allMechs,
		applyPerk = function (unitID) 
			env = Spring.UnitScript.GetScriptEnv(unitID)
			for i = 1, env.numWeapons do
				env.firingHeats[i] = env.firingHeats[i] * PCENT_DEC
			end
		end,
		costFunction = deductXP,
		levels = 3,
	},
	{
		name = "eagleeye",
		cmdDesc = {
			id = GetCmdID('PERK_EAGLE_EYE'),
			action = 'perkeagleeye',
			name = GG.Pad("Eagle", "Eye"),
			tooltip = '+' .. EFFECT .. '% sector view range',
			texture = 'bitmaps/ui/perkbg.png',	
		},
		valid = allMechs,
		applyPerk = function (unitID) 
			GG.SetUnitSectorRadius(unitID, PCENT_INC)
		end,
		costFunction = deductXP,
		levels = 3,
	},
	{
		name = "peakcondition",
		cmdDesc = {
			id = GetCmdID('PERK_PEAK_CONDITION'),
			action = 'perkpeakcondition',
			name = GG.Pad("Peak", "Condition"),
			tooltip = '+' .. EFFECT .. '% turn rate and acceleration',
			texture = 'bitmaps/ui/perkbgability.png',	
		},
		valid = allMechs,
		applyPerk = function (unitID, level) 
			GG.SetUnitTurnRate(unitID, PCENT_INC)
			local ud = UnitDefs[Spring.GetUnitDefID(unitID)]
			local values = {
				turnRate		= ud.turnRate * PCENT_INC ^ level,
				accRate			= ud.maxAcc * PCENT_INC ^ level,
				decRate			= ud.maxDec * PCENT_INC ^ level,
			}
			Spring.MoveCtrl.SetGroundMoveTypeData(unitID, values)
		end,
		costFunction = deductXP,
		levels = 3,
	},
	{
		name = "parkour",
		cmdDesc = {
			id = GetCmdID('PERK_PARKOUR'),
			action = 'perkparkour',
			name = GG.Pad("Parkour!"),
			tooltip = '-1/10th second to jump start delay',
			texture = 'bitmaps/ui/perkbgability.png',	
		},
		valid = hasJumpjets,
		applyPerk = function (unitID) 
			GG.SetUnitJumpDelay(unitID, -10)
		end,
		costFunction = deductXP,
		levels = 3,
	},
	--[[ Generic
	{
		name = "heatefficiency",
		cmdDesc = {
			id = GetCmdID('PERK_HEAT_EFFICIENCY'),
			action = 'perkheatefficiency',
			name = GG.Pad("Heatsinks"),
			tooltip = '+' .. EFFECT .. '% Heat dissipation rate & capacity',
			texture = 'bitmaps/ui/perkbg.png',	
		},
		valid = allMechs,
		applyPerk = function (unitID) 
			--Spring.Echo("Heatsink Dissipation selected") 
			env = Spring.UnitScript.GetScriptEnv(unitID)
			env.baseCoolRate = env.baseCoolRate * PCENT_INC
			env.heatLimit = env.heatLimit * PCENT_INC
			Spring.SetUnitRulesParam(unitID, "heatLimit", env.heatLimit)
		end,
		costFunction = deductXP,
		levels = 3,
	},
	{
		name = "sensorrange",
		cmdDesc = {
			id = GetCmdID('PERK_SENSORS_RANGE'),
			action = 'perksensorsrange',
			name = GG.Pad("Sensors"),
			tooltip = '+' .. EFFECT .. '% Radar and LOS range',
			texture = 'bitmaps/ui/perkbg.png',	
		},
		valid = allMechs,
		applyPerk = function (unitID) 
			--Spring.Echo("Sensor range selected") 
			local currRadar = Spring.GetUnitSensorRadius(unitID, "radar")
			local currLos = Spring.GetUnitSensorRadius(unitID, "los")
			local currAirLos = Spring.GetUnitSensorRadius(unitID, "airLos")
			Spring.SetUnitSensorRadius(unitID, "radar", currRadar * PCENT_INC)
			Spring.SetUnitSensorRadius(unitID, "los", currLos * PCENT_INC)
			Spring.SetUnitSensorRadius(unitID, "airLos", currAirLos * PCENT_INC)
			if hasBAP(Spring.GetUnitDefID(unitID)) then
				GG.allyBAPs[Spring.GetUnitAllyTeam(unitID)][unitID] = currRadar * PCENT_INC
			end
		end,
		costFunction = deductXP,
		levels = 3,
	},
	-- Ability modifiers
	{
		name = "narcduration",
		cmdDesc = {
			id = GetCmdID('PERK_NARC_DURATION'),
			action = 'perknarkduration',
			name = GG.Pad("NARC"),
			tooltip = '+' .. EFFECT .. '% NARC duration',
			texture = 'bitmaps/ui/perkbgability.png',	
		},
		valid = function (unitDefID) return allMechs(unitDefID) and hasWeaponName(unitDefID, "NARC") end,
		applyPerk = function (unitID) 
			--Spring.Echo("Sensor range selected") 
			local currDuration = Spring.GetUnitRulesParam(unitID, "NARC_DURATION") or Spring.GetGameRulesParam("NARC_DURATION")
			Spring.SetUnitRulesParam(unitID, "NARC_DURATION", currDuration * PCENT_INC)
		end,
		costFunction = deductXP,
		levels = 3,
	},
	{
		name = "jumpjetefficiency",
		cmdDesc = {
			id = GetCmdID('PERK_JUMP_EFFICIENCY'),
			action = 'perkjumpjetefficiency',
			name = GG.Pad("Jumpjets"),
			tooltip = '+' .. EFFECT .. '% Jump range, speed & reload',
			texture = 'bitmaps/ui/perkbgability.png',	
		},
		valid = hasJumpjets,
		applyPerk = function (unitID) 
			--Spring.Echo("Extended Range Jumpjets selected") 
			local currRange = Spring.GetUnitRulesParam(unitID, "jumpRange")
			local currSpeed = Spring.GetUnitRulesParam(unitID, "jumpSpeed")
			local currReload = Spring.GetUnitRulesParam(unitID, "jumpReload")
			Spring.SetUnitRulesParam(unitID, "jumpRange", currRange * PCENT_INC)
			Spring.SetUnitRulesParam(unitID, "jumpSpeed", currSpeed * PCENT_INC)
			Spring.SetUnitRulesParam(unitID, "jumpReload", currReload * PCENT_DEC)
		end,
		costFunction = deductXP,
		levels = 3,
	},
	{
		name = "mascefficiency",
		cmdDesc = {
			id = GetCmdID('PERK_MASC_EFFICIENCY'),
			action = 'perkmascefficiency',
			name = GG.Pad("MASC"),
			tooltip = '-' .. EFFECT .. '% MASC heat generation',
			texture = 'bitmaps/ui/perkbgability.png',	
		},
		valid = hasMASC,
		applyPerk = function (unitID) 
			--Spring.Echo("MASC heat reduction selected") 
			env = Spring.UnitScript.GetScriptEnv(unitID)
			env.mascHeatRate = env.mascHeatRate * PCENT_DEC
		end,
		costFunction = deductXP,
		levels = 3,
	},
	{
		name = "amsrange",
		cmdDesc = {
			id = GetCmdID('PERK_AMS_RANGE'),
			action = 'perkamsrange',
			name = GG.Pad("AMS"),
			tooltip = '+' .. EFFECT .. '% AMS Weapon Range',
			texture = 'bitmaps/ui/perkbgability.png',	
		},
		valid = function (unitDefID) return allMechs(unitDefID) and hasWeaponClass(unitDefID, "ams") end,
		applyPerk = function (unitID) 
			--Spring.Echo("Projectile range selected") 
			setWeaponClassAttribute(unitID, "ams", "range", PCENT_INC)
		end,
		costFunction = deductXP,
		levels = 3,
	},
	{
		name = "ecmrange",
		cmdDesc = {
			id = GetCmdID('PERK_ECM_RANGE'),
			action = 'perkecmrange',
			name = GG.Pad("ECM"),
			tooltip = '+' .. EFFECT .. '% ECM range',
			texture = 'bitmaps/ui/perkbgability.png',	
		},
		valid = function (unitDefID) return (allMechs(unitDefID) and hasECM(unitDefID) and isFaction(unitDefID, "cc")) end,
		applyPerk = function (unitID) 
			--Spring.Echo("ECM range selected") 
			local currECM = Spring.GetUnitSensorRadius(unitID, "radarJammer")
			Spring.SetUnitSensorRadius(unitID, "radarJammer", currECM * PCENT_INC)
			GG.allyJammers[Spring.GetUnitAllyTeam(unitID)][unitID] = currECM * PCENT_INC
		end,
		costFunction = deductXP,
		levels = 3,
	},
	{
		name = "insulation",
		cmdDesc = {
			id = GetCmdID('PERK_INSULATED_ELECTRONICS'),
			action = 'perkinsulatedelectronics',
			name = GG.Pad("Insulated", "Electronics"),
			tooltip = '-' .. EFFECT .. '% PPC disruption time',
			texture = 'bitmaps/ui/perkbgability.png',	
		},
		valid = function (unitDefID) return (allMechs(unitDefID) and hasECM(unitDefID) or hasBAP(unitDefID)) end,
		applyPerk = function (unitID) 
			--Spring.Echo("Insulated Electronics selected") 
			Spring.SetUnitRulesParam(unitID, "insulation", PCENT_DEC)
		end,
		costFunction = deductXP,
		levels = 3,
	},
	-- Weapon (Faction) specific
	{
		name = "lrmrange",
		cmdDesc = {
			id = GetCmdID('PERK_LRM_RANGE'),
			action = 'perklrmrange',
			name = GG.Pad("LRM"),
			tooltip = '+' .. EFFECT .. '% LRM Range',
			texture = 'bitmaps/ui/perkbgfaction.png',	
		},
		valid = function (unitDefID) return (allMechs(unitDefID) and hasWeaponClass(unitDefID, "lrm") and isFaction(unitDefID, "fw")) end,
		applyPerk = function (unitID) 
			--Spring.Echo("Missile range selected") 
			setWeaponClassAttribute(unitID, "lrm", "range", PCENT_INC)
		end,
		costFunction = deductXP,
		levels = 3,
	},
	{
		name = "mrmrange",
		cmdDesc = {
			id = GetCmdID('PERK_MRM_RANGE'),
			action = 'perkmrmrange',
			name = GG.Pad("MRM"),
			tooltip = '+' .. EFFECT .. '% MRM Range',
			texture = 'bitmaps/ui/perkbgfaction.png',	
		},
		valid = function (unitDefID) return (allMechs(unitDefID) and hasWeaponClass(unitDefID, "mrm") and isFaction(unitDefID, "dc")) end,
		applyPerk = function (unitID) 
			--Spring.Echo("Missile range selected") 
			setWeaponClassAttribute(unitID, "mrm", "range", PCENT_INC)
		end,
		costFunction = deductXP,
		levels = 3,
	},
	{
		name = "ppcrange",
		cmdDesc = {
			id = GetCmdID('PERK_PPC_RANGE'),
			action = 'perkppcrange',
			name = GG.Pad("PPC"),
			tooltip = '+' .. EFFECT .. '% PPC Weapon Range',
			texture = 'bitmaps/ui/perkbgfaction.png',	
		},
		valid = function (unitDefID) return (allMechs(unitDefID) and hasWeaponClass(unitDefID, "ppc") and isFaction(unitDefID, "dc")) end,
		applyPerk = function (unitID) 
			--Spring.Echo("PPC range selected") 
			setWeaponClassAttribute(unitID, "ppc", "range", PCENT_INC)
		end,
		costFunction = deductXP,
		levels = 3,
	},
	{
		name = "autocannonrange",
		cmdDesc = {
			id = GetCmdID('PERK_AUTOCANNON_RANGE'),
			action = 'perkautocannonrange',
			name = GG.Pad("Autocannon"),
			tooltip = '+' .. EFFECT .. '% Autocannon Weapon Range',
			texture = 'bitmaps/ui/perkbgfaction.png',	
		},
		valid = function (unitDefID) return (allMechs(unitDefID) and hasWeaponClass(unitDefID, "autocannon") and isFaction(unitDefID, "fs")) end,
		applyPerk = function (unitID) 
			--Spring.Echo("Autocannon range selected") 
			setWeaponClassAttribute(unitID, "autocannon", "range", PCENT_INC)
		end,
		costFunction = deductXP,
		levels = 3,
	},
	{
		name = "gaussrange",
		cmdDesc = {
			id = GetCmdID('PERK_GAUSS_RANGE'),
			action = 'perkgaussrange',
			name = GG.Pad("Gauss"),
			tooltip = '+' .. EFFECT .. '% Gauss Weapon Range',
			texture = 'bitmaps/ui/perkbgfaction.png',	
		},
		valid = function (unitDefID) return (allMechs(unitDefID) and hasWeaponClass(unitDefID, "gauss") and isFaction(unitDefID, "la")) end,
		applyPerk = function (unitID) 
			--Spring.Echo("Gauss range selected") 
			setWeaponClassAttribute(unitID, "gauss", "range", PCENT_INC)
		end,
		costFunction = deductXP,
		levels = 3,
	},]]
	-- Dropship Upgrades
	{
		name = "union",
		cmdDesc = {
			id = GetCmdID('CMD_DROPZONE_2'),
			action = 'perkdropshipupgradeunion',
			name = GG.Pad("Union", "Dropship"),
			tooltip = 'Unlocks Heavy & Assault mechs. Increases Tonnage Limit',
			texture = 'unitpics/Dropship_Union.png',	
		},
		valid = function (unitDefID) return UnitDefs[unitDefID].name:find("dropzone") end,
		applyPerk = function (unitID)
			local teamID = Spring.GetUnitTeam(unitID)
			GG.DropZoneUpgrade(teamID)
		end,
		costFunction = deductCBills,
		price = 39620,
	},
	{
		name = "overlord",
			cmdDesc = {
			id = GetCmdID('CMD_DROPZONE_3'),
			action = 'perkdropshipupgradeoverlord',
			name = GG.Pad("Overlord", "Dropship"),
			tooltip = 'Further Increases Tonnage Limit',
			texture = 'unitpics/Dropship_Overlord.png',
		},
		valid = function (unitDefID) return UnitDefs[unitDefID].name:find("dropzone") end,
		applyPerk = function (unitID)
			local teamID = Spring.GetUnitTeam(unitID)
			GG.DropZoneUpgrade(teamID)
		end,
		costFunction = deductCBills,
		price = 47020,
		requires = "union",
	},
	-- vehicle pad
	{
		name = "vpadheavy",
		cmdDesc = {
			id = GetCmdID('PERK_VPAD_2'),
			action = 'perkvpadheavy',
			name = GG.Pad("Heavy", "Units"),
			tooltip = 'Adds heavy units to the militia, increases chance of medium units',
			texture = 'bitmaps/ui/upgrade.png',	
		},
		valid = function (unitDefID) return (not GG.hoverMap) and UnitDefs[unitDefID].name:find("vehiclepad") end,
		applyPerk = function (unitID)
			GG.PadUpgrade(unitID, 2)
		end,
		costFunction = deductCBills,
		price = 8000,
	},
	{
		name = "vpadhouse",
		cmdDesc = {
			id = GetCmdID('PERK_VPAD_3'),
			action = 'perkvpadhouse',
			name = GG.Pad("Assault", "Units"),
			tooltip = 'Adds assault units to the militia, increases chance of heavy units',
			texture = 'bitmaps/ui/upgrade.png',	
		},
		valid = function (unitDefID) return (not GG.hoverMap) and UnitDefs[unitDefID].name:find("vehiclepad") end,
		applyPerk = function (unitID)
			GG.PadUpgrade(unitID, 3)
		end,
		costFunction = deductCBills,
		price = 12000,
		requires = "vpadheavy",
	},
	-- hover pad
	{
		name = "hpad2",
		cmdDesc = {
			id = GetCmdID('PERK_HPAD_2'),
			action = 'perkhpad2',
			name = GG.Pad("Medium", "Units"),
			tooltip = 'Adds medium units to the militia, increases chance of APC units',
			texture = 'bitmaps/ui/upgrade.png',	
		},
		valid = function (unitDefID) return (GG.hoverMap) and UnitDefs[unitDefID].name:find("vehiclepad") end,
		applyPerk = function (unitID)
			GG.PadUpgrade(unitID, 2)
		end,
		costFunction = deductCBills,
		price = 7000,
	},
	{
		name = "hpad3",
		cmdDesc = {
			id = GetCmdID('PERK_HPAD_3'),
			action = 'perkhpad3',
			name = GG.Pad("VTOL", "Units"),
			tooltip = 'Adds VTOL units to the militia, increases chance of medium units',
			texture = 'bitmaps/ui/upgrade.png',	
		},
		valid = function (unitDefID) return (GG.hoverMap) and UnitDefs[unitDefID].name:find("vehiclepad") end,
		applyPerk = function (unitID)
			GG.PadUpgrade(unitID, 3)
		end,
		costFunction = deductCBills,
		price = 10000,
		requires = "hpad2",
	},
	-- Garrison 
	{
		name = "garrisonlaser",
		cmdDesc = {
			id = GetCmdID('PERK_GARRISON_2'),
			action = 'perkgarrisonlaser',
			name = GG.Pad("Defensive", "Lasers"),
			tooltip = 'Opens firing ports for lasers (-20% damage resistance)',
			texture = 'bitmaps/ui/upgrade.png',	
		},
		valid = function (unitDefID) return UnitDefs[unitDefID].name == "outpost_garrison" end,
		applyPerk = function (unitID)
			env = Spring.UnitScript.GetScriptEnv(unitID)
			env.noFiring = false
			Spring.SetUnitArmored(unitID, true, 0.8)
		end,
		costFunction = deductCBills,
		price = 6000,
	},
	{
		name = "garrisonfaction",
		cmdDesc = {
			id = GetCmdID('PERK_GARRISON_3'),
			action = 'perkgarrisonphat',
			name = GG.Pad("Extra", "Armour"),
			tooltip = 'Adds additional armour (+100% damage resistance)',
			texture = 'bitmaps/ui/upgrade.png',	
		},
		valid = function (unitDefID) return UnitDefs[unitDefID].name:find("garrison") end,
		applyPerk = function (unitID)
			--local x,y,z = Spring.GetUnitPosition(unitID)
			--local faction = GG.teamSide[Spring.GetUnitTeam(unitID)]
			--local turretID = Spring.CreateUnit("garrison_" .. faction, x,y,z, 0, Spring.GetUnitTeam(unitID))
			--Spring.UnitAttach(unitID, turretID, 8)
			Spring.SetUnitArmored(unitID, true, 2)
		end,
		costFunction = deductCBills,
		price = 12000,
		requires = "garrisonlaser",
	},
	-- Uplink
	{
		name = "uplink_2",
		cmdDesc = {
			id = GetCmdID('PERK_UPLINK_2'),
			action = 'perkuplink_2',
			name = GG.Pad("Aero", "Sortie"),
			tooltip = 'Unlock Aero fighter sorties',
			texture = 'unitpics/Sortie_Attack.png',	
		},
		valid = function (unitDefID) return UnitDefs[unitDefID].name == "outpost_uplink" end,
		applyPerk = function (unitID)
			GG.UplinkUpgrade(unitID, 2)
		end,
		costFunction = deductCBills,
		price = 35000,
	},
	{
		name = "uplink_3",
		cmdDesc = {
			id = GetCmdID('PERK_UPLINK_3'),
			action = 'perkuplink_3',
			name = GG.Pad("Assault", "Dropship"),
			tooltip = 'Unlock Assault dropship attack run',
			texture = 'unitpics/Dropship_Avenger.png',	
		},
		valid = function (unitDefID) return UnitDefs[unitDefID].name == "outpost_uplink" end,
		applyPerk = function (unitID)
			GG.UplinkUpgrade(unitID, 3)
		end,
		costFunction = deductCBills,
		price = 52000,
		requires = "uplink_2",
	},
	-- Turret Control
	{
		name = "turretcontrol_2",
		cmdDesc = {
			id = GetCmdID('PERK_TURRETCONTROL_2'),
			action = 'perkturretcontrol_2',
			name = GG.Pad("Energy", "Weapon", "Towers"),
			tooltip = 'Unlocks towers with energy weapons (no ammo limits)',
			texture = 'bitmaps/ui/upgrade.png',	
		},
		valid = function (unitDefID) return UnitDefs[unitDefID].name == "outpost_turretcontrol" end,
		applyPerk = function (unitID)
			GG.LimitTowerType(unitID, Spring.GetUnitTeam(unitID), "energy", 2)
		end,
		costFunction = deductCBills,
		price = 6000,
	},
	{
		name = "turretcontrol_3",
		cmdDesc = {
			id = GetCmdID('PERK_TURRETCONTROL_3'),
			action = 'perkturretcontrol_3',
			name = GG.Pad("Long","Range", "Towers"),
			tooltip = 'Unlocks LRM and Sniper Artillery towers',
			texture = 'bitmaps/ui/upgrade.png',	
		},
		valid = function (unitDefID) return UnitDefs[unitDefID].name == "outpost_turretcontrol" end,
		applyPerk = function (unitID)
			GG.LimitTowerType(unitID, Spring.GetUnitTeam(unitID), "ranged", 2)
		end,
		costFunction = deductCBills,
		price = 12000,
		requires = "turretcontrol_2",
	},
	-- Seismic Sensor
	{
		name = "seismic_2",
		cmdDesc = {
			id = GetCmdID('PERK_SEISMIC_2'),
			action = 'perkseismic_2',
			name = GG.Pad("Increase", "Range"),
			tooltip = 'Increases the range of the seismic sensor +50% (+10% time between pings)',
			texture = 'bitmaps/ui/upgrade.png',	
		},
		valid = function (unitDefID) return UnitDefs[unitDefID].name == "outpost_seismic" end,
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
			name = GG.Pad("Increase", "Duration"),
			tooltip = 'Increases the duration of each ping +250% (+20% time between pings)',
			texture = 'bitmaps/ui/upgrade.png',	
		},
		valid = function (unitDefID) return UnitDefs[unitDefID].name == "outpost_seismic" end,
		applyPerk = function (unitID)
			env = Spring.UnitScript.GetScriptEnv(unitID)
			env.seismicDuration = env.seismicDuration * 2.5
			env.seismicDelay = env.seismicDelay * 1.2
		end,
		costFunction = deductCBills,
		price = 8000,
	},
}