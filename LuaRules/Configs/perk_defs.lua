-- Use the automatic CMD ID generator
local GetCmdID = GG.CustomCommands.GetCmdID
local EMPTY = {}
local modOptions = Spring.GetModOptions()

local NUM_DAMAGE_TYPES = 0
for damageType in pairs(GG.GameConstants.damageMults) do
	NUM_DAMAGE_TYPES = NUM_DAMAGE_TYPES + 1
end

local MOD_COST_MULT = modOptions and modOptions.modcostmult or 1.0
local PERK_XP_COST = 1.0 -- 1.5
GG.PERK_XP_COST = PERK_XP_COST
local EFFECT = modOptions and modOptions.perkeffect or 5
local PCENT_INC = (100+EFFECT)/100
local PCENT_DEC = (100-EFFECT)/100

local AmmoTypes = {}
for k, v in pairs(GG.GameConstants.ammoTypes) do
	AmmoTypes[string.lower(k)] = v
end

-- Common valid() functions
local function allMechs(unitDefID) return (UnitDefs[unitDefID].customParams.baseclass == "mech") end
local function hasJumpjets(unitDefID) return (UnitDefs[unitDefID].customParams.jumpjets or false) end
local function hasMASC(unitDefID) return (allMechs(unitDefID) and UnitDefs[unitDefID].customParams.masc or false) end
local function hasECM(unitDefID) return (allMechs(unitDefID) and UnitDefs[unitDefID].customParams.ecm or false) end
local function hasBAP(unitDefID) return (allMechs(unitDefID) and UnitDefs[unitDefID].customParams.bap or false) end
local function hasPrebuilt(unitDefID, modName) return (allMechs(unitDefID) and string.find(UnitDefs[unitDefID].customParams.mods or "", modName) ~= nil) end
local function isFaction(unitDefID, faction) return (allMechs(unitDefID) and UnitDefs[unitDefID].name:sub(1,2) == faction) end
local function isOmni(unitDefID) return (allMechs(unitDefID) and UnitDefs[unitDefID].customParams.omni) end
local function isNotOmni(unitDefID) return not isOmni(unitDefID) end

local function isMechBay(unitDefID) return (UnitDefs[unitDefID].name == "outpost_mechbay") end

-- Common applyTo() functions
local function hasWeaponName(unitDefID, weapName)
	local weapons = UnitDefs[unitDefID].weapons
	local found
	for weapNum, weapTable in pairs(weapons) do 
		local wd = WeaponDefNames[weapName:lower()]
		if weapTable["weaponDef"] == wd.id then 
			if not found then found = {} end
			found[weapNum] = wd
		end
	end
	if found then
		return true, found
	end
	return false
end

local function hasWeaponClass(unitDefID, className, tag, with, value, custom) -- projectile, energy, missile
	local weapons = UnitDefs[unitDefID].weapons
	for weapNum, weapTable in pairs(weapons) do 
		local wd = WeaponDefs[weapTable["weaponDef"]]
		local cp = wd.customParams
		if cp["weaponclass"] == className then 
			if not tag then
				return true
			elseif tag and wd[tag] and not value then -- has tag, not looking for a value
				return true
			elseif tag and custom and cp[tag] then -- has customParam
				if not (with and value) then return true end -- not looking for a value
				return with and (cp[tag] == value) -- looking for a value
			elseif with and wd[tag] and wd[tag] == value then -- has tag with specific value
				--Spring.Echo(UnitDefs[unitDefID].name, "has weapon class", className, "(", wd.name, ") with", tag, "value", value)
				return true
			elseif not with and not (wd[tag] == value) then -- has tag WITHOUT specific value
				--Spring.Echo(UnitDefs[unitDefID].name, "has weapon class", className, "(", wd.name, ") without", tag, "value", value)
				return true
			end
		end
	end
	return false
end	

-- Common apply() functions
local function noOp(unitID) end

local function setWeaponClassAttribute(unitID, className, attrib, multiplier, tag, with, value, custom)
	if not unitID or not Spring.ValidUnitID(unitID) or Spring.GetUnitIsDead(unitID) then return end
	local unitDefID = Spring.GetUnitDefID(unitID)
	if not unitDefID then return end
	local weapons = UnitDefs[unitDefID].weapons
	local changed = {}
	local numChanged = 0
	for weapNum, weapTable in pairs(weapons) do
		local wd = WeaponDefs[weapTable["weaponDef"]]
		if className == "all" or (wd.customParams["weaponclass"] == className) then
			if not tag
			or with and custom and wd.customParams[tag] 
			or with and wd[tag] and wd[tag] == value
			or not with and not (wd[tag] == value) then
				if multiplier ~= 1 then
					local currAttrib = Spring.GetUnitWeaponState(unitID, weapNum, attrib)
					--Spring.Echo("Current " .. attrib .. ": ", currAttrib, weapNum, WeaponDefs[weapTable["weaponDef"]].name)
					Spring.SetUnitWeaponState(unitID, weapNum, attrib, currAttrib * multiplier)
				end
				changed[weapNum] = wd
				numChanged = numChanged + 1
			end
		end
	end
	return changed, numChanged
end
GG.setWeaponClassAttribute = setWeaponClassAttribute

local function setWeaponClassDamage(unitID, className, multiplier, tag, with, value)
	local weapons = UnitDefs[Spring.GetUnitDefID(unitID)].weapons
	local changed = {}
	for weapNum, weapTable in pairs(weapons) do
		local wd = WeaponDefs[weapTable["weaponDef"]]
		if className == "all" or (wd.customParams["weaponclass"] == className) then
			if not tag
			or with and wd[tag] and wd[tag] == value
			or not with and not (wd[tag] == value) then
				for i = 0, NUM_DAMAGE_TYPES do
					local currAttrib = Spring.GetUnitWeaponDamages(unitID, weapNum, i)
					Spring.SetUnitWeaponDamages(unitID, weapNum, i, currAttrib * multiplier)
					changed[weapNum] = wd
				end
			end
		end
	end
	return changed	
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

local function deductSalvage(unitID, amount)
	local teamID = Spring.GetUnitTeam(unitID)
	GG.ChangeTeamResource(teamID, "salvage", Spring.IsNoCostEnabled() and 0 or -amount)
end

local function WeaponTypeCount(unitDefID, className)
	local weapons = UnitDefs[unitDefID].weapons
	local count = 0
	local changed = {}
	for weapNum, weapTable in pairs(weapons) do
		local wd = WeaponDefs[weapTable["weaponDef"]]
		if className == "all" or (wd.customParams["weaponclass"] == className) then
			count = count + 1
			changed[weapNum] = wd
		end
	end
	--Spring.Echo("WeaponTypeCount", UnitDefs[unitDefID].name, className, count)
	return count, changed
end

local function deductPerWeaponType(unitDefID, weaponType, amount)
	return WeaponTypeCount(unitDefID, weaponType) * amount
end

local function deductPerUnitDefTag(unitDefID, custom, tag, amount, subtable)
	local ud = UnitDefs[unitDefID]
	local cp = ud.customParams
	local value = (custom and cp[tag] or ud[tag] or 0)
	-- cray stuff for customparams tables
	--Spring.Echo("value 1", value, tag, subtable)
	value = (custom and subtable and table.unserialize(value)) or value
	--Spring.Echo("value 2", value, tag, subtable)
	value = (type(value) == type(EMPTY) and value[subtable]) or value
	--Spring.Echo("value 3", value, tag, subtable)
	return value * amount
end


