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

local function deductSalvage(unitID, amount)
	local teamID = Spring.GetUnitTeam(unitID)
	GG.ChangeTeamSalvage(teamID, amount)
end

return {
	-- Weapon (Faction) specific
	{
		name = "extendedrangelrm",
		cmdDesc = {
			id = GetCmdID('UPGRADE_EXTENDEDRANGELRM'),
			action = 'upgradeextendedrangelrm',
			name = GG.Pad("Extended", "Range", "LRM"),
			tooltip = 'Applies to LRMs only. Increases LRM range by 50%, but reduces ammo by 50% and will not receive tracking/damage bonus from TAG/Narc. Is incompatible with Artemis IV upgrade and LRM special ammo.',
			texture = 'bitmaps/ui/perkbgfaction.png',	
		},
		valid = function (unitDefID) return (allMechs(unitDefID) and hasWeaponClass(unitDefID, "lrm")) end,
		applyPerk = function (unitID) 
			--Spring.Echo("Missile range selected") 
			setWeaponClassAttribute(unitID, "lrm", "range", 1.5)
			-- TODO: reduce max ammo by 50%
			-- TODO: Remove tracking bonus (TODO: implement tracking bonus)
		end,
		costFunction = deductSalvage,
		price = 5,
	},
}