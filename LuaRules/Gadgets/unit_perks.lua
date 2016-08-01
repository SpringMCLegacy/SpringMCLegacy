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
local PERK_XP_COST = 1.5

-- function for toggling weapon status via gui
local CMD_WEAPON_TOGGLE = GG.CustomCommands.GetCmdID("CMD_WEAPON_TOGGLE")


-- Variables
local perkDefs = {} -- perkCmdID = PerkDef table
local validPerks = {} -- unitDefID = {perkCmdID = true, etc}
local currentPerks = {} -- currentPerks = {unitID = {perk1 = true, perk2 = true, ...}}
local perkUnits = {} -- unitID = baseclass

-- dropzone perks need to be persistent
local dropZonePerks = {} -- dropZonePerks[teamID] = {perk1 = true, perk2 = true, ...}

local perkInclude = VFS.Include("LuaRules/Configs/perk_defs.lua")
for perkName, perkDef in pairs(perkInclude) do
	perkDef.name = perkName
	perkDefs[perkDef.cmdDesc.id] = perkDef
end


local function UpdateRemaining(unitID, newLevel, price)
	-- disable perks here
	local perkRemaining = false
	for perkCmdID, perkDef in pairs(perkDefs) do
		if not currentPerks[unitID][perkDef.name] and validPerks[Spring.GetUnitDefID(unitID)][perkCmdID] then
			perkRemaining = true
			if (not newLevel) or not (price or perkDef.price) then
				Spring.Echo("ERROR: unit_perks:", newLevel, price, perkDef.price, UnitDefs[Spring.GetUnitDefID(unitID)].name)
			end
			if (newLevel < (price or perkDef.price)) or (perkDef.requires and not currentPerks[unitID][perkDef.requires]) then
				EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, perkCmdID), {disabled = true})
			else
				EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, perkCmdID), {disabled = false})
			end
		end
	end
	if not perkRemaining then
		Spring.SetUnitRulesParam(unitID, "perk_fully", 1)
	end
end

function gadget:Initialize()
	-- Support /luarules reload
	for _,unitID in ipairs(Spring.GetAllUnits()) do
		local teamID = Spring.GetUnitTeam(unitID)
		local unitDefID = Spring.GetUnitDefID(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
	
	for unitDefID, unitDef in pairs(UnitDefs) do
		for perkCmdID, perkDef in pairs(perkDefs) do -- using pairs here means perks aren't in order, use Find?
			local perkCmdDesc = perkDef.cmdDesc
			-- ...check if the perk is valid and cache the result
			local valid = perkDef.valid(unitDefID)
			if valid then
				if not validPerks[unitDefID] then -- first time
					validPerks[unitDefID] = {} 
				end
				validPerks[unitDefID][perkCmdID] = valid
			end
		end
	end
end

local function UpdateUnitPerks(unitID, baseclass)
	if baseclass == "mech" then -- only mechs use xp to perk up
		local newExp = Spring.GetUnitExperience(unitID)
		UpdateRemaining(unitID, newExp, PERK_XP_COST)
		Spring.SetUnitRulesParam(unitID, "perk_xp", math.min(100, 100 * newExp / PERK_XP_COST))
	elseif not select(3, Spring.GetUnitTeam(unitID)) then -- team isn't dead
		-- other units use CBills
		local cBills = select(1, Spring.GetTeamResources(Spring.GetUnitTeam(unitID), "metal"))
		UpdateRemaining(unitID, cBills)
	end
end

function gadget:GameFrame(n)
	for unitID, baseclass in pairs(perkUnits) do
		UpdateUnitPerks(unitID, baseclass)
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if cmdID == CMD_WEAPON_TOGGLE then
		env = Spring.UnitScript.GetScriptEnv(unitID)
		Spring.UnitScript.CallAsUnit(unitID, env.ToggleWeapon, cmdParams[1]) -- 1st param is weaponNum
		return false
	end
	local perkDef = perkDefs[cmdID]
	if perkDef and perkUnits[unitID] then
		local ud = UnitDefs[unitDefID]
		local cp = ud.customParams
		-- check that this unit can receive this perk (can be issued the order due to multiple units selected)
		-- ... and that it doesn't already have it
		if validPerks[unitDefID][cmdID] and not currentPerks[unitID][cmdID] then
			if perkDef.requires and not currentPerks[unitID][perkDef.requires] then return false end
			perkDef.applyPerk(unitID)
			EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, cmdID), {name = perkDef.cmdDesc.name .."\n  (Trained)", disabled = true})
			currentPerks[unitID][perkDef.name] = true
			-- deduct 'cost' of perk
			perkDef.costFunction(unitID, perkDef.price or PERK_XP_COST)
			UpdateUnitPerks(unitID, perkUnits[unitID]) -- update perks here too to prevent pause cheating
		else -- perk is not valid, command not accepted
			return false
		end
		-- return false for mechs (so command queue is not changed), true otherwise (to clear stack for dropzone?)
		return perkUnits[unitID] ~= "mech"
	end
	-- let all other commands run through this gadget unharmed
	return true
end

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local ud = UnitDefs[unitDefID]
	local cp = ud.customParams
	if validPerks[unitDefID] then
		 -- start out with enough XP for one perk
		if cp.baseclass == "mech" then
			Spring.SetUnitRulesParam(unitID, "perk_xp", 100)
			SetUnitExperience(unitID, PERK_XP_COST)
		end
		currentPerks[unitID] = {}
		perkUnits[unitID] = cp.baseclass

		for perkCmdID, perkDef in pairs(perkDefs) do -- using pairs here means perks aren't in order, use Find?
			if validPerks[unitDefID][perkCmdID] then -- Only add perks valid for this mech
				InsertUnitCmdDesc(unitID, perkDef.cmdDesc)
			end
		end
		-- check if unit is a DZ and team DZ has previously been perked
		if GG.DROPZONE_IDS[unitDefID] and dropZonePerks[teamID] then
			table.copy(dropZonePerks[teamID], currentPerks[unitID])
			for perkName in pairs(currentPerks[unitID]) do
				local perkDef = perkInclude[perkName]
				EditUnitCmdDesc(unitID, FindUnitCmdDesc(unitID, perkDef.cmdDesc.id), {name = perkDef.cmdDesc.name .."\n  (Trained)", disabled = true})
			end
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID)
	if GG.DROPZONE_IDS[unitDefID] then
		dropZonePerks[teamID] = {}
		table.copy(currentPerks[unitID], dropZonePerks[teamID])
	end
	currentPerks[unitID] = nil
	perkUnits[unitID] = nil
end

else

-- UNSYNCED

end
