-- Use the automatic CMD ID generator
local GetCmdID = GG.CustomCommands.GetCmdID

local modOptions = Spring.GetModOptions()

local PERK_XP_COST = 1.0 -- 1.5
local EFFECT = modOptions and modOptions.perkeffect or 5
local PCENT_INC = (100+EFFECT)/100
local PCENT_DEC = (100-EFFECT)/100

-- Common valid() functions
local function allMechs(unitDefID) return (UnitDefs[unitDefID].customParams.baseclass == "mech") end
local function hasJumpjets(unitDefID) return (UnitDefs[unitDefID].customParams.jumpjets or false) end
local function hasMASC(unitDefID) return (allMechs(unitDefID) and UnitDefs[unitDefID].customParams.masc or false) end
local function hasECM(unitDefID) return (allMechs(unitDefID) and UnitDefs[unitDefID].customParams.ecm or false) end
local function hasBAP(unitDefID) return (allMechs(unitDefID) and UnitDefs[unitDefID].customParams.bap or false) end
local function isFaction(unitDefID, faction) return (allMechs(unitDefID) and UnitDefs[unitDefID].name:sub(1,2) == faction) end

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

local function hasWeaponClass(unitDefID, className, tag, with, value) -- projectile, energy, missile
	local weapons = UnitDefs[unitDefID].weapons
	for weapNum, weapTable in pairs(weapons) do 
		local wd = WeaponDefs[weapTable["weaponDef"]]
		if wd.customParams["weaponclass"] == className then 
			if not tag then
				return true 
			elseif with and wd[tag] and wd[tag] == value then
				--Spring.Echo(UnitDefs[unitDefID].name, "has weapon class", className, "(", wd.name, ") with", tag, "value", value)
				return true
			elseif not with and not (wd[tag] == value) then
				--Spring.Echo(UnitDefs[unitDefID].name, "has weapon class", className, "(", wd.name, ") without", tag, "value", value)
				return true
			end
		end
	end
	return false
end	

-- Common apply() functions
local function setWeaponClassAttribute(unitID, className, attrib, multiplier, tag, with, value)
	local weapons = UnitDefs[Spring.GetUnitDefID(unitID)].weapons
	local changed = {}
	for weapNum, weapTable in pairs(weapons) do
		local wd = WeaponDefs[weapTable["weaponDef"]]
		if className == "all" or (wd.customParams["weaponclass"] == className) then
			if not tag
			or with and wd[tag] and wd[tag] == value
			or not with and not (wd[tag] == value) then
				local currAttrib = Spring.GetUnitWeaponState(unitID, weapNum, attrib)
				--Spring.Echo("Current " .. attrib .. ": ", currAttrib, weapNum, WeaponDefs[weapTable["weaponDef"]].name)
				Spring.SetUnitWeaponState(unitID, weapNum, attrib, currAttrib * multiplier)
				changed[weapNum] = wd
			end
		end
	end
	return changed
end

