function gadget:GetInfo()
	return {
		name = "Unit Perks",
		desc = "XP Unlocked Unit Perks",
		author = "FLOZi (C. Lawrence)",
		date = "31/03/2013",
		license = "GNU GPL v2",
		layer = 1,
		enabled = true
	}
end

if (gadgetHandler:IsSyncedCode()) then
--SYNCED

-- Localisations

-- Synced Read
local GetUnitCmdDescs 		= Spring.GetUnitCmdDescs

-- Synced Ctrl
local EditUnitCmdDesc		= Spring.EditUnitCmdDesc
local InsertUnitCmdDesc		= Spring.InsertUnitCmdDesc
local FindUnitCmdDesc		= Spring.FindUnitCmdDesc

-- Unsynced Ctrl

-- Constants
local PERK_XP_COST = 0.01
-- Variables
local perkDefs = {} -- perkCmdID = PerkDef table
local currentPerks = {} -- currentPerks = {unitID = {perk1 = true, perk2 = true}}

local perkInclude = VFS.Include("LuaRules/Configs/perk_defs.lua")
for perkName, perkDef in pairs(perkInclude) do
	perkDef.name = perkName
	perkDefs[perkDef.cmdDesc.id] = perkDef
end

function gadget:Initialize()
	Spring.Echo("Perk Cost is: " .. PERK_XP_COST)
	Spring.SetExperienceGrade(PERK_XP_COST)
end
	
function gadget:UnitExperience(unitID, unitDefID, teamID, experience, oldExp)
	Spring.Echo("Unit " .. unitID .. " (" .. UnitDefs[unitDefID].name .. ") gained exp: " .. experience)
	-- enable perks here
	local ud = UnitDefs[unitDefID]
	local cp = ud.customParams
	if cp and cp.unittype == "mech" then
		for perkCmdID, perkDef in pairs(perkDefs) do
			--Spring.Echo(perkCmdDesc.name, FindUnitCmdDesc(unitID, perkCmdDesc.id))
			if not currentPerks[unitID][perkDef.name] then
				EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, perkCmdID), {disabled = false})
			end
		end
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	local perkDef = perkDefs[cmdID]
	local ud = UnitDefs[unitDefID]
	local cp = ud.customParams
	if perkDef then
		if cp and cp.unittype == "mech" then
			perkDef.applyPerk(unitID)
			EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, cmdID), {name = perkDef.cmdDesc.name .."\n(Trained)"})
			currentPerks[unitID][perkDef.name] = true
			-- disable perks here
			for perkCmdID, perkDef in pairs(perkDefs) do
				EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, perkCmdID), {disabled = true})
			end
			return true
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
		for perkCmdID, perkDef in pairs(perkDefs) do
			local perkCmdDesc = perkDef.cmdDesc
			-- Don't add perks that can't be used on this mech
			if perkDef.valid(unitDefID) then
				InsertUnitCmdDesc(unitID, perkCmdDesc)
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
