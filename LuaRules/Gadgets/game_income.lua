function gadget:GetInfo()
	return {
		name		= "Game - Income",
		desc		= "Damage, Insurance and Sell Income",
		author		= "FLOZi (C. Lawrence)",
		date		= "26/07/20",
		license 	= "GNU GPL v2",
		layer		= 3,
		enabled	= true,
	}
end

if gadgetHandler:IsSyncedCode() then
--	SYNCED

local modOptions = Spring.GetModOptions()

-- localisations
local SetUnitRulesParam		= Spring.SetUnitRulesParam
--SyncedRead
local AreTeamsAllied		= Spring.AreTeamsAllied
--SyncedCtrl
local AddTeamResource 		= Spring.AddTeamResource
local DestroyUnit			= Spring.DestroyUnit
local InsertUnitCmdDesc		= Spring.InsertUnitCmdDesc

-- Constants
local CBILLS_PER_SEC = (modOptions and tonumber(modOptions.income)) or 10
local BEACON_ID = UnitDefNames["beacon"].id

local DAMAGE_REWARD_MULT = (modOptions and tonumber(modOptions.income_damage)) or 0.1
Spring.SetGameRulesParam("damage_reward_mult", DAMAGE_REWARD_MULT)
local INSURANCE_MULT = (modOptions and tonumber(modOptions.insurance)) or 0.1
Spring.SetGameRulesParam("insurance_mult", INSURANCE_MULT)

local MELTDOWN = WeaponDefNames["meltdown"].id

function gadget:UnitDamaged(unitID, unitDefID, teamID, damage, paralyzer, weaponID,  projectileID, attackerID, attackerDefID, attackerTeam)
	if attackerID and attackerDefID and attackerTeam and not AreTeamsAllied(teamID, attackerTeam) then
		if GG.mechCache[attackerDefID] then -- only mechs generate income
			-- don't allow income from nukes
			if not (weaponID and weaponID == MELTDOWN) then		
				AddTeamResource(attackerTeam, "metal", damage * DAMAGE_REWARD_MULT)
			end
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID, attackerID, attackerDefID, attackerTeam)
	-- Insurance income
	if attackerID and not AreTeamsAllied(teamID, attackerTeam) and GG.mechCache[unitDefID] then
		AddTeamResource(teamID, "metal", UnitDefs[unitDefID].metalCost * INSURANCE_MULT)
	end
end

function gadget:AllowResourceLevel(teamID, res, amount)
	if res == "e" then 
		return false 
	end
	return true
end

function gadget:AllowResourceTransfer(oldTeamID, newTeamID, res, amount)
	if res == "e" then 
		return false 
	end
	return true
end

function gadget:GameFrame(n)
	if n > 0 and n % 30 == 0 then -- once a second
		-- Beacon Income
		for _, teamID in pairs(Spring.GetTeamList()) do
			AddTeamResource(teamID, "metal", CBILLS_PER_SEC * Spring.GetTeamUnitDefCount(teamID, BEACON_ID))
		end
	end
end

function gadget:Initialize()
	for _,unitID in ipairs(Spring.GetAllUnits()) do
		local teamID = Spring.GetUnitTeam(unitID)
		local unitDefID = Spring.GetUnitDefID(unitID)
		gadget:UnitCreated(unitID, unitDefID, teamID)
	end
end

else
--	UNSYNCED
return false end