local NUM_DAMAGE_TYPES = 13

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
					changed[weapNum] = wf
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
	GG.ChangeTeamSalvage(teamID, Spring.IsNoCostEnabled() and 0 or -amount)
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
		-- Mechbay
		{
			name = "mechbay_2",
			cmdDesc = {
				id = GetCmdID('PERK_MECHBAY_2'),
				action = 'perkmechbay_2',
				name = GG.Pad("Mech", "Mods &", "Omni"),
				tooltip = 'Unlock mech equipment mods and omnitech',
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
				name = GG.Pad("Battlemech", "Recovery", "Vehicle"),
				tooltip = 'Adds a BRV that picks up salvage and recovers dead mechs',
				texture = 'bitmaps/ui/upgrade.png',	
			},
			valid = isMechBay,
			applyPerk = function (unitID)
				GG.SetMechBayLevel(unitID, 3)
			end,
			costFunction = deductCBills,
			price = 6000,
			requires = "mechbay_2",
		},
	},
	-- Mods -------------------------------------------------------------------------
	mods = {
		-- Mobility
		{
			name = "aes",
			menu = "mobility",
			cmdDesc = {
				id = GetCmdID('MOD_AES'),
				action = 'modaes',
				name = GG.Pad("Actuator", "Enhance", "System"),
				tooltip = 'Increases rotational speed of torso and arms by 50%.',
				texture = 'bitmaps/ui/perkorange.png',	
			},
			valid = isMechBay,
			applyTo = allMechs,
			applyPerk = function (unitID, level, invert)
				local effect = 1.5
				effect = (invert and 1/effect) or effect
				
				env = Spring.UnitScript.GetScriptEnv(unitID)
				env.TORSO_SPEED = env.TORSO_SPEED * effect -- haha, screw encapsulation
				env.ELEVATION_SPEED = env.ELEVATION_SPEED * effect
			end,
			costFunction = deductSalvage,
			price = 5,
		},
		{
			name = "directionalthrusters",
			menu = "mobility",
			cmdDesc = {
				id = GetCmdID('MOD_DIRECTIONAL_THRUSTERS'),
				action = 'moddirectionalthrusters',
				name = GG.Pad("Directional", "Thrusters"),
				tooltip = 'Allows Mechs to adjust their heading mid-air after a jump, removing the need to turn and face its jump location.',
				texture = 'bitmaps/ui/perkorange.png',	
			},
			valid = isMechBay,
			applyTo = hasJumpjets,
			applyPerk = function (unitID, level, invert)
				GG.SetUnitJumpInstant(unitID, not invert)
			end,
			costFunction = deductSalvage,
			price = 5,
		},
		{
			name = "mechanicaljumpsystem",
			menu = "mobility",
			cmdDesc = {
				id = GetCmdID('MOD_MECHANICAL_JUMP_SYSTEM'),
				action = 'modmechanicaljumpsystem',
				name = GG.Pad("Mechanical", "Jump", "System"),
				tooltip = 'Replaces the jet-propelled jump system of a Mech with a mechanical system. Removes the need to recharge after a jump, but halves jump distance, and damage to legs will make the system inoperable.',
				texture = 'bitmaps/ui/perkorange.png',	
			},
			valid = isMechBay,
			applyTo = hasJumpjets,
			applyPerk = function (unitID, level, invert)
				GG.SetUnitMechanicalJump(unitID, not invert)
			end,
			costFunction = deductSalvage,
			price = 10,
		},
		-- Tactical
		{
			name = "doubleheatsinks",
			menu = "tactical",
			cmdDesc = {
				id = GetCmdID('MOD_DOUBLE_HEATSINKS'),
				action = 'moddoubleheatsinks',
				name = GG.Pad("Double", "Heatsinks"),
				tooltip = "Advanced Heatsinks that improves a Mech's maximum heat threshold. Though they are twice as effective as regular heatsink, they are three times the size, so the increase is 50% rather than actually double.",
				texture = 'bitmaps/ui/perkbgability.png',	
			},
			valid = isMechBay,
			applyTo = allMechs,
			applyPerk = function (unitID, level, invert) 
				local effect = 1.5
				effect = (invert and 1/effect) or effect
				
				env = Spring.UnitScript.GetScriptEnv(unitID)
				env.baseCoolRate = env.baseCoolRate * effect
				env.heatLimit = env.heatLimit * effect
				Spring.SetUnitRulesParam(unitID, "heatLimit", env.heatLimit)
			end,
			costFunction = deductSalvage,
			price = 10,
		},
		{
			name = "coolantpods",
			menu = "tactical",
			cmdDesc = {
				id = GetCmdID('MOD_COOLANT_PODS'),
				action = 'modcoolantpods',
				name = GG.Pad("Coolant", "Pods"),
				tooltip = 'Gives Mechs the "Coolant Flush" ability with 5 charges.',
				texture = 'bitmaps/ui/perkbgability.png',	
			},
			valid = isMechBay,
			applyTo = allMechs,
			applyPerk = function (unitID, level, invert)
				GG.EnableCoolantFlush(unitID, not invert)
			end,
			costFunction = deductSalvage,
			price = 5,
		},
		{
			name = "emergencycoolantsystem",
			menu = "tactical",
			cmdDesc = {
				id = GetCmdID('MOD_EMERGENCY_COOLANT_SYSTEM'),
				action = 'modemergencycoolantsystem',
				name = GG.Pad("Emergency", "Coolant", "System"),
				tooltip = 'A further upgrade for Coolant Pods, this system will automatically trigger a coolant flush when the Mech reaches high heat levels.',
				texture = 'bitmaps/ui/perkbgability.png',	
			},
			valid = isMechBay,
			applyTo = allMechs,
			applyPerk = function (unitID, level, invert)
				GG.EnableAutoCoolant(unitID, not invert)
			end,
			costFunction = deductSalvage,
			requires = "coolantpods",
			price = 10,
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
			applyTo = allMechs,
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
			price = 10,
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
			applyTo = function (unitDefID) return (allMechs(unitDefID) and hasECM(unitDefID)) end,
			applyPerk = function (unitID, level, invert) 
				local effect = 1.5
				effect = (invert and 1/effect) or effect
				
				local currECM = Spring.GetUnitSensorRadius(unitID, "radarJammer")
				Spring.SetUnitSensorRadius(unitID, "radarJammer", currECM * effect)
				GG.allyJammers[Spring.GetUnitAllyTeam(unitID)][unitID] = currECM * effect
			end,
			costFunction = deductSalvage,
			price = 10,
		},
		{
			name = "inarc",
			menu = "tactical",
			cmdDesc = {
				id = GetCmdID('MOD_I_NARC'),
				action = 'modinarc',
				name = GG.Pad("Improved", "NARC"),
				tooltip = "Improved Narc Launcher. 50% range increase and Homing Pod duration. It also unlocks additional iNarc Pod upgrades (see Offensive upgrades section).",
				texture = 'bitmaps/ui/perkbgability.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return allMechs(unitDefID) and hasWeaponName(unitDefID, "NARC") end,
			applyPerk = function (unitID, level, invert) 
				local effect = 1.5
				effect = (invert and 1/effect) or effect
				
				local currDuration = Spring.GetUnitRulesParam(unitID, "NARC_DURATION") or Spring.GetGameRulesParam("NARC_DURATION")
				Spring.SetUnitRulesParam(unitID, "NARC_DURATION", currDuration * effect)
				setWeaponClassAttribute(unitID, "narc", "range", effect)
			end,
			costFunction = deductSalvage,
			price = 10,
		},
		-- Defensive
		{
			name = "protectedactuators",
			menu = "defensive",
			cmdDesc = {
				id = GetCmdID('MOD_PROTECTED_ACTUATORS'),
				action = 'modprotectedactuators',
				name = GG.Pad("Protected", "Actuators"),
				tooltip = 'Increases limb health by 25%.',
				texture = 'bitmaps/ui/perkgreen.png',	
			},
			valid = isMechBay,
			applyTo = allMechs,
			applyPerk = function (unitID, level, invert)
				local effect = 1.25
				effect = (invert and 1/effect) or effect
				
				env = Spring.UnitScript.GetScriptEnv(unitID)
				Spring.UnitScript.CallAsUnit(unitID, env.SetLimbMaxHP, effect)
			end,
			costFunction = deductSalvage,
			price = 5,
		},
		{
			name = "particlefielddamper",
			menu = "defensive",
			cmdDesc = {
				id = GetCmdID('MOD_PARTICLE_FIELD_DAMPER'),
				action = 'modparticlefielddamper',
				name = GG.Pad("Particle", "Field", "Damper"),
				tooltip = 'Reduces the amount of time electronics are affected by "PPC effect" from PPC hits.',
				texture = 'bitmaps/ui/perkgreen.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return (allMechs(unitDefID) and hasECM(unitDefID)) end,
			applyPerk = function (unitID, level, invert)
				local effect = 0.5
				effect = (invert and 1/effect) or effect
				
				Spring.SetUnitRulesParam(unitID, "insulation", effect)
			end,
			costFunction = deductSalvage,
			price = 10,
		},
		{
			name = "reinforcedlegs",
			menu = "defensive",
			cmdDesc = {
				id = GetCmdID('MOD_REINFORCED_LEGS'),
				action = 'modreinforcedlegs',
				name = GG.Pad("Reinforced", "Legs"),
				tooltip = 'Damage taken by executing Death from Above attacks reduced by half.',
				texture = 'bitmaps/ui/perkgreen.png',	
			},
			valid = isMechBay,
			applyTo = hasJumpjets,
			applyPerk = function (unitID, level, invert)
				GG.SetUnitReinforcedLegs(unitID, not invert)
			end,
			costFunction = deductSalvage,
			price = 7,
		},
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
			applyTo = allMechs,
			applyPerk = function (unitID, level, invert)
				GG.EnableArmour(unitID, not invert, "ferro")
			end,
			costFunction = deductSalvage,
			price = 7,
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
			applyTo = allMechs,
			applyPerk = function (unitID, level, invert)
				GG.EnableArmour(unitID, not invert, "hard")
				-- TODO: nullify double damage from AP and T-C
				
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
			price = 10,
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
			applyTo = allMechs,
			applyPerk = function (unitID, level, invert)
				GG.EnableArmour(unitID, not invert, "heat")
			end,
			costFunction = deductSalvage,
			price = 5,
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
			applyTo = allMechs,
			applyPerk = function (unitID, level, invert)
				GG.EnableArmour(unitID, not invert, "reactive")
			end,
			costFunction = deductSalvage,
			price = 10,
		},
		{
			name = "reflecarmour",
			menu = "defensive",
			cmdDesc = {
				id = GetCmdID('MOD_REFLEC_ARMOUR'),
				action = 'modreflecarmour',
				name = GG.Pad("Reflec", "Armour"),
				tooltip = '25% increased defense against damage from energy weapons - Lasers, PPCs and Plasma weapons.',
				texture = 'bitmaps/ui/perkgreen.png',	
			},
			valid = isMechBay,
			applyTo = allMechs,
			applyPerk = function (unitID, level, invert)
				GG.EnableArmour(unitID, not invert, "reflec")
			end,
			costFunction = deductSalvage,
			price = 10,
		},
		-- Offensive
		{
			name = "targetingcomputer",
			menu = "offensive",
			cmdDesc = {
				id = GetCmdID('MOD_TARGETING_COMPUTER'),
				action = 'modtargetingcomputer',
				name = GG.Pad("Targeting", "Computer"),
				tooltip = 'Increases the accuracy of all ballistic and energy direct-fire weapons by 25%, except weapons which fire in bursts.',
				texture = 'bitmaps/ui/perkbgfaction.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) 
				return hasWeaponClass(unitDefID, "autocannon", "salvoSize", true, 1) 
				or hasWeaponClass(unitDefID, "gauss", "salvoSize", true, 1) 
				or hasWeaponClass(unitDefID, "ppc", "salvoSize", true, 1) 
				or hasWeaponClass(unitDefID, "energy", "soundTrigger", true, true) 
			end,
			applyPerk = function (unitID, level, invert)
				--Spring.Echo("Missile range selected") 
				local effect = 0.75 -- smaller accuracy is better, 25% reduction
				effect = (invert and 1/effect) or effect
				
				setWeaponClassAttribute(unitID, "autocannon", "accuracy", effect, "salvoSize", true, 1)
				setWeaponClassAttribute(unitID, "gauss", "accuracy", effect, "salvoSize", true, 1)
				setWeaponClassAttribute(unitID, "ppc", "accuracy", effect, "salvoSize", true, 1)
				setWeaponClassAttribute(unitID, "energy", "accuracy", effect, "soundTrigger", true, true)
			end,
			costFunction = deductSalvage,
			price = 10,
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
			applyTo = function (unitDefID) return hasWeaponClass(unitDefID, "mrm") and isFaction(unitDefID, "dc") end,
			applyPerk = function (unitID, level, invert)
				--Spring.Echo("Missile range selected") 
				local effect = 0.75 -- smaller accuracy is better, 25% reduction
				effect = (invert and 1/effect) or effect
				
				setWeaponClassAttribute(unitID, "mrm", "accuracy", effect)
			end,
			costFunction = deductSalvage,
			price = 10,
		},
		{
			name = "extendedrangelrm",
			menu = "offensive",
			cmdDesc = {
				id = GetCmdID('MOD_EXTENDED_RANGE_LRM'),
				action = 'modextendedrangelrm',
				name = GG.Pad("Extended", "Range", "LRM"),
				tooltip = 'Applies to LRMs only. Increases LRM range by 50%, but reduces ammo by 50% and will not receive tracking/damage bonus from TAG/Narc.',
				texture = 'bitmaps/ui/perkbgfaction.png',	
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
				env.maxAmmo["lrm"] = env.maxAmmo["lrm"] * effect
				env.currAmmo["lrm"] = env.maxAmmo["lrm"]
				Spring.SetUnitRulesParam(unitID, "ammo_lrm", 100)
				-- TODO: Remove tracking bonus (TODO: implement tracking bonus)
			end,
			costFunction = deductSalvage,
			price = 10,
		},
		{
			name = "improvedheavygauss",
			menu = "offensive",
			cmdDesc = {
				id = GetCmdID('MOD_IMPROVED_HEAVY_GAUSS'),
				action = 'modimprovedheavygauss',
				name = GG.Pad("Improved", "Heavy", "Gauss"),
				tooltip = 'Heavy Gauss only. Shots do consistent damage (1900) at all ranges, increasing damage at long ranges but decreasing it at close range.',
				texture = 'bitmaps/ui/perkbgfaction.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return (allMechs(unitDefID) and hasWeaponName(unitDefID, "heavygauss") and isFaction(unitDefID, "la")) end,
			applyPerk = function (unitID, level, invert)
				local _, toChange = hasWeaponName(Spring.GetUnitDefID(unitID), "heavygauss")
				for weapNum in pairs(toChange) do
					Spring.SetUnitWeaponDamages(unitID, weapNum, "dynDamageExp", invert and 1 or 0)
					for i = 0, NUM_DAMAGE_TYPES do -- there are 13 armourdefs
						Spring.SetUnitWeaponDamages(unitID, weapNum, i, invert and 2160 or 1900) -- TODO: doesn't account for per-armour type reductions, eeek!
					end
				end
			end,
			costFunction = deductSalvage,
			price = 10,
		},
		{
			name = "ppccapacitors",
			menu = "offensive",
			cmdDesc = {
				id = GetCmdID('MOD_PPC_CAPACITORS'),
				action = 'modppccapacitors',
				name = GG.Pad("PPC", "Capacitors"),
				tooltip = 'Applies to PPCs (all variations) only. Increases damage of PPCs by 25% but increases heat generated by 50%.',
				texture = 'bitmaps/ui/perkbgfaction.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return (allMechs(unitDefID) and hasWeaponClass(unitDefID, "ppc") and isFaction(unitDefID, "dc")) end,
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
			price = 10,
		},
		{
			name = "quickchargingcapacitors",
			menu = "offensive",
			cmdDesc = {
				id = GetCmdID('MOD_QUICK_CHARGING_CAPACITORS'),
				action = 'modquickchargingcapacitors',
				name = GG.Pad("Quick", "Charging", "Capacitors"),
				tooltip = 'Gauss-based weapons only. Rate of fire increased by 25%, but generates heat similar to a PPC.',
				texture = 'bitmaps/ui/perkbgfaction.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponClass(unitDefID, "gauss") and (isFaction(unitDefID, "la") or isFaction(unitDefID, "fw")) end,
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
			price = 10,
		},
		{
			name = "silverbullet",
			menu = "offensive",
			cmdDesc = {
				id = GetCmdID('MOD_SILVER_BULLET'),
				action = 'modsilverbullet',
				name = GG.Pad("Silver", "Bullet", "Gauss"),
				tooltip = 'Regular Gauss Rifle only. Transforms the Gauss into an LBX-like weapon that fires 15 flechette rounds.',
				texture = 'bitmaps/ui/perkbgfaction.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponName(unitDefID, "gauss") and isFaction(unitDefID, "la") end,
			applyPerk = function (unitID, level, invert)
				--Spring.Echo("Missile range selected") 
				GG.EnableSilverBullet(unitID, not invert)
			end,
			costFunction = deductSalvage,
			price = 15,
		},
		-- Ammo
		{
			name = "ammoprecision",
			menu = "ammo",
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_PRECISION'),
				action = 'modammoprecision',
				name = GG.Pad("Autocannon", "Precision"),
				tooltip = 'Autocannons only. Increases range and accuracy of autocannons by 25%, but with 50% reduction in ammunition.',
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponClass(unitDefID, "autocannon") and isFaction(unitDefID, "fs") end,
			applyPerk = function (unitID, level, invert)
				-- increase range, accuracy by 25%
				local effect = 1.25
				effect = (invert and 1/effect) or effect
				local changed = setWeaponClassAttribute(unitID, "autocannon", "range", effect)
				-- increase accuracy by 25%, lower is better
				effect = 0.75
				effect = (invert and 1/effect) or effect
				setWeaponClassAttribute(unitID, "autocannon", "accuracy", effect)
				-- reduce max ammo by 50%
				effect = 0.5
				effect = (invert and 1/effect) or effect
				env = Spring.UnitScript.GetScriptEnv(unitID)
				local ammoCache = {}
				for weapNum, wd in pairs(changed) do
					local ammoType = wd.customParams.ammotype
					if not ammoCache[ammoType] then -- only once per ammotype
						ammoCache[ammoType] = true
						env.maxAmmo[ammoType] = env.maxAmmo[ammoType] * effect
						env.currAmmo[ammoType] = env.maxAmmo[ammoType]
						Spring.SetUnitRulesParam(unitID, "ammo_" .. ammoType, 100)
					end
				end
			end,
			costFunction = deductSalvage,
			price = 5,
		},
		{
			name = "ammoarmourpiercing",
			menu = "ammo",
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_ARMOUR_PIERCING'),
				action = 'modammoarmourpiercing',
				name = GG.Pad("Autocannon", "Armour", "Piercing"),
				tooltip = 'Autocannons only. Increases damage of shells by 25%, but with 50% reduction in ammunition and 25% reduction in accuracy.',
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponClass(unitDefID, "autocannon") and isFaction(unitDefID, "fs") end,
			applyPerk = function (unitID, level, invert)
				-- increase range, accuracy by 25%
				local effect = 1.25
				effect = (invert and 1/effect) or effect
				local changed = setWeaponClassDamage(unitID, "autocannon", effect)
				-- decrease accuracy by 25%, lower is better
				effect = 1.25
				effect = (invert and 1/effect) or effect
				setWeaponClassAttribute(unitID, "autocannon", "accuracy", effect)
				-- reduce max ammo by 50%
				effect = 0.5
				effect = (invert and 1/effect) or effect
				env = Spring.UnitScript.GetScriptEnv(unitID)
				local ammoCache = {}
				for weapNum, wd in pairs(changed) do
					local ammoType = wd.customParams.ammotype
					if not ammoCache[ammoType] then -- only once per ammotype
						ammoCache[ammoType] = true
						env.maxAmmo[ammoType] = env.maxAmmo[ammoType] * effect
						env.currAmmo[ammoType] = env.maxAmmo[ammoType]
						Spring.SetUnitRulesParam(unitID, "ammo_" .. ammoType, 100)
					end
				end
			end,
			costFunction = deductSalvage,
			price = 10,
		},
		{
			name = "ammocaseless",
			menu = "ammo",
			cmdDesc = {
				id = GetCmdID('MOD_AMMO_CASELESS'),
				action = 'modammocaseless',
				name = GG.Pad("Autocannon", "Caseless"),
				tooltip = 'Autocannons only.  Increases ammunition storage by 50%.',
				texture = 'bitmaps/ui/perkyellow.png',	
			},
			valid = isMechBay,
			applyTo = function (unitDefID) return hasWeaponClass(unitDefID, "autocannon") and isFaction(unitDefID, "fs") end,
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
						env.maxAmmo[ammoType] = env.maxAmmo[ammoType] * effect
						env.currAmmo[ammoType] = env.maxAmmo[ammoType]
						Spring.SetUnitRulesParam(unitID, "ammo_" .. ammoType, 100)
					end
				end
			end,
			costFunction = deductSalvage,
			price = 5,
		},
		{
			name = "ammolrminferno",
			menu = "ammo",
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
			price = 5,
		},
		{
			name = "ammolrmmagpulse",
			menu = "ammo",
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
			price = 5,
		},
		{
			name = "ammosrminferno",
			menu = "ammo",
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
			price = 5,
		},
	},
}