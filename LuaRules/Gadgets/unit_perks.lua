function gadget:GetInfo()
	return {
		name = "Unit Perks",
		desc = "XP Unlocked Unit Perks",
		author = "FLOZi (C. Lawrence)",
		date = "31/03/2013",
		license = "GNU GPL v2",
		layer = 2, -- run after game_radar
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
local PERK_XP_COST = 0.2
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
end
	
function gadget:UnitExperience(unitID, unitDefID, teamID, gainedExp, totalExp)
	--Spring.Echo("Unit " .. unitID .. " (" .. UnitDefs[unitDefID].name .. ") gained exp: " .. gainedExp)
	-- enable perks here
	local ud = UnitDefs[unitDefID]
	local cp = ud.customParams
	if cp and cp.unittype == "mech" then
		if totalExp > PERK_XP_COST then
			Spring.Echo("Unit " .. unitID .. " (" .. UnitDefs[unitDefID].name .. ") ready to perk up! " .."(Exp: " .. totalExp ..")")
			for perkCmdID, perkDef in pairs(perkDefs) do
				--Spring.Echo(perkCmdDesc.name, FindUnitCmdDesc(unitID, perkCmdDesc.id))
				if not currentPerks[unitID][perkDef.name] then
					EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, perkCmdID), {disabled = false})
				end
			end
		end
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
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
			SetUnitExperience(unitID, newExp)
			-- Check if we have enough xp left to select another perk
			if newExp < PERK_XP_COST then
				-- disable perks here
				for perkCmdID, perkDef in pairs(perkDefs) do
					if not currentPerks[unitID][perkDef.name] then
						EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, perkCmdID), {disabled = true})
					end
				end
			end
		else 
			return false
		end
	end
	return true
end

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local ud = UnitDefs[unitDefID]
	local cp = ud.customParams
	if cp and cp.unittype == "mech" then
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
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	currentPerks[unitID] = nil
end

else

-- UNSYNCED

end
