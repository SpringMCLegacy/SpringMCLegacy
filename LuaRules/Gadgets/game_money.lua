function gadget:GetInfo()
	return {
		name = "Game Money",
		desc = "Units can only be built if you have the money",
		author = "FLOZi (C. Lawrence)",
		date = "30/01/2011",
		license = "GNU GPL v2",
		layer = 1,
		enabled = true
	}
end

if (gadgetHandler:IsSyncedCode()) then
--SYNCED

-- Localisations

-- Synced Read
local AreTeamsAllied 		= Spring.AreTeamsAllied
local GetTeamResources		= Spring.GetTeamResources
local GetUnitCmdDescs 		= Spring.GetUnitCmdDescs
local GetUnitTeam 			= Spring.GetUnitTeam
-- Synced Ctrl
local AddTeamResource 		= Spring.AddTeamResource
local EditUnitCmdDesc		= Spring.EditUnitCmdDesc
local FindUnitCmdDesc		= Spring.FindUnitCmdDesc
local SetUnitResourcing		= Spring.SetUnitResourcing
local UseTeamResource 		= Spring.UseTeamResource

-- Unsynced Ctrl

-- Constants
local DAMAGE_REWARD_MULT = 0.1
local KILL_REWARD_MULT = 0.1

-- Variables
local modOptions = Spring.GetModOptions()
local dropShips = {}

function gadget:AllowUnitCreation(unitDefID, builderID, teamID, x, y, z)
	ud = UnitDefs[unitDefID]
	local money = GetTeamResources(teamID, "metal")
	local weightLeft = GetTeamResources(teamID, "energy")
	local buildCost = ud.metalCost
	local weight = ud.energyCost
	if buildCost > money or weight > weightLeft then
		return false
	end
	if ud.speed > 0 then
		local env = Spring.UnitScript.GetScriptEnv(builderID)
		Spring.UnitScript.CallAsUnit(builderID, env.GetUnitDef, unitDefID)
	end
	return true
end

function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
	if modOptions and (modOptions.income ~= "none" and modOptions.income ~= "dropship") then
		if attackerID and not AreTeamsAllied(unitTeam, attackerTeam) then
			AddTeamResource(attackerTeam, "metal", damage * DAMAGE_REWARD_MULT)
		end
	end
end

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	local ud = UnitDefs[unitDefID]
	if ud.builder then -- warning, assumes no other builders or factories!
		dropShips[unitID] = true
		if modOptions and modOptions.income == "none" then
			SetUnitResourcing(unitID, "umm", 0)
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	dropShips[unitID] = nil
	if modOptions and (modOptions.income ~= "none" and modOptions.income ~= "dropship") then
		if attackerID and not AreTeamsAllied(unitTeam, attackerTeam) then
			AddTeamResource(attackerTeam, "metal", UnitDefs[unitDefID].metalCost * KILL_REWARD_MULT)
		end
	end
	-- reimburse 'weight'
	AddTeamResource(unitTeam, "energy", UnitDefs[unitDefID].energyCost)
end

function gadget:UnitGiven(unitID, unitDefID, unitTeam, oldTeam)
	-- reimburse 'weight'
	local weight = UnitDefs[unitDefID].energyCost
	AddTeamResource(oldTeam, "energy", weight)
	UseTeamResource(unitTeam, "energy", weight)
end

function gadget:GameFrame(n)
	if n % 30 == 0 then
		for unitID in pairs(dropShips) do
			local teamID = GetUnitTeam(unitID)
			local money = GetTeamResources(teamID, "metal")
			local weightLeft = GetTeamResources(teamID, "energy")
			local cmdDescs = GetUnitCmdDescs(unitID)
			for cmdDescID = 1, #cmdDescs do
				local buildDefID = cmdDescs[cmdDescID].id
				if buildDefID < 0 then -- a build order
					local buildCost = UnitDefs[-buildDefID].metalCost
					local weight = UnitDefs[-buildDefID].energyCost
					if buildCost > money then
						EditUnitCmdDesc(unitID, cmdDescID, {disabled = true})--, params = {"C"}})
					elseif weight > weightLeft then
						EditUnitCmdDesc(unitID, cmdDescID, {disabled = true})--, params = {"T"}})
					else
						EditUnitCmdDesc(unitID, cmdDescID, {disabled = false})--, params = {}})
					end
				end
			end
		end
	end
end

else

-- UNSYNCED

end
