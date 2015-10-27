function gadget:GetInfo()
	return {
		name = "Unit Perks",
		desc = "XP Unlocked Unit Perks",
		author = "FLOZi (C. Lawrence)",
		date = "31/03/2013",
		license = "GNU GPL v2",
		layer = 4, -- run after game_radar & unit_purchasing
		enabled = true
	}
end

if (gadgetHandler:IsSyncedCode()) then
--SYNCED

-- Localisations

-- Synced Read
local GetUnitCmdDescs 		= Spring.GetUnitCmdDescs
local GetUnitExperience		= Spring.GetUnitExperience

-- Synced Ctrl
local EditUnitCmdDesc		= Spring.EditUnitCmdDesc
local InsertUnitCmdDesc		= Spring.InsertUnitCmdDesc
local FindUnitCmdDesc		= Spring.FindUnitCmdDesc
local SetUnitExperience		= Spring.SetUnitExperience

-- Unsynced Ctrl

-- Constants
local MINIMUM_XP_INCREASE_TO_CHECK = 0.01
local PERK_XP_COST = 1.5

-- function for toggling weapon status via gui
local CMD_WEAPON_TOGGLE = GG.CustomCommands.GetCmdID("CMD_WEAPON_TOGGLE")


-- Variables
local perkDefs = {} -- perkCmdID = PerkDef table
local validPerks = {} -- unitDefID = {perkCmdID = true, etc}
local currentPerks = {} -- currentPerks = {unitID = {perk1 = true, perk2 = true}}

local perkInclude = VFS.Include("LuaRules/Configs/perk_defs.lua")
for perkName, perkDef in pairs(perkInclude) do
	perkDef.name = perkName
	perkDefs[perkDef.cmdDesc.id] = perkDef
end

function gadget:Initialize()
	Spring.SetExperienceGrade(MINIMUM_XP_INCREASE_TO_CHECK)
	-- Support /luarules reload
	for _,unitID in ipairs(Spring.GetAllUnits()) do
		local teamID = Spring.GetUnitTeam(unitID)
		local unitDefID = Spring.GetUnitDefID(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
end
	
function gadget:UnitExperience(unitID, unitDefID, teamID, newExp, oldExp)
	--Spring.Echo("Unit " .. unitID .. " (" .. UnitDefs[unitDefID].name .. ")", newExp, oldExp, newExp - oldExp, oldExp - newExp)
	-- enable perks here
	local ud = UnitDefs[unitDefID]
	local cp = ud.customParams
	if cp and cp.unittype == "mech" then
		if newExp > PERK_XP_COST then
			--Spring.Echo("Unit " .. unitID .. " (" .. UnitDefs[unitDefID].name .. ") ready to perk up! " .."(Exp: " .. newExp ..")")
			for perkCmdID, perkDef in pairs(perkDefs) do
				--Spring.Echo(perkCmdDesc.name, FindUnitCmdDesc(unitID, perkCmdDesc.id))
				if currentPerks[unitID] and not currentPerks[unitID][perkDef.name] then
					EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, perkCmdID), {disabled = false})
				end
			end
		end
		Spring.SetUnitRulesParam(unitID, "perk_xp", math.min(100, 100 * newExp / PERK_XP_COST))
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if cmdID == CMD_WEAPON_TOGGLE then
		env = Spring.UnitScript.GetScriptEnv(unitID)
		Spring.UnitScript.CallAsUnit(unitID, env.ToggleWeapon, cmdParams[1]) -- 1st param is weaponNum
		return false
	end
	local perkDef = perkDefs[cmdID]
	if perkDef then
		local ud = UnitDefs[unitDefID]
		local cp = ud.customParams
		-- check that this unit can receive this perk (can be issued the order due to multiple units selected)
		if cp and cp.unittype == "mech" and perkDef.valid(unitDefID) then
			perkDef.applyPerk(unitID)
			EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, cmdID), {name = perkDef.cmdDesc.name .."\n  (Trained)", disabled = true})
			currentPerks[unitID][perkDef.name] = true
			-- deduct xp 'cost' of perk
			local currExp = GetUnitExperience(unitID)
			local newExp = currExp - PERK_XP_COST
			--newExp = newExp >= 0 and newExp or 0 -- clamp >= 0, due to "first-perk-is-free"
			SetUnitExperience(unitID, newExp)
			Spring.SetUnitRulesParam(unitID, "perk_xp", math.min(100, 100 * newExp / PERK_XP_COST))
			-- Check if we have enough xp left to select another perk
			if newExp < PERK_XP_COST then
				-- disable perks here
				for perkCmdID, perkDef in pairs(perkDefs) do
					if not currentPerks[unitID][perkDef.name] then
						EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, perkCmdID), {disabled = true})
					end
				end
			end
		elseif ud.humanName == "Dropzone" then --and perkDef.valid(unitDefID) then
			perkDef.applyPerk(unitID)
			return true
		end
		-- always return false, even if command was carried out, so that command queue is not altered
		return false
	end
	return true
end

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local ud = UnitDefs[unitDefID]
	local cp = ud.customParams
	if cp and cp.unittype == "mech" then
		 -- start out with enough XP for one perk
		Spring.SetUnitRulesParam(unitID, "perk_xp", 100)
		SetUnitExperience(unitID, PERK_XP_COST)
		-- Only give perks to mech pilots
		currentPerks[unitID] = {}
		local firstTime = not validPerks[unitDefID]
		if firstTime then 
			validPerks[unitDefID] = {} 
		end
		for perkCmdID, perkDef in pairs(perkDefs) do -- using pairs here means perks aren't in order, use Find?
			local perkCmdDesc = perkDef.cmdDesc
			if firstTime then -- first time this kind of unit is produced... 
				-- ...check if the perk is valid and cache the result
				validPerks[unitDefID][perkCmdID] = perkDef.valid(unitDefID)
			end
			if validPerks[unitDefID][perkCmdID] then -- Only add perks valid for this mech
				InsertUnitCmdDesc(unitID, perkCmdDesc)
			else
				-- treat invalid perks as though they were already trained
				currentPerks[unitID][perkDef.name] = true
			end
		end
	elseif ud.humanName == "Dropzone" then -- GG.dropZones[unitID] then
		InsertUnitCmdDesc(unitID, perkInclude["drop"].cmdDesc)
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	currentPerks[unitID] = nil
end

else

-- UNSYNCED

end
