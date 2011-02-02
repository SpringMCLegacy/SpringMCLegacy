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

-- Unsynced Ctrl

-- Constants
local DAMAGE_REWARD_MULT = 1
local KILL_REWARD_MULT = 0.5

-- Variables
local modOptions = Spring.GetModOptions()
local dropShips = {}

function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
	if modOptions and modOptions.income == "damage" then
		if not AreTeamsAllied(unitTeam, attackerTeam) then
			AddTeamResource(attackerTeam, "metal", damage * DAMAGE_REWARD_MULT)
		end
	end
end

function gadget:UnitCreated(unitID, unitDefID, teamID)
	local ud = UnitDefs[unitDefID]
	if ud.builder then -- warning, assumes no other builders or factories!
		dropShips[unitID] = true
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	dropShips[unitID] = nil
	if modOptions and modOptions.income == "damage" then
		if attackerID and not AreTeamsAllied(unitTeam, attackerTeam) then
			AddTeamResource(attackerTeam, "metal", UnitDefs[unitDefID].metalCost * KILL_REWARD_MULT)
		end
	end
end

function gadget:GameFrame(n)
	if n % 30 == 0 then
		for unitID in pairs(dropShips) do
			local teamID = GetUnitTeam(unitID)
			local money = GetTeamResources(teamID, "metal")
			local cmdDescs = GetUnitCmdDescs(unitID)
			for cmdDescID = 1, #cmdDescs do
				local buildDefID = cmdDescs[cmdDescID].id
				if buildDefID < 0 then -- a build order
					local buildCost = UnitDefs[-buildDefID].metalCost
					if buildCost > money then
						EditUnitCmdDesc(unitID, cmdDescID, {disabled = true})
					else
						EditUnitCmdDesc(unitID, cmdDescID, {disabled = false})
					end
				end
			end
		end
	end
end

else

-- UNSYNCED

end