return {
	-- Mech Experience Perks -------------------------------------------------------------------------
	perks = {
		-- Weapon
		{
			name = "deadshot",
			cmdDesc = {
				id = GetCmdID('PERK_DEAD_SHOT'),
				action = 'perkdeadshot',
				name = GG.Pad("Dead", "Shot"),
				tooltip = '+' .. EFFECT .. '% weapon accuracy',
				texture = 'bitmaps/ui/perks/deadshot.png',	
			},
			valid = allMechs,
			applyPerk = function (unitID) 
				setWeaponClassAttribute(unitID, "all", "accuracy", PCENT_DEC)
			end,
			costFunction = deductXP,
			price = PERK_XP_COST,
			levels = 3,
		},
		{
			name = "triggerfinger",
			cmdDesc = {
				id = GetCmdID('PERK_TRIGGER_FINGER'),
				action = 'perktriggerfinger',
				name = GG.Pad("Trigger", "Finger"),
				tooltip = '+' .. EFFECT .. '% weapon rate of fire',
				texture = 'bitmaps/ui/perks/triggerfinger.png',	
			},
			valid = allMechs,
			applyPerk = function (unitID) 
				setWeaponClassAttribute(unitID, "all", "reloadTime", PCENT_DEC)
			end,
			costFunction = deductXP,
			price = PERK_XP_COST,
			levels = 3,
		},
		{
			name = "firediscipline",
			cmdDesc = {
				id = GetCmdID('PERK_FIRE_DISCIPLINE'),
				action = 'perkfirediscipline',
				name = GG.Pad("Fire", "Discipline"),
				tooltip = '-' .. EFFECT .. '% weapon heat generation',
				texture = 'bitmaps/ui/perks/heatdiscipline.png',	
			},
			valid = allMechs,
			applyPerk = function (unitID) 
				env = Spring.UnitScript.GetScriptEnv(unitID)
				for i = 1, env.numWeapons do
					env.firingHeats[i] = env.firingHeats[i] * PCENT_DEC
				end
			end,
			costFunction = deductXP,
			price = PERK_XP_COST,
			levels = 3,
		},
		-- Utility
		{
			name = "eagleeye",
			cmdDesc = {
				id = GetCmdID('PERK_EAGLE_EYE'),
				action = 'perkeagleeye',
				name = GG.Pad("Eagle", "Eye"),
				tooltip = '+' .. EFFECT .. '% sector view range',
				texture = 'bitmaps/ui/perks/eagleeye.png',	
			},
			valid = allMechs,
			applyPerk = function (unitID) 
				GG.SetUnitSectorRadius(unitID, PCENT_INC)
			end,
			costFunction = deductXP,
			price = PERK_XP_COST,
			levels = 3,
		},
		{
			name = "kingofthehill",
			cmdDesc = {
				id = GetCmdID('PERK_KING_OF_THE_HILL'),
				action = 'perkkindofthehill',
				name = GG.Pad("King of", "The Hill"),
				tooltip = '+' .. EFFECT .. '% beacon capture rate',
				texture = 'bitmaps/ui/perks/kingofthehill.png',	
			},
			valid = allMechs,
			applyPerk = function (unitID) 
				GG.SetUnitCapStrength(unitID, PCENT_INC)
			end,
			costFunction = deductXP,
			price = PERK_XP_COST,
			levels = 3,
		},
		{
			name = "Pinata",
			cmdDesc = {
				id = GetCmdID('PERK_PINATA'),
				action = 'perkpinata',
				name = GG.Pad("Pinata"),
				tooltip = '+1 salvage per kill',
				texture = 'bitmaps/ui/perks/pinata.png',	
			},
			valid = allMechs,
			applyPerk = function (unitID) 
				GG.PinataLevel(unitID, 1) -- add one
			end,
			costFunction = deductXP,
			price = PERK_XP_COST,
			levels = 3,
		},
		-- Jumpjets
		{
			name = "peakcondition",
			cmdDesc = {
				id = GetCmdID('PERK_PEAK_CONDITION'),
				action = 'perkpeakcondition',
				name = GG.Pad("Peak", "Condition"),
				tooltip = '+' .. EFFECT .. '% turn rate and acceleration',
				texture = 'bitmaps/ui/perks/peakcondition.png',	
			},
			valid = allMechs,
			applyPerk = function (unitID, level) 
				GG.SetUnitTurnRate(unitID, PCENT_INC) -- rate in the unit_turn gadget
				local unitDefID = Spring.GetUnitDefID(unitID)
				local ud = UnitDefs[unitDefID]
				local values = {
					turnRate		= ud.turnRate * PCENT_INC ^ level, -- rate when moving
					accRate			= ud.maxAcc * PCENT_INC ^ level,
					decRate			= ud.maxDec * PCENT_INC ^ level,
				}
				GG.SpeedChange(unitID, unitDefID, nil, values) -- Sets groundmovetypedata with safety checks
			end,
			costFunction = deductXP,
			price = PERK_XP_COST,
			levels = 3,
		},
		{
			name = "parkour",
			cmdDesc = {
				id = GetCmdID('PERK_PARKOUR'),
				action = 'perkparkour',
				name = GG.Pad("Parkour!"),
				tooltip = '-1/10th second to jump start delay',
				texture = 'bitmaps/ui/perks/parkour.png',	
			},
			valid = hasJumpjets,
			applyPerk = function (unitID) 
				GG.SetUnitJumpDelay(unitID, -10)
			end,
			costFunction = deductXP,
			price = PERK_XP_COST,
			levels = 3,
		},
		{
			name = "cannonball",
			cmdDesc = {
				id = GetCmdID('PERK_CANNONBALL'),
				action = 'perkcannonball',
				name = GG.Pad("Cannonball"),
				tooltip = '+' .. EFFECT .. '% Death From Above attack damage',
				texture = 'bitmaps/ui/perks/cannonball.png',	
			},
			valid = hasJumpjets,
			applyPerk = function (unitID) 
				GG.SetUnitDFADamage(unitID, PCENT_INC)
			end,
			costFunction = deductXP,
			price = PERK_XP_COST,
			levels = 3,
		},
	},
	-- Outpost Upgrades -------------------------------------------------------------------------
	upgrades = {
		-- Dropzone
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
			sound = 'bb_dropship_upgraded',
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
			sound = 'bb_dropship_upgraded',
		},
		-- aircon
		{
			name = "airconassault",
			cmdDesc = {
				id = GetCmdID('PERK_AIRCON_2'),
				action = 'perkairconassault',
				name = GG.Pad("Assault", "Dropship"),
				tooltip = 'Unlocks the Avenger Assault Dropship sortie.',
				texture = 'bitmaps/ui/upgrade.png',	
			},
			valid = function (unitDefID) return UnitDefs[unitDefID].name:find("aircon") end,
			applyPerk = function (unitID)
				GG.LockAssault(unitID, false)
			end,
			costFunction = deductCBills,
			price = 12000,
		},
		-- C3 Array
		{
			name = "c3overclock",
			cmdDesc = {
				id = GetCmdID('PERK_C3ARRAY_2'),
				action = 'perkc3overclock',
				name = GG.Pad("C3 Over", "Clock"),
				tooltip = 'Unlocks all 3 lances from a single C3 Mainframe. WARNING: Will gradually destroy the mainframe!!',
				texture = 'bitmaps/ui/upgrade.png',	
			},
			valid = function (unitDefID) return UnitDefs[unitDefID].name:find("c3array") end,
			applyPerk = function (unitID)
				env = Spring.UnitScript.GetScriptEnv(unitID)
				Spring.UnitScript.CallAsUnit(unitID, env.Upgrade, 2)
			end,
			costFunction = deductCBills,
			price = 12000,
		},
		-- vehicle pad
		{
			name = "vpadheavy",
			cmdDesc = {
				id = GetCmdID('PERK_VPAD_2'),
				action = 'perkvpadheavy',
				name = GG.Pad("Heavy", "Units"),
				tooltip = 'Adds heavy & assault units to the Regular militia. Adds VTOLs when toggled to All Terrain.',
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
			name = "vpaddirector",
			cmdDesc = {
				id = GetCmdID('PERK_VPAD_3'),
				action = 'perkvpaddirector',
				name = GG.Pad("Militia", "Director"),
				tooltip = 'Allows issuing orders to the vehicle pad in order to direct the militia. Also increases chance of heavier units & VTOLs.',
				texture = 'bitmaps/ui/upgrade.png',	
			},
			valid = function (unitDefID) return (not GG.hoverMap) and UnitDefs[unitDefID].name:find("vehiclepad") end,
			applyPerk = function (unitID)
				GG.PadUpgrade(unitID, 3)
				GG.AddVpadCmds(unitID)
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
			valid = function (unitDefID) return UnitDefs[unitDefID].name == "outpost_garrison" end,
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
				name = GG.Pad("Naval", "PPC"),
				tooltip = 'Unlock Naval PPC anti-sensor area bombardment.',
				texture = 'bitmaps/ui/upgrade.png',	
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
				name = GG.Pad("Naval", "Laser"),
				tooltip = 'Unlock Naval Laser point-target removal service.',
				texture = 'bitmaps/ui/upgrade.png',	
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
				name = GG.Pad("Heavy", "Turrets"),
				tooltip = 'Unlocks heavy and faction turrets, which consume 2 control slots each.',
				texture = 'bitmaps/ui/upgrade.png',	
			},
			valid = function (unitDefID) return UnitDefs[unitDefID].name == "outpost_turretcontrol" end,
			applyPerk = function (unitID)
				GG.LockHeavyTurrets(unitID, false)
			end,
			costFunction = deductCBills,
			price = 6000,
		},
		{
			name = "turretcontrol_3",
			cmdDesc = {
				id = GetCmdID('PERK_TURRETCONTROL_3'),
				action = 'perkturretcontrol_3',
				name = GG.Pad("Increase", "Slots"),
				tooltip = 'Doubles the available turret control bandwidth slots',
				texture = 'bitmaps/ui/upgrade.png',	
			},
			valid = function (unitDefID) return UnitDefs[unitDefID].name == "outpost_turretcontrol" end,
			applyPerk = function (unitID)
				GG.UpdateTurretSlots(unitID, Spring.GetUnitTeam(unitID), 4)
			end,
			costFunction = deductCBills,
			price = 12000,
			requires = "turretcontrol_2",
		},
		-- EWAR
		{
			name = "ewar2",
			cmdDesc = {
				id = GetCmdID('PERK_EWAR_2'),
				action = 'perkewar2',
				name = GG.Pad("Angel", "ECM", "Suite"),
				tooltip = 'Upgrades ECM to Angel ECM. Enemy Beagle Active Probe can no longer penetrate the ECM field.',
				texture = 'bitmaps/ui/upgrade.png',	
			},
			valid = function (unitDefID) return UnitDefs[unitDefID].name == "outpost_ewar" end,
			applyPerk = function (unitID)
				env = Spring.UnitScript.GetScriptEnv(unitID)
				Spring.UnitScript.CallAsUnit(unitID, env.Upgrade, 2)
			end,
			costFunction = deductCBills,
			price = 8000,
		},
		{
			name = "ewar3",
			cmdDesc = {
				id = GetCmdID('PERK_EWAR_3'),
				action = 'perkewar3',
				name = GG.Pad("Seismic", "Noise", "Maker"),
				tooltip = 'Adds a seismic noise maker which confuses enemy seismic sensors with false seismic pings.',
				texture = 'bitmaps/ui/upgrade.png',	
			},
			valid = function (unitDefID) return UnitDefs[unitDefID].name == "outpost_ewar" end,
			applyPerk = function (unitID)
				env = Spring.UnitScript.GetScriptEnv(unitID)
				Spring.UnitScript.CallAsUnit(unitID, env.Upgrade, 3)
			end,
			costFunction = deductCBills,
			price = 12000,
			requires = "ewar2",
		},
		-- Sensor
		{
			name = "sensor2",
			cmdDesc = {
				id = GetCmdID('PERK_SENSOR_2'),
				action = 'perksensor2',
				name = GG.Pad("Blood", "Hound", "Probe"),
				tooltip = 'Upgrades from Beagle to Bloodhound Active Probe. Enemy ECM emitters are now fully revealed.',
				texture = 'bitmaps/ui/upgrade.png',	
			},
			valid = function (unitDefID) return UnitDefs[unitDefID].name == "outpost_sensor" end,
			applyPerk = function (unitID)
				env = Spring.UnitScript.GetScriptEnv(unitID)
				Spring.UnitScript.CallAsUnit(unitID, env.Upgrade, 2)
			end,
			costFunction = deductCBills,
			price = 8000,
		},
		{
			name = "sensor3",
			cmdDesc = {
				id = GetCmdID('PERK_SENSOR_3'),
				action = 'perksensor3',
				name = GG.Pad("Seismic", "Detector"),
				tooltip = 'Adds a map-wide seismic detector that shows where enemy mechs are moving.',
				texture = 'bitmaps/ui/upgrade.png',	
			},
			valid = function (unitDefID) return UnitDefs[unitDefID].name == "outpost_sensor" end,
			applyPerk = function (unitID)
				env = Spring.UnitScript.GetScriptEnv(unitID)
				Spring.UnitScript.CallAsUnit(unitID, env.Upgrade, 3)
			end,
			costFunction = deductCBills,
			price = 12000,
			requires = "sensor2",
		},
		-- Mechbay
		{
			name = "mechbay_2",
			cmdDesc = {
				id = GetCmdID('PERK_MECHBAY_2'),
				action = 'perkmechbay_2',
				name = GG.Pad("Support", "Vehicles"), --"Mech", "Mods"),
				tooltip = 'Unlocks the ability to purchase Savior MRV and J-27 ammo carrier.', --'Unlock mech equipment mods',
				texture = 'bitmaps/ui/upgrade.png',	
			},
			valid = isMechBay,
			applyPerk = function (unitID)
				GG.SetMechBayLevel(unitID, 2)
			end,
			costFunction = deductCBills,
			price = 3000,
		},
		{
			name = "mechbay_3",
			cmdDesc = {
				id = GetCmdID('PERK_MECHBAY_3'),
				action = 'perkmechbay_3',
				name = GG.Pad("Hardened", "MechBay"), --"Omnitech"),
				tooltip = 'Encases the mechbay in an armoured shroud.', --'Unlocks omnitech allowing for changing weapon loadouts of omnimechs',
				texture = 'bitmaps/ui/upgrade.png',	
			},
			valid = isMechBay,
			applyPerk = function (unitID)
				GG.SetMechBayLevel(unitID, 3)
			end,
			costFunction = deductCBills,
			price = 6000,
			requires = "sensor2", -- TODO: this disables it, change to "mechbay_2",
		},
		-- Salvage Yard
		{
			name = "salvageyard_2",
			cmdDesc = {
				id = GetCmdID('PERK_SALVAGEYARD_2'),
				action = 'perksalvageyard_2',
				name = GG.Pad("Heavy", "BRV"),
				tooltip = 'Unlocks Heavy Battlemech Recovery Vehicle, allowing recovery of mechs over 60 tons',
				texture = 'bitmaps/ui/upgrade.png',	
			},
			valid = function (unitDefID) return end,--UnitDefs[unitDefID].name == "outpost_salvageyard" end,
			applyPerk = function (unitID)
				--GG.SetMechBayLevel(unitID, 2)
			end,
			costFunction = deductCBills,
			price = 3000,
		},
		{
			name = "salvageyard_3",
			cmdDesc = {
				id = GetCmdID('PERK_SALVAGEYARD_3'),
				action = 'perksalvageyard_3',
				name = GG.Pad("VTOL", "RV"),
				tooltip = 'Adds a VTOL Recovery Vehicle that picks up salvage and recovers dead mechs',
				texture = 'bitmaps/ui/upgrade.png',	
			},
			valid = function (unitDefID) return end,--UnitDefs[unitDefID].name == "outpost_salvageyard" end,
			applyPerk = function (unitID)
				--GG.SetMechBayLevel(unitID, 3)
			end,
			costFunction = deductCBills,
			price = 6000,
			requires = "salvageyard_2",
		},
	},
	-- Mods -------------------------------------------------------------------------
	mods = {
		-- Structural (CHASSIS)
		{
			name = "endosteel",
			menu = "structural",
			locked = true,
			cmdDesc = {
				id = GetCmdID('MOD_ENDO_STEEL'),
				action = 'modendosteel',
				name = GG.Pad("Endo", "Steel"),
				tooltip = 'Pre-built with integrated Endo Steel chassis',
				texture = 'bitmaps/ui/perkred.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasPrebuilt(unitDefID, "endosteel") end,
			applyPerk = noOp,
			costFunction = noOp,
			price = 0,
		},
		{
			name = "aes",
			menu = "structural",
			cmdDesc = {
				id = GetCmdID('MOD_AES'),
				action = 'modaes',
				name = GG.Pad("Actuator", "Enhance", "System"),
				tooltip = 'Increases rotational speed of torso and arms by 50%.',
				texture = 'bitmaps/ui/perkgrey.png',	
			},
			valid = isMechBay,
			applyTo = isNotOmni,
			applyPerk = function (unitID, level, invert)
				local effect = 1.5
				effect = (invert and 1/effect) or effect
				
				env = Spring.UnitScript.GetScriptEnv(unitID)
				env.TORSO_SPEED = env.TORSO_SPEED * effect -- haha, screw encapsulation
				env.ELEVATION_SPEED = env.ELEVATION_SPEED * effect
			end,
			costFunction = deductSalvage,
			price = 10 * MOD_COST_MULT,
		},
		{
			name = "protectedactuators",
			menu = "structural",
			cmdDesc = {
				id = GetCmdID('MOD_PROTECTED_ACTUATORS'),
				action = 'modprotectedactuators',
				name = GG.Pad("Protected", "Actuators"),
				tooltip = 'Increases limb health by 25%.',
				texture = 'bitmaps/ui/perkgrey.png',	
			},
			valid = isMechBay,
			applyTo = isNotOmni,
			applyPerk = function (unitID, level, invert)
				local effect = 1.25
				effect = (invert and 1/effect) or effect
				
				env = Spring.UnitScript.GetScriptEnv(unitID)
				Spring.UnitScript.CallAsUnit(unitID, env.SetLimbMaxHP, effect)
			end,
			costFunction = deductSalvage,
			price = 5 * MOD_COST_MULT,
		},
		{
			name = "reinforcedlegs",
			menu = "structural",
			cmdDesc = {
				id = GetCmdID('MOD_REINFORCED_LEGS'),
				action = 'modreinforcedlegs',
				name = GG.Pad("Reinforced", "Legs"),
				tooltip = 'Damage taken by executing Death from Above attacks reduced by half.',
				texture = 'bitmaps/ui/perkgrey.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasJumpjets(unitDefID) and isNotOmni(unitDefID) end,
			applyPerk = function (unitID, level, invert)
				GG.SetUnitReinforcedLegs(unitID, not invert)
			end,
			costFunction = deductSalvage,
			price = 8 * MOD_COST_MULT,
		},
		{
			name = "doubleheatsinks",
			menu = "structural",
			cmdDesc = {
				id = GetCmdID('MOD_DOUBLE_HEATSINKS'),
				action = 'moddoubleheatsinks',
				name = GG.Pad("Double", "Heatsinks"),
				tooltip = "Advanced Heatsinks that doubles a Mech's maximum heat threshold and heat dissipation.",
				texture = 'bitmaps/ui/perkgrey.png',	
			},
			valid = isMechBay,
			applyTo = isNotOmni,
			applyPerk = function (unitID, level, invert) 
				local effect = 2
				effect = (invert and 1/effect) or effect
				
				env = Spring.UnitScript.GetScriptEnv(unitID)
				env.baseCoolRate = env.baseCoolRate * effect
				env.heatLimit = env.heatLimit * effect
				Spring.SetUnitRulesParam(unitID, "heatLimit", env.heatLimit)
			end,
			costFunction = deductSalvage,
			priceFunction = function (unitDefID)
				return deductPerUnitDefTag(unitDefID, true, "heatlimit", 1) * MOD_COST_MULT
			end,
		},
		{
			name = "case",
			menu = "structural",
			cmdDesc = {
				id = GetCmdID('MOD_CASE'),
				action = 'modcase',
				name = GG.Pad("CASE", "Ammo", "Bins"),
				tooltip = "Cellular Ammunition Storage Equipment, reduces ammo loss on limb loss by 50% and prevents cookoff damage.",
				texture = 'bitmaps/ui/perkgrey.png',	
			},
			valid = isMechBay,
			applyTo = isNotOmni,
			applyPerk = function (unitID, level, invert) 
				env = Spring.UnitScript.GetScriptEnv(unitID)
				env.case = not invert
			end,
			costFunction = deductSalvage,
			price = 15 * MOD_COST_MULT,
			incompatible = {"expandedbins"},
		},
		{
			name = "expandedbins",
			menu = "structural",
			cmdDesc = {
				id = GetCmdID('MOD_EXPANDED_BINS'),
				action = 'modcase',
				name = GG.Pad("Expanded", "Ammo", "Bins"),
				tooltip = "Increases ammo capacity by 25% but doubles cookoff damage on limb loss",
				texture = 'bitmaps/ui/perkgrey.png',	
			},
			valid = isMechBay,
			applyTo = isNotOmni,
			applyPerk = function (unitID, level, invert) 
				env = Spring.UnitScript.GetScriptEnv(unitID)
				env.expandedBins = not invert
				local ammoCache = {}
				local effect = 1.25
				effect = (invert and 1/effect) or effect
				
				for ammoType in pairs(AmmoTypes) do
					env.ChangeAmmo(ammoType, 0, effect) 
				end
			end,
			costFunction = deductSalvage,
			price = 15 * MOD_COST_MULT,
			incompatible = {"case"},
		},
		-- Mobility (ENGINE)
		{
			name = "lightengine",
			menu = "mobility",
			locked = true,
			cmdDesc = {
				id = GetCmdID('MOD_LIGHT_ENGINE'),
				action = 'modlightengine',
				name = GG.Pad("Light", "Engine"),
				tooltip = 'Pre-built with integrated Light Fusion Engine',
				texture = 'bitmaps/ui/perkred.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasPrebuilt(unitDefID, "lightengine") end,
			applyPerk = noOp,
			costFunction = noOp,
			price = 0,
		},
		{
			name = "xlengine",
			menu = "mobility",
			locked = true,
			cmdDesc = {
				id = GetCmdID('MOD_XL_ENGINE'),
				action = 'modxlengine',
				name = GG.Pad("XL", "Engine"),
				tooltip = 'Pre-built with integrated Extralight Fusion Engine',
				texture = 'bitmaps/ui/perkred.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasPrebuilt(unitDefID, "xlengine") end,
			applyPerk = noOp,
			costFunction = noOp,
			price = 0,
		},
		{
			name = "jumpjets",
			menu = "mobility",
			locked = true,
			cmdDesc = {
				id = GetCmdID('MOD_JUMPJETS'),
				action = 'modjumpjets',
				name = GG.Pad("Jumpjets"),
				tooltip = 'Pre-built with integrated Jumpjets',
				texture = 'bitmaps/ui/perkred.png',	
			},
			valid = isMechBay,
			applyTo = hasJumpjets,
			applyPerk = noOp,
			costFunction = noOp,
			price = 0,
		},
		{
			name = "masc",
			menu = "mobility",
			cmdDesc = {
				id = GetCmdID('MOD_MASC'),
				action = 'modmasc',
				name = GG.Pad("MASC"),
				tooltip = 'Accelerates myomer circuits, increasing running speed to 200% walking. However, damages legs with prolonged use. Stackable with Super Charger.',
				texture = 'bitmaps/ui/perkorange.png',	
			},
			valid = isMechBay,
			applyTo = isNotOmni,
			applyPerk = function (unitID, level, invert)
				env = Spring.UnitScript.GetScriptEnv(unitID)
				Spring.UnitScript.CallAsUnit(unitID, env.EnableMASC, not invert)
				GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, GG.CustomCommands.IDs.CMD_RUN_TOGGLE, {1}, EMPTY}, 1) -- set to on and refresh params
				GG.Delay.DelayCall(GG.ShowMechMenu, {unitID, Spring.GetUnitDefID(unitID), "issueorder"}, 2) -- refresh menu
			end,
			costFunction = deductSalvage,
			price = 10 * MOD_COST_MULT,
			incompatible = {"triplestrengthmyomer"},
		},
		{
			name = "supercharger",
			menu = "mobility",
			cmdDesc = {
				id = GetCmdID('MOD_SUPERCHARGER'),
				action = 'modsupercharger',
				name = GG.Pad("Super", "Charger"),
				tooltip = 'Attaches directly to the engine to boost performance, increasing running speed by 25%. However, generates double heat and damages the torso. Stackable with MASC.',
				texture = 'bitmaps/ui/perkorange.png',	
			},
			valid = isMechBay,
			applyTo = isNotOmni,
			applyPerk = function (unitID, level, invert)
				env = Spring.UnitScript.GetScriptEnv(unitID)
				Spring.UnitScript.CallAsUnit(unitID, env.EnableSuperCharger, not invert)
				GG.Delay.DelayCall(Spring.GiveOrderToUnit, {unitID, GG.CustomCommands.IDs.CMD_RUN_TOGGLE, {1}, EMPTY}, 1) -- set to on and refresh params
				GG.Delay.DelayCall(GG.ShowMechMenu, {unitID, Spring.GetUnitDefID(unitID), "issueorder"}, 2) -- refresh menu
			end,
			costFunction = deductSalvage,
			price = 10 * MOD_COST_MULT,
		},
		{
			name = "triplestrengthmyomer",
			menu = "mobility",
			cmdDesc = {
				id = GetCmdID('MOD_TSM'),
				action = 'modtriplestrengthmyomer',
				name = GG.Pad("Triple", "Strength", "Myomer"),
				tooltip = 'Replaces mech joints with TSM, increasing walking speed by 20% and running speed by 30%, but only when heat exceeds 33%. Stackable with Super Charger.',
				texture = 'bitmaps/ui/perkorange.png',	
			},
			valid = isMechBay,
			applyTo = isNotOmni,
			applyPerk = function (unitID, level, invert)
				env = Spring.UnitScript.GetScriptEnv(unitID)
				Spring.UnitScript.CallAsUnit(unitID, env.EnableTSM, not invert)
			end,
			costFunction = deductSalvage,
			price = 10 * MOD_COST_MULT,
			incompatible = {"masc"},
		},
		{
			name = "directionalthrusters",
			menu = "mobility",
			cmdDesc = {
				id = GetCmdID('MOD_DIRECTIONAL_THRUSTERS'),
				action = 'moddirectionalthrusters',
				name = GG.Pad("Directional", "Thrusters"),
				tooltip = 'Allows Mechs to adjust their heading mid-air after a jump instead of turning before the jump.',
				texture = 'bitmaps/ui/perkorange.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasJumpjets(unitDefID) and isNotOmni(unitDefID) end,
			applyPerk = function (unitID, level, invert)
				GG.SetUnitJumpInstant(unitID, not invert)
			end,
			costFunction = deductSalvage,
			price = 10 * MOD_COST_MULT,
			incompatible = {"improvedjumpjets"},
		},
		{
			name = "improvedjumpjets",
			menu = "mobility",
			cmdDesc = {
				id = GetCmdID('MOD_IMPROVED_JUMP_JETS'),
				action = 'modimprovedjumpjets',
				name = GG.Pad("Improved", "Jumpjets"),
				tooltip = 'Increases Jump Range by 50%, and reduces heat generated by the same amount.',
				texture = 'bitmaps/ui/perkorange.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasJumpjets(unitDefID) and isNotOmni(unitDefID) end,
			applyPerk = function (unitID, level, invert)
				GG.SetUnitImprovedJumpjets(unitID, not invert)
			end,
			costFunction = deductSalvage,
			price = 15 * MOD_COST_MULT,
			incompatible = {"directionalthrusters"},
		},
		-- Tactical (TECH)
		{
			name = "beagle",
			menu = "tactical",
			locked = true,
			cmdDesc = {
				id = GetCmdID('MOD_BEAGLE'),
				action = 'modbeagle',
				name = GG.Pad("Beagle", "Active", "Probe"),
				tooltip = 'Pre-built with integrated Beagle Active Probe sensor suite',
				texture = 'bitmaps/ui/perkred.png',	
			},
			valid = isMechBay,
			applyTo = hasBAP,
			applyPerk = noOp,
			costFunction = noOp,
			price = 0,
		},
		{
			name = "guardian",
			menu = "tactical",
			locked = true,
			cmdDesc = {
				id = GetCmdID('MOD_GUARDIAN_ECM'),
				action = 'modecm',
				name = GG.Pad("Guardian", "ECM"),
				tooltip = 'Pre-built with integrated Guardian ECM suite',
				texture = 'bitmaps/ui/perkred.png',	
			},
			valid = isMechBay,
			applyTo = hasECM,
			applyPerk = noOp,
			costFunction = noOp,
			price = 0,
		},
		{
			name = "angel",
			menu = "tactical",
			cmdDesc = {
				id = GetCmdID('MOD_ANGEL_ECM'),
				action = 'modangelecm',
				name = GG.Pad("Angel", "ECM"),
				tooltip = 'Upgrade to Guardian ECM that removes BAP ECM pings and even the Bloodhound sensor suite',
				texture = 'bitmaps/ui/perkbgability.png',	
			},
			valid = isMechBay,
			applyTo = hasECM,
			applyPerk = function(unitID, level, invert)
				GG.angels[unitID] = not invert
			end,
			costFunction = deductSalvage,
			price = 25 * MOD_COST_MULT,
		},
		{
			name = "bloodhound",
			menu = "tactical",
			cmdDesc = {
				id = GetCmdID('MOD_BLOODHOUND_AP'),
				action = 'modangelecm',
				name = GG.Pad("Blood", "Hound", "Probe"),
				tooltip = 'Upgrade to Beagle Active Probe that can penetrate Guardian ECM, revealing the jammer and allies',
				texture = 'bitmaps/ui/perkbgability.png',	
			},
			valid = isMechBay,
			applyTo = hasBAP,
			applyPerk = function(unitID, level, invert)
				GG.bloodHounds[unitID] = not invert
			end,
			costFunction = deductSalvage,
			price = 25 * MOD_COST_MULT,
		},
		{

			name = "improvedsensors",
			menu = "tactical",
			cmdDesc = {
				id = GetCmdID('MOD_IMPROVED_SENSORS'),
				action = 'modimprovedsensors',
				name = GG.Pad("Improved", "Sensors"),
				tooltip = 'Increases sensor range by 10%.',
				texture = 'bitmaps/ui/perkbgability.png',	
			},
			valid = isMechBay,
			applyTo = isNotOmni,
			applyPerk = function (unitID, level, invert)
				local effect = 1.1
				effect = (invert and 1/effect) or effect
				
				local currRadar = Spring.GetUnitSensorRadius(unitID, "radar")
				--local currLos = Spring.GetUnitSensorRadius(unitID, "los")
				local currAirLos = Spring.GetUnitSensorRadius(unitID, "airLos")
				Spring.SetUnitSensorRadius(unitID, "radar", currRadar * effect)
				--Spring.SetUnitSensorRadius(unitID, "los", currLos * effect)
				Spring.SetUnitSensorRadius(unitID, "airLos", currAirLos * effect)
				if hasBAP(Spring.GetUnitDefID(unitID)) then
					GG.allyBAPs[Spring.GetUnitAllyTeam(unitID)][unitID] = currRadar * effect
				end
			end,
			costFunction = deductSalvage,
			price = 10 * MOD_COST_MULT,
		},
		{
			name = "coolantpods",
			menu = "tactical",
			cmdDesc = {
				id = GetCmdID('MOD_COOLANT_PODS'),
				action = 'modcoolantpods',
				name = GG.Pad("Coolant", "Pods"),
				tooltip = 'Gives Mechs the "Coolant Flush" ability.',-- with 5 charges.',
				texture = 'bitmaps/ui/perkbgability.png',	
			},
			valid = isMechBay,
			applyTo = isNotOmni,
			applyPerk = function (unitID, level, invert)
				GG.EnableCoolantFlush(unitID, not invert)
				GG.EnableAutoCoolant(unitID, not invert)
			end,
			costFunction = deductSalvage,
			price = 5 * MOD_COST_MULT,
		},
		{
			name = "disruptionfieldbooster",
			menu = "tactical",
			cmdDesc = {
				id = GetCmdID('MOD_DISRUPTION_FIELD_BOOSTER'),
				action = 'moddisruptionfieldbooster',
				name = GG.Pad("Disruption", "Field", "Booster"),
				tooltip = "Increases the range of ECM's disruption field.",
				texture = 'bitmaps/ui/perkbgability.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return (isNotOmni(unitDefID) and hasECM(unitDefID)) end,
			applyPerk = function (unitID, level, invert) 
				local effect = 1.5
				effect = (invert and 1/effect) or effect
				
				GG.SetUnitECMRadius(unitID, effect)
			end,
			costFunction = deductSalvage,
			price = 10 * MOD_COST_MULT,
		},
		{
			name = "particlefielddamper",
			menu = "tactical",
			cmdDesc = {
				id = GetCmdID('MOD_PARTICLE_FIELD_DAMPER'),
				action = 'modparticlefielddamper',
				name = GG.Pad("Particle", "Field", "Damper"),
				tooltip = 'Reduces the amount of time electronics are affected by "PPC effect" from PPC hits.',
				texture = 'bitmaps/ui/perkbgability.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return (isNotOmni(unitDefID) and hasECM(unitDefID)) end,
			applyPerk = function (unitID, level, invert)
				local effect = 0.5
				effect = (invert and 1/effect) or effect
				
				Spring.SetUnitRulesParam(unitID, "insulation", effect)
			end,
			costFunction = deductSalvage,
			price = 10 * MOD_COST_MULT,
		},
		
		-- Defensive (ARMOUR)
		{
			name = "ferrofibrousarmour",
			menu = "defensive",
			cmdDesc = {
				id = GetCmdID('MOD_FERRO_FIBROUS_ARMOUR'),
				action = 'modferrofirbousarmour',
				name = GG.Pad("Ferro", "Fibrous", "Armour"),
				tooltip = 'A general 12% increase in damage resistance against all forms of damage.',
				texture = 'bitmaps/ui/perkgreen.png',	
			},
			valid = isMechBay,
			applyTo = isNotOmni,
			applyPerk = function (unitID, level, invert)
				GG.EnableArmour(unitID, not invert, "ferro")
			end,
			costFunction = deductSalvage,
			price = 7 * MOD_COST_MULT,
			incompatible = {"hardenedarmour", "heatarmour", "reactivearmour", "reflecarmour", "stealtharmour"},
		},
		{
			name = "hardenedarmour",
			menu = "defensive",
			cmdDesc = {
				id = GetCmdID('MOD_HARDENED_ARMOUR'),
				action = 'modhardenedarmour',
				name = GG.Pad("Hardened", "Armour"),
				tooltip = '25% increased defense against all damage and nullifies the double-damage done by Autocannon Armour Piercing ammo and SRM Tandem-Charge warheads, but speed, acceleration and leg turn rate reduced by 20%.',
				texture = 'bitmaps/ui/perkgreen.png',	
			},
			valid = isMechBay,
			applyTo = isNotOmni,
			applyPerk = function (unitID, level, invert)
				GG.EnableArmour(unitID, not invert, "hard")
				
				effect = 0.8
				effect = (invert and 1/effect) or effect
				
				GG.SetUnitTurnRate(unitID, effect)
				local ud = UnitDefs[Spring.GetUnitDefID(unitID)]
				local values = {
					turnRate		= ud.turnRate * effect,
					accRate			= ud.maxAcc * effect,
					decRate			= ud.maxDec * effect,
					maxSpeed		= ud.speed * effect,
					maxReverseSpeed	= ud.rSpeed * effect,
				}
				Spring.MoveCtrl.SetGroundMoveTypeData(unitID, values)
				env = Spring.UnitScript.GetScriptEnv(unitID)
				env.speedMod = env.speedMod * effect
			end,
			costFunction = deductSalvage,
			price = 10 * MOD_COST_MULT,
			incompatible = {"ferrofibrousarmour", "heatarmour", "reactivearmour", "reflecarmour", "stealtharmour"},
		},
		{
			name = "heatarmour",
			menu = "defensive",
			cmdDesc = {
				id = GetCmdID('MOD_HEAT_ARMOUR'),
				action = 'modheatarmour',
				name = GG.Pad("Heat", "Dissipating", "Armour"),
				tooltip = 'Makes the unit immune to heat damage from weapons like Flamers and PPCs.',
				texture = 'bitmaps/ui/perkgreen.png',	
			},
			valid = isMechBay,
			applyTo = isNotOmni,
			applyPerk = function (unitID, level, invert)
				GG.EnableArmour(unitID, not invert, "heat")
			end,
			costFunction = deductSalvage,
			price = 5 * MOD_COST_MULT,
			incompatible = {"ferrofibrousarmour", "hardenedarmour", "reactivearmour", "reflecarmour", "stealtharmour"},
		},
		{
			name = "reactivearmour",
			menu = "defensive",
			cmdDesc = {
				id = GetCmdID('MOD_REACTIVE_ARMOUR'),
				action = 'modreactivearmour',
				name = GG.Pad("Reactive", "Armour"),
				tooltip = '25% increased defense against all missiles.',
				texture = 'bitmaps/ui/perkgreen.png',	
			},
			valid = isMechBay,
			applyTo = isNotOmni,
			applyPerk = function (unitID, level, invert)
				GG.EnableArmour(unitID, not invert, "reactive")
			end,
			costFunction = deductSalvage,
			price = 10 * MOD_COST_MULT,
			incompatible = {"ferrofibrousarmour", "hardenedarmour", "heatarmour", "reflecarmour", "stealtharmour"},
		},
		{
			name = "reflecarmour",
			menu = "defensive",
			cmdDesc = {
				id = GetCmdID('MOD_REFLEC_ARMOUR'),
				action = 'modreflecarmour',
				name = GG.Pad("Reflec", "Armour"),
				tooltip = '25% increased defense against damage from laser weapons',
				texture = 'bitmaps/ui/perkgreen.png',	
			},
			valid = isMechBay,
			applyTo = isNotOmni,
			applyPerk = function (unitID, level, invert)
				GG.EnableArmour(unitID, not invert, "reflec")
			end,
			costFunction = deductSalvage,
			price = 10 * MOD_COST_MULT,
			incompatible = {"ferrofibrousarmour", "hardenedarmour", "heatarmour", "reactivearmour", "stealtharmour"},
		},
		{
			name = "stealtharmour",
			menu = "defensive",
			cmdDesc = {
				id = GetCmdID('MOD_STEALTH_ARMOUR'),
				action = 'modstealtharmour',
				name = GG.Pad("Stealth", "Armour"),
				tooltip = 'Invisible to enemy sensors, including Beagle Active Probes, can not be targeted by lock-on weapons, and any unit that shoots at it will suffer 25% accuracy reduction. However, disables Mechs own sensors.',
				texture = 'bitmaps/ui/perkgreen.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasECM(unitDefID) and isFaction(unitDefID, "cc") and isNotOmni(unitDefID) end,
			applyPerk = function (unitID, level, invert)
				GG.EnableStealth(unitID, not invert)
			end,
			costFunction = deductSalvage,
			price = 10 * MOD_COST_MULT,
			incompatible = {"ferrofibrousarmour", "hardenedarmour", "heatarmour", "reactivearmour", "reflecarmour", "artemislrm"},
		},
		-- Offensive (WEAPONS)
		{
			name = "targetingcomputer",
			menu = "offensive",
			cmdDesc = {
				id = GetCmdID('MOD_TARGETING_COMPUTER'),
				action = 'modtargetingcomputer',
				name = GG.Pad("Targeting", "Computer"),
				tooltip = 'Increases the accuracy of all ballistic and energy direct-fire weapons by 25%.',
				texture = 'bitmaps/ui/perkbgfaction.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) 
				return isNotOmni(unitDefID)
				and (hasWeaponClass(unitDefID, "autocannon")--, "salvoSize", true, 1) 
				or hasWeaponClass(unitDefID, "gauss")--, "salvoSize", true, 1) 
				or hasWeaponClass(unitDefID, "ppc") --, "salvoSize", true, 1) 
				or hasWeaponClass(unitDefID, "energy"))--, "soundTrigger", true, true)) 
			end,
			applyPerk = function (unitID, level, invert)
				local effect = 0.75 -- smaller accuracy is better, 25% reduction
				effect = (invert and 1/effect) or effect
				
				setWeaponClassAttribute(unitID, "autocannon", "accuracy", effect)--, "salvoSize", true, 1)
				setWeaponClassAttribute(unitID, "gauss", "accuracy", effect)--, "salvoSize", true, 1)
				setWeaponClassAttribute(unitID, "ppc", "accuracy", effect)--, "salvoSize", true, 1)
				setWeaponClassAttribute(unitID, "energy", "accuracy", effect)--, "soundTrigger", true, true)
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_WEAPON = 5
				local runningTotal = deductPerWeaponType(unitDefID, "autocannon", AMOUNT_PER_WEAPON)
				runningTotal = runningTotal + deductPerWeaponType(unitDefID, "gauss", AMOUNT_PER_WEAPON)
				runningTotal = runningTotal + deductPerWeaponType(unitDefID, "ppc", AMOUNT_PER_WEAPON)
				runningTotal = runningTotal + deductPerWeaponType(unitDefID, "energy", AMOUNT_PER_WEAPON)
				return runningTotal * MOD_COST_MULT
			end,
			--incompatible = {"aatargetingcomputer"},
		},
		{
			name = "apollofcs",
			menu = "offensive",
			cmdDesc = {
				id = GetCmdID('MOD_APOLLO_FCS'),
				action = 'modapollofcs',
				name = GG.Pad("Apollo", "FCS"),
				tooltip = 'Increases the accuracy of MRM weapons by 25%.',
				texture = 'bitmaps/ui/perkbgfaction.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponClass(unitDefID, "mrm") and isNotOmni(unitDefID) and isFaction(unitDefID, "dc") end,
			applyPerk = function (unitID, level, invert)
				--Spring.Echo("Missile range selected") 
				local effect = 0.75 -- smaller accuracy is better, 25% reduction
				effect = (invert and 1/effect) or effect
				
				setWeaponClassAttribute(unitID, "mrm", "accuracy", effect)
				setWeaponClassAttribute(unitID, "mrm", "sprayAngle", effect)
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_WEAPON = 5
				return deductPerWeaponType(unitDefID, "mrm", AMOUNT_PER_WEAPON) * MOD_COST_MULT
			end,
		},
		{
			name = "artemislrm",
			menu = "offensive",
			cmdDesc = {
				id = GetCmdID('MOD_ARTEMIS_LRM'),
				action = 'modartemissrm',
				name = GG.Pad("Artemis", "LRM", "FCS"),
				tooltip = "Applies to LRMs only. Increases accuracy of missiles, but only if fired at target in the Mech's own LOS, as it effectively acts like the unit's own personal TAG.",
				texture = 'bitmaps/ui/perkbgfaction.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return isNotOmni(unitDefID) and hasWeaponClass(unitDefID, "lrm") end,
			applyPerk = function (unitID, level, invert)
				--Spring.Echo("Missile range selected") 
				GG.EnableArtemis(unitID, "lrm", not invert)
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_WEAPON = 5
				return deductPerWeaponType(unitDefID, "lrm", AMOUNT_PER_WEAPON) * MOD_COST_MULT
			end,
			incompatible = {"ammolrmextended", "ammolrminferno", "ammolrmmagpulse", "ammolrmthunder", "ammolrmarad", "ammolrmhoming", "stealtharmour"},
		},
		{
			name = "artemissrm",
			menu = "offensive",
			cmdDesc = {
				id = GetCmdID('MOD_ARTEMIS_SRM'),
				action = 'modartemissrm',
				name = GG.Pad("Artemis", "SRM", "FCS"),
				tooltip = "Applies to SRMs only. Increases accuracy of missiles, but only if fired at target in the Mech's own LOS, as it effectively acts like the unit's own personal TAG.",
				texture = 'bitmaps/ui/perkbgfaction.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return isNotOmni(unitDefID) and hasWeaponClass(unitDefID, "srm") end,
			applyPerk = function (unitID, level, invert)
				--Spring.Echo("Missile range selected") 
				GG.EnableArtemis(unitID, "srm", not invert)
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_WEAPON = 5
				return deductPerWeaponType(unitDefID, "srm", AMOUNT_PER_WEAPON) * MOD_COST_MULT
			end,
			incompatible = {"ammosrmtandem", "ammosrminferno", "ammosrmmagpulse"},
		},
		{
			name = "improvedheavygauss",
			menu = "offensive",
			cmdDesc = {
				id = GetCmdID('MOD_IMPROVED_HEAVY_GAUSS'),
				action = 'modimprovedheavygauss',
				name = GG.Pad("HGauss", "Hybrid", "Armature"),
				tooltip = 'Heavy Gauss only. Replaces electromagnetic propulsion with hybrid armature to fire explosive-tipped shells that deal consistent damage at all ranges.',
				texture = 'bitmaps/ui/perkbgfaction.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return (isNotOmni(unitDefID) and hasWeaponName(unitDefID, "heavygauss") and isFaction(unitDefID, "la")) end,
			applyPerk = function (unitID, level, invert)
				local _, toChange = hasWeaponName(Spring.GetUnitDefID(unitID), "heavygauss")
				for weapNum in pairs(toChange) do
					Spring.SetUnitWeaponDamages(unitID, weapNum, "dynDamageExp", invert and 1 or 0)
					setWeaponClassDamage(unitID, "all", invert and 2160/1900 or 1900/2160)
				end
			end,
			costFunction = deductSalvage,
			price = 10 * MOD_COST_MULT,
			incompatible = {"quickchargingcapacitors"},
		},
		{
			name = "ppccapacitors",
			menu = "offensive",
			cmdDesc = {
				id = GetCmdID('MOD_PPC_CAPACITORS'),
				action = 'modppccapacitors',
				name = GG.Pad("PPC", "Enhanced", "Accelerator"),
				tooltip = 'Applies to PPCs (all variations) only. Increases damage of PPCs by 25% but increases heat generated by 50%.',
				texture = 'bitmaps/ui/perkbgfaction.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return (isNotOmni(unitDefID) and hasWeaponClass(unitDefID, "ppc") and isFaction(unitDefID, "dc")) end,
			applyPerk = function (unitID, level, invert)
				local effect = 1.25
				effect = (invert and 1/effect) or effect
				
				local changed = setWeaponClassDamage(unitID, "ppc", effect)
				
				-- increase heatgen by 50%
				effect = 1.5
				effect = (invert and 1/effect) or effect
				env = Spring.UnitScript.GetScriptEnv(unitID)
				for weapNum in pairs(changed) do
					env.firingHeats[weapNum] = env.firingHeats[weapNum] * effect				
				end
			end,
			costFunction = deductSalvage,
			price = 10 * MOD_COST_MULT,
		},
		{
			name = "ppcinhibitoroverride",
			menu = "offensive",
			cmdDesc = {
				id = GetCmdID('MOD_PPC_INHIBITOROVERRIDE'),
				action = 'modppcinhibitoroverride',
				name = GG.Pad("PPC", "Inhibitor", "Override"),
				tooltip = 'Applies to PPCs with a minimum range only. Allows firing within minimum range, but will also apply PPC effects to the firer.',
				texture = 'bitmaps/ui/perkbgfaction.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return (isNotOmni(unitDefID) and hasWeaponClass(unitDefID, "ppc", "minrange", nil, nil, true)) end,
			applyPerk = function (unitID, level, invert)
				local changed = setWeaponClassAttribute(unitID, "ppc", "range", 1, "minrange", true, nil, true)
				env = Spring.UnitScript.GetScriptEnv(unitID)
				for weapNum in pairs(changed) do
					env.inhibitors[weapNum] = not invert
				end
			end,
			costFunction = deductSalvage,
			price = 5 * MOD_COST_MULT,
		},
		{
			name = "quickchargingcapacitors",
			menu = "offensive",
			cmdDesc = {
				id = GetCmdID('MOD_QUICK_CHARGING_CAPACITORS'),
				action = 'modquickchargingcapacitors',
				name = GG.Pad("Gauss", "Advanced", "Capacitors"),
				tooltip = 'Gauss-based weapons only. Rate of fire increased by 25%, but generates heat similar to a PPC.',
				texture = 'bitmaps/ui/perkbgfaction.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return isNotOmni(unitDefID) and hasWeaponClass(unitDefID, "gauss") and (isFaction(unitDefID, "la") or isFaction(unitDefID, "fw")) end,
			applyPerk = function (unitID, level, invert)
				--Spring.Echo("Missile range selected") 
				local effect = 0.75 -- 25% reduction
				effect = (invert and 1/effect) or effect
				local changed, wd = setWeaponClassAttribute(unitID, "gauss", "reloadTime", effect)
				
				env = Spring.UnitScript.GetScriptEnv(unitID)
				for weapNum in pairs(changed) do
					env.firingHeats[weapNum] = invert and wd.customParams.heatgenerated or 2.5 -- PPC is 5 * 0.5 in lus_helper
				end
			end,
			costFunction = deductSalvage,
			price = 10 * MOD_COST_MULT,
			incompatible = {"improvedheavygauss", "silverbullet"},
		},
		{
			name = "silverbullet",
			menu = "offensive",
			cmdDesc = {
				id = GetCmdID('MOD_SILVER_BULLET'),
				action = 'modsilverbullet',
				name = GG.Pad("Gauss", "Silver", "Bullet"),
				tooltip = 'Regular Gauss Rifle only. Transforms the Gauss into an LBX-like weapon that fires 15 flechette rounds.',
				texture = 'bitmaps/ui/perkbgfaction.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return isNotOmni(unitDefID) and hasWeaponName(unitDefID, "gauss") and isFaction(unitDefID, "la") end,
			applyPerk = function (unitID, level, invert)
				--Spring.Echo("Missile range selected") 
				GG.EnableSilverBullet(unitID, not invert)
			end,
			costFunction = deductSalvage,
			price = 15 * MOD_COST_MULT,
			incompatible = {"quickchargingcapacitors"},
		},
		{
			name = "poweramplifier",
			menu = "offensive",
			cmdDesc = {
				id = GetCmdID('MOD_POWER_AMPLIFIER'),
				action = 'modpoweramplifier',
				name = GG.Pad("Power", "Amplifier"),
				tooltip = 'Beamlasers only. Boosts damage by 10% for 10% extra heat.',
				texture = 'bitmaps/ui/perkbgfaction.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return isNotOmni(unitDefID) and hasWeaponClass(unitDefID, "energy", "soundTrigger", true, true) end,
			applyPerk = function (unitID, level, invert)
				local effect = 1.1
				effect = (invert and 1/effect) or effect
				
				local changed = setWeaponClassDamage(unitID, "energy", effect, "soundTrigger", true, true)
				
				env = Spring.UnitScript.GetScriptEnv(unitID)
				for weapNum in pairs(changed) do
					env.firingHeats[weapNum] = env.firingHeats[weapNum] * effect
				end
			end,
			costFunction = deductSalvage,
			price = 15 * MOD_COST_MULT,
		},
		-- Ammo
		{
			name = "ammoprecision",
			menu = "ammo",
			noLimit = true,
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_PRECISION'),
				action = 'modammoprecision',
				name = GG.Pad("AC", "Precision"),
				tooltip = 'Autocannons only. Increases accuracy of autocannons by 25%, but with 50% reduction in ammunition.',
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponClass(unitDefID, "autocannon", "specialammo", true, "true", true) and isFaction(unitDefID, "fs") end,
			applyPerk = function (unitID, level, invert)
				-- increase accuracy by 25%, lower is better
				effect = 0.75
				effect = (invert and 1/effect) or effect
				local changed = setWeaponClassAttribute(unitID, "autocannon", "accuracy", effect)
				-- reduce max ammo by 50%
				effect = 0.5
				effect = (invert and 1/effect) or effect
				env = Spring.UnitScript.GetScriptEnv(unitID)
				local ammoCache = {}
				for weapNum, wd in pairs(changed) do
					local ammoType = wd.customParams.ammotype
					if not ammoCache[ammoType] then -- only once per ammotype
						ammoCache[ammoType] = true
						env.ChangeAmmo(ammoType, 0, effect)
					end
				end
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_TON = 5
				local _, changed = WeaponTypeCount(unitDefID, "autocannon")
				local runningTotal = 0
				for weapNum, wd in pairs(changed) do
					local ammoType = wd.customParams.ammotype
					local shotsPerTon = GG.GameConstants.ammoTypes[ammoType:upper()]
					runningTotal = runningTotal + deductPerUnitDefTag(unitDefID, true, "maxammo", AMOUNT_PER_TON / shotsPerTon, ammoType)
				end
				return runningTotal * MOD_COST_MULT
			end,
			incompatible = {"ammoarmourpiercing", "ammocaseless", "ammohypervelocity"},
		},
		{
			name = "ammohypervelocity",
			menu = "ammo",
			noLimit = true,
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_HYPERVELOCITY'),
				action = 'modammohypervelocity',
				name = GG.Pad("AC", "Hyper", "Velocity"),
				tooltip = 'Autocannons only. Increases range of autocannons by 25%, but with 50% reduction in ammunition.',
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponClass(unitDefID, "autocannon", "specialammo", true, "true", true) and isFaction(unitDefID, "cc") end,
			applyPerk = function (unitID, level, invert)
				-- increase range by 25%
				effect = 1.25
				effect = (invert and 1/effect) or effect
				local changed = setWeaponClassAttribute(unitID, "autocannon", "range", effect)
				-- reduce max ammo by 50%
				effect = 0.5
				effect = (invert and 1/effect) or effect
				env = Spring.UnitScript.GetScriptEnv(unitID)
				local ammoCache = {}
				for weapNum, wd in pairs(changed) do
					local ammoType = wd.customParams.ammotype
					if not ammoCache[ammoType] then -- only once per ammotype
						ammoCache[ammoType] = true
						env.ChangeAmmo(ammoType, 0, effect)
					end
				end
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_TON = 5
				local _, changed = WeaponTypeCount(unitDefID, "autocannon")
				local runningTotal = 0
				for weapNum, wd in pairs(changed) do
					local ammoType = wd.customParams.ammotype
					local shotsPerTon = GG.GameConstants.ammoTypes[ammoType:upper()]
					runningTotal = runningTotal + deductPerUnitDefTag(unitDefID, true, "maxammo", AMOUNT_PER_TON / shotsPerTon, ammoType)
				end
				return runningTotal * MOD_COST_MULT
			end,
			incompatible = {"ammoprecision", "ammoarmourpiercing", "ammocaseless"},
		},
		{
			name = "ammoarmourpiercing",
			menu = "ammo",
			noLimit = true,
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_ARMOUR_PIERCING'),
				action = 'modammoarmourpiercing',
				name = GG.Pad("AC", "Armour", "Piercing"),
				tooltip = 'Autocannons only. Increases damage of shells by 25%, but with 50% reduction in ammunition and 25% reduction in accuracy.',
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponClass(unitDefID, "autocannon", "specialammo", true, "true", true) and isFaction(unitDefID, "fs") end,
			applyPerk = function (unitID, level, invert)
				-- increase damage by 25%
				GG.EnableAmmo(unitID, not invert, "autocannon", "armourpiercing")				

				-- decrease accuracy by 25%, lower is better
				effect = 1.25
				effect = (invert and 1/effect) or effect
				local changed = setWeaponClassAttribute(unitID, "autocannon", "accuracy", effect)
				-- reduce max ammo by 50%
				effect = 0.5
				effect = (invert and 1/effect) or effect
				env = Spring.UnitScript.GetScriptEnv(unitID)
				local ammoCache = {}
				for weapNum, wd in pairs(changed) do
					local ammoType = wd.customParams.ammotype
					if not ammoCache[ammoType] then -- only once per ammotype
						ammoCache[ammoType] = true
						env.ChangeAmmo(ammoType, 0, effect)
					end
				end
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_TON = 10
				local _, changed = WeaponTypeCount(unitDefID, "autocannon")
				local runningTotal = 0
				for weapNum, wd in pairs(changed) do
					local ammoType = wd.customParams.ammotype
					local shotsPerTon = GG.GameConstants.ammoTypes[ammoType:upper()]
					runningTotal = runningTotal + deductPerUnitDefTag(unitDefID, true, "maxammo", AMOUNT_PER_TON / shotsPerTon, ammoType)
				end
				return runningTotal * MOD_COST_MULT
			end,
			incompatible = {"ammoprecision", "ammocaseless", "ammohypervelocity"},
		},
		{
			name = "ammocaseless",
			menu = "ammo",
			noLimit = true,
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_CASELESS'),
				action = 'modammocaseless',
				name = GG.Pad("AC", "Caseless"),
				tooltip = 'Autocannons only.  Increases ammunition storage by 50%.',
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponClass(unitDefID, "autocannon", "specialammo", true, "true", true) and isFaction(unitDefID, "fs") end,
			applyPerk = function (unitID, level, invert)
				-- increase max ammo by 50%
				local effect = 1.5
				effect = (invert and 1/effect) or effect
				env = Spring.UnitScript.GetScriptEnv(unitID)
				local ammoCache = {}
				local changed = setWeaponClassAttribute(unitID, "autocannon", "range", 1) -- hack to get weapon numbers
				for weapNum, wd in pairs(changed) do
					local ammoType = wd.customParams.ammotype
					if not ammoCache[ammoType] then -- only once per ammotype
						ammoCache[ammoType] = true
						env.ChangeAmmo(ammoType, 0, effect)
					end
				end
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_TON = 5
				local _, changed = WeaponTypeCount(unitDefID, "autocannon")
				local runningTotal = 0
				for weapNum, wd in pairs(changed) do
					local ammoType = wd.customParams.ammotype
					local shotsPerTon = GG.GameConstants.ammoTypes[ammoType:upper()]
					runningTotal = runningTotal + deductPerUnitDefTag(unitDefID, true, "maxammo", AMOUNT_PER_TON / shotsPerTon, ammoType)
				end
				return runningTotal * MOD_COST_MULT
			end,
			incompatible = {"ammoprecision", "ammoarmourpiercing", "ammohypervelocity"},
		},
		{
			name = "ammolrminferno",
			menu = "ammo",
			noLimit = true,
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_LRM_INFERNO'),
				action = 'modammolrminferno',
				name = GG.Pad("LRM", "Inferno"),
				tooltip = 'LRMs only. Missiles will apply heat damage to targets, but deal no damage.',
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponClass(unitDefID, "lrm") end,
			applyPerk = function (unitID, level, invert)
				GG.EnableAmmo(unitID, not invert, "lrm", "inferno")				
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_TON = 5 / GG.GameConstants.ammoTypes.LRM
				return deductPerUnitDefTag(unitDefID, true, "maxammo", AMOUNT_PER_TON, "lrm") * MOD_COST_MULT
			end,
			incompatible = {"ammolrmextended", "artemislrm", "ammolrmmagpulse", "ammolrmthunder", "ammolrmarad", "ammolrmhoming"},
		},
		{
			name = "ammolrmextended",
			menu = "ammo",
			noLimit = true,
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_LRM_EXTENDED'),
				action = 'modammolrmextended',
				name = GG.Pad("Extended", "Range", "LRM"),
				tooltip = 'Applies to LRMs only. Increases LRM range by 50%, but reduces ammo by 50%.',
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponClass(unitDefID, "lrm") end,
			applyPerk = function (unitID, level, invert)
				-- increase range by 50%
				local effect = 1.5
				effect = (invert and 1/effect) or effect
				
				local changed = setWeaponClassAttribute(unitID, "lrm", "range", effect)
				-- reduce max ammo by 50%
				effect = 0.5
				effect = (invert and 1/effect) or effect
				env = Spring.UnitScript.GetScriptEnv(unitID)
				env.ChangeAmmo("lrm", 0, effect)
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_TON = 10 / GG.GameConstants.ammoTypes.LRM
				return deductPerUnitDefTag(unitDefID, true, "maxammo", AMOUNT_PER_TON, "lrm") * MOD_COST_MULT
			end,
			incompatible = {"artemislrm", "ammolrminferno", "ammolrmmagpulse", "ammolrmthunder", "ammolrmarad", "ammolrmhoming"},
		},
		{
			name = "ammolrmmagpulse",
			menu = "ammo",
			noLimit = true,
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_LRM_MAG_PULSE'),
				action = 'modammolrmmagpulse',
				name = GG.Pad("LRM", "Mag", "Pulse"),
				tooltip = 'LRMs only. Mag-Pulse Warheads effectively deal the heat and electronic disruption effect of PPC hits, but no damage.',
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponClass(unitDefID, "lrm") and isFaction(unitDefID, "fw") end,
			applyPerk = function (unitID, level, invert)
				GG.EnableAmmo(unitID, not invert, "lrm", "magpulse")				
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_TON = 5 / GG.GameConstants.ammoTypes.LRM
				return deductPerUnitDefTag(unitDefID, true, "maxammo", AMOUNT_PER_TON, "lrm") * MOD_COST_MULT
			end,
			incompatible = {"ammolrmextended", "artemislrm", "ammolrminferno", "ammolrmthunder", "ammolrmarad", "ammolrmhoming"},
		},
		{
			name = "ammolrmarad",
			menu = "ammo",
			noLimit = true,
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_LRM_ARAD'),
				action = 'modammolrmarad',
				name = GG.Pad("LRM", "Anti", "Radiation"),
				tooltip = 'LRMs only. Anti-Radiation warheads that can fire at units with ECM, though not at other units inside ECM, but have poorer tracking against non-ECM targets.',
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponClass(unitDefID, "lrm") and (isFaction(unitDefID, "fw") or isFaction(unitDefID, "sj")) end,
			applyPerk = function (unitID, level, invert)
				GG.EnableAmmo(unitID, not invert, "lrm", "arad")				
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_TON = 10 / GG.GameConstants.ammoTypes.LRM
				return deductPerUnitDefTag(unitDefID, true, "maxammo", AMOUNT_PER_TON, "lrm") * MOD_COST_MULT
			end,
			incompatible = {"ammolrmextended", "artemislrm", "ammolrminferno", "ammolrmthunder", "ammolrmmagpulse", "ammolrmhoming"},
		},
		{
			name = "ammolrmthunder",
			menu = "ammo",
			noLimit = true,
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_LRM_THUNDER'),
				action = 'modammolrmthunder',
				name = GG.Pad("LRM", "Thunder"),
				tooltip = 'LRMs only. LRM hits deal 25% less damage, but missiles that impact the ground leave behind a small mine, allowing for planting of minefields.',
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponClass(unitDefID, "lrm") and isFaction(unitDefID, "cc") end,
			applyPerk = function (unitID, level, invert)
				GG.EnableAmmo(unitID, not invert, "lrm", "thunder")				
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_TON = 15 / GG.GameConstants.ammoTypes.LRM
				return deductPerUnitDefTag(unitDefID, true, "maxammo", AMOUNT_PER_TON, "lrm") * MOD_COST_MULT
			end,
			incompatible = {"ammolrmextended", "artemislrm", "ammolrminferno", "ammolrmmagpulse", "ammolrmarad", "ammolrmhoming"},
		},
		{
			name = "ammolrmhoming",
			menu = "ammo",
			noLimit = true,
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_LRM_HOMING'),
				action = 'modammolrmhoming',
				name = GG.Pad("LRM", "Smart"),
				tooltip = 'LRMs only. Missiles can track targets being painted with TAG, becoming much more accurate.',
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponClass(unitDefID, "lrm") and isFaction(unitDefID, "fw") end,
			applyPerk = function (unitID, level, invert)
				GG.EnableAmmo(unitID, not invert, "lrm", "homing")				
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_TON = 25 / GG.GameConstants.ammoTypes.LRM
				return deductPerUnitDefTag(unitDefID, true, "maxammo", AMOUNT_PER_TON, "lrm") * MOD_COST_MULT
			end,
			incompatible = {"ammolrmextended", "artemislrm", "ammolrminferno", "ammolrmmagpulse", "ammolrmarad", "ammolrmthunder"},
		},
		{
			name = "ammoarrowhoming",
			menu = "ammo",
			noLimit = true,
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_ARROW_HOMING'),
				action = 'modammoarrowhoming',
				name = GG.Pad("Arrow IV", "Homing"),
				tooltip = 'Arrow Artillery missile only. Allows Arrow missiles to track targets being painted with TAG, becoming much more accurate.',
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponName(unitDefID, "arrowiv") end,
			applyPerk = function (unitID, level, invert)
				GG.EnableAmmo(unitID, not invert, "arrowiv", "homing")				
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_TON = 25 / GG.GameConstants.ammoTypes.Arrow
				return deductPerUnitDefTag(unitDefID, true, "maxammo", AMOUNT_PER_TON, "arrow") * MOD_COST_MULT
			end,
			incompatible = {"ammoarrowarad", "ammoarrowcluster", "ammoarrowthunder", "ammoarrowad"},
		},
		{
			name = "ammoarrowcluster",
			menu = "ammo",
			noLimit = true,
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_ARROW_CLUSTER'),
				action = 'modammoarrowcluster',
				name = GG.Pad("Arrow IV", "Cluster"),
				tooltip = 'Arrow Artillery missile only. Replaces the artillery warhead with 96 cluster munitions to saturate an area.',
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponName(unitDefID, "arrowiv") end,
			applyPerk = function (unitID, level, invert)
				GG.EnableAmmo(unitID, not invert, "arrowiv", "cluster")				
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_TON = 25 / GG.GameConstants.ammoTypes.Arrow
				return deductPerUnitDefTag(unitDefID, true, "maxammo", AMOUNT_PER_TON, "arrow") * MOD_COST_MULT
			end,
			incompatible = {"ammoarrowarad", "ammoarrowhoming", "ammoarrowthunder", "ammoarrowad"},
		},
		{
			name = "ammoarrowthunder",
			menu = "ammo",
			noLimit = true,
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_ARROW_THUNDER'),
				action = 'modammoarrowthunder',
				name = GG.Pad("Arrow IV", "Thunder"),
				tooltip = 'Arrow Artillery missile only. Replaces the artillery warhead with 96 mines scattered over an area.',
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponName(unitDefID, "arrowiv") and isFaction(unitDefID, "cc") end,
			applyPerk = function (unitID, level, invert)
				GG.EnableAmmo(unitID, not invert, "arrowiv", "thunder")				
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_TON = 25 / GG.GameConstants.ammoTypes.Arrow
				return deductPerUnitDefTag(unitDefID, true, "maxammo", AMOUNT_PER_TON, "arrow") * MOD_COST_MULT
			end,
			incompatible = {"ammoarrowarad", "ammoarrowhoming", "ammoarrowcluster", "ammoarrowad"},
		},
		{
			name = "ammoarrowad",
			menu = "ammo",
			noLimit = true,
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_ARROW_AD'),
				action = 'modammoarrowad',
				name = GG.Pad("Arrow IV", "Air", "Defense"),
				tooltip = 'Arrow Artillery missile only. Replaces the artillery warhead with an anti-air heat seeker.',
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponName(unitDefID, "arrowiv") and isFaction(unitDefID, "cc") end,
			applyPerk = function (unitID, level, invert)
				GG.EnableAmmo(unitID, not invert, "arrowiv", "ad")				
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_TON = 25 / GG.GameConstants.ammoTypes.Arrow
				return deductPerUnitDefTag(unitDefID, true, "maxammo", AMOUNT_PER_TON, "arrow") * MOD_COST_MULT
			end,
			incompatible = {"ammoarrowarad", "ammoarrowhoming", "ammoarrowcluster", "ammoarrowthunder"},
		},
		{
			name = "ammoarrowarad",
			menu = "ammo",
			noLimit = true,
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_ARROW_ARAD'),
				action = 'modammolrmarad',
				name = GG.Pad("Arrow IV", "Anti", "Radiation"),
				tooltip = 'Arrow Artillery missile only. Anti-Radiation warheads that can fire at units with ECM, though not at other units inside ECM, but have poorer tracking against non-ECM targets.',
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponName(unitDefID, "arrowiv") and (isFaction(unitDefID, "fw") or isFaction(unitDefID, "sj")) end,
			applyPerk = function (unitID, level, invert)
				GG.EnableAmmo(unitID, not invert, "arrowiv", "arad")
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_TON = 10 / GG.GameConstants.ammoTypes.Arrow
				return deductPerUnitDefTag(unitDefID, true, "maxammo", AMOUNT_PER_TON, "arrow") * MOD_COST_MULT
			end,
			incompatible = {"ammoarrowhoming", "ammoarrowcluster", "ammoarrowthunder", "ammoarrowad"},
		},
		{
			name = "ammosrminferno",
			menu = "ammo",
			noLimit = true,
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_SRM_INFERNO'),
				action = 'modammosrminferno',
				name = GG.Pad("SRM", "Inferno"),
				tooltip = 'SRMs only. Missiles will apply heat damage to targets, but deal no damage.',
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponClass(unitDefID, "srm") end,
			applyPerk = function (unitID, level, invert)
				GG.EnableAmmo(unitID, not invert, "srm", "inferno")				
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_TON = 8 / GG.GameConstants.ammoTypes.SRM
				return deductPerUnitDefTag(unitDefID, true, "maxammo", AMOUNT_PER_TON, "srm") * MOD_COST_MULT
			end,
			incompatible = {"ammosrmtandem", "ammosrmmagpulse", "artemissrm"},
		},
		{
			name = "ammosrmtandem",
			menu = "ammo",
			noLimit = true,
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_SRM_TANDEM'),
				action = 'modammosrmtandem',
				name = GG.Pad("SRM", "Tandem"),
				tooltip = 'SRMs only. Doubles the amount of damage SRMs do, but halves ammo capacity.',
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponClass(unitDefID, "srm") end,
			applyPerk = function (unitID, level, invert)
				GG.EnableAmmo(unitID, not invert, "srm", "tandem")		
				
				local effect = 0.5
				effect = (invert and 1/effect) or effect
				env = Spring.UnitScript.GetScriptEnv(unitID)
				env.ChangeAmmo("srm", 0, effect)
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_TON = 5 / GG.GameConstants.ammoTypes.SRM
				return deductPerUnitDefTag(unitDefID, true, "maxammo", AMOUNT_PER_TON, "srm") * MOD_COST_MULT
			end,
			incompatible = {"ammosrminferno", "ammosrmmagpulse", "artemissrm"},
		},
		{
			name = "ammosrmmagpulse",
			menu = "ammo",
			noLimit = true,
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_SRM_MAG_PULSE'),
				action = 'modammosrmmagpulse',
				name = GG.Pad("SRM", "Mag", "Pulse"),
				tooltip = 'SRMs only. Mag-Pulse Warheads effectively deal the heat and electronic disruption effect of PPC hits, but no damage.',
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponClass(unitDefID, "srm") and isFaction(unitDefID, "fw") end,
			applyPerk = function (unitID, level, invert)
				GG.EnableAmmo(unitID, not invert, "srm", "magpulse")				
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_TON = 5 / GG.GameConstants.ammoTypes.SRM
				return deductPerUnitDefTag(unitDefID, true, "maxammo", AMOUNT_PER_TON, "srm") * MOD_COST_MULT
			end,
			incompatible = {"ammosrmtandem", "ammosrminferno", "artemissrm"},
		},
		{
			name = "ammoinarc",
			menu = "ammo",
			noLimit = true,
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_I_NARC'),
				action = 'modammoinarc',
				name = GG.Pad("Improved", "NARC"),
				tooltip = "Improved Narc Beacon. 50% range increase and 2x Homing Pod duration.",
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return allMechs(unitDefID) and hasWeaponName(unitDefID, "NARC") end,
			applyPerk = function (unitID, level, invert) 
				local effect = 1.5
				effect = (invert and 1/effect) or effect
				setWeaponClassAttribute(unitID, "narc", "range", effect)
				
				effect = 2
				effect = (invert and 1/effect) or effect
				local currDuration = Spring.GetUnitRulesParam(unitID, "NARC_DURATION") or Spring.GetGameRulesParam("NARC_DURATION")
				Spring.SetUnitRulesParam(unitID, "NARC_DURATION", currDuration * effect)
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_TON = 5 / GG.GameConstants.ammoTypes.Narc
				return deductPerUnitDefTag(unitDefID, true, "maxammo", AMOUNT_PER_TON, "narc") * MOD_COST_MULT
			end,
			incompatible = {"ammonarcbola", "ammonarcthermite", "ammonarchaywire", "ammonarcexplosive", "ammonarcecm"},
		},
		{
			name = "ammonarcexplosive",
			menu = "ammo",
			noLimit = true,
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_NARC_EXPLOSIVE'),
				action = 'modammonarcexplosive',
				name = GG.Pad("NARC", "Explosive", "Pod"),
				tooltip = 'Narc only. Replaced standard Homing Pod fired by Narc Launchers with an Explosive Pod that deals 400 damage.',
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponName(unitDefID, "narc") and isFaction(unitDefID, "dc") end,
			applyPerk = function (unitID, level, invert)
				GG.EnableAmmo(unitID, not invert, "narc", "explosivepod")				
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_TON = 5 / GG.GameConstants.ammoTypes.Narc
				return deductPerUnitDefTag(unitDefID, true, "maxammo", AMOUNT_PER_TON, "narc") * MOD_COST_MULT
			end,
			incompatible = {"ammonarcbola", "ammonarcthermite", "ammonarchaywire", "ammoinarc", "ammonarcecm"},
		},
		{
			name = "ammonarcbola",
			menu = "ammo",
			noLimit = true,
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_NARC_BOLA'),
				action = 'modammonarcbola',
				name = GG.Pad("NARC", "Bola", "Pod"),
				tooltip = 'Narc only. Replaces standard Homing Pod fired by Narcs with a Bola Pod that temporarily immobilizes target Mechs for several seconds.',
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponName(unitDefID, "narc") and isFaction(unitDefID, "cc") end,
			applyPerk = function (unitID, level, invert)
				GG.EnableAmmo(unitID, not invert, "narc", "bola")				
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_TON = 5 / GG.GameConstants.ammoTypes.Narc
				return deductPerUnitDefTag(unitDefID, true, "maxammo", AMOUNT_PER_TON, "narc") * MOD_COST_MULT
			end,
			incompatible = {"ammonarcexplosive", "ammonarcthermite", "ammonarchaywire", "ammoinarc", "ammonarcecm"},
		},
		{
			name = "ammonarcthermite",
			menu = "ammo",
			noLimit = true,
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_NARC_THERMITE'),
				action = 'modammonarcthermite',
				name = GG.Pad("NARC", "Thermite"),
				tooltip = 'Narc only. Replaces standard Homing Pod fired by Narcs with a thermite charge that delivers heat for several seconds.',
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponName(unitDefID, "narc") end,
			applyPerk = function (unitID, level, invert)
				GG.EnableAmmo(unitID, not invert, "narc", "thermite")				
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_TON = 5 / GG.GameConstants.ammoTypes.Narc
				return deductPerUnitDefTag(unitDefID, true, "maxammo", AMOUNT_PER_TON, "narc") * MOD_COST_MULT
			end,
			incompatible = {"ammonarcexplosive", "ammonarcbola", "ammonarchaywire", "ammoinarc", "ammonarcecm"},
		},
		{
			name = "ammonarchaywire",
			menu = "ammo",
			noLimit = true,
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_NARC_HAYWIRE'),
				action = 'modammonarchaywire',
				name = GG.Pad("NARC", "Haywire"),
				tooltip = 'Narc only. Replaces standard Homing Pod fired by Narcs with a haywire pod which halves target accuracy for several seconds.',
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponName(unitDefID, "narc") end,
			applyPerk = function (unitID, level, invert)
				GG.EnableAmmo(unitID, not invert, "narc", "haywire")
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_TON = 5 / GG.GameConstants.ammoTypes.Narc
				return deductPerUnitDefTag(unitDefID, true, "maxammo", AMOUNT_PER_TON, "narc") * MOD_COST_MULT
			end,
			incompatible = {"ammonarcexplosive", "ammonarcbola", "ammonarcthermite", "ammoinarc", "ammonarcecm"},
		},
		{
			name = "ammonarcecm",
			menu = "ammo",
			noLimit = true,
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_NARC_ECM'),
				action = 'modammonarcecm',
				name = GG.Pad("NARC", "ECM"),
				tooltip = "Narc only. Replaces standard Homing Pod fired by Narcs with an ECM pod which scrambles the target's homing missile targeting.",
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponName(unitDefID, "narc") end,
			applyPerk = function (unitID, level, invert)
				GG.EnableAmmo(unitID, not invert, "narc", "ecm")
			end,
			costFunction = deductSalvage,
			priceFunction = function(unitDefID)
				local AMOUNT_PER_TON = 5 / GG.GameConstants.ammoTypes.Narc
				return deductPerUnitDefTag(unitDefID, true, "maxammo", AMOUNT_PER_TON, "narc") * MOD_COST_MULT
			end,
			incompatible = {"ammonarcexplosive", "ammonarcbola", "ammonarcthermite", "ammoinarc", "ammonarchaywire"},
		},
	},
